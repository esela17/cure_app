import 'dart:io';
import 'package:cure_app/models/user_model.dart';
import 'package:cure_app/services/auth_service.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/services/notification_service.dart';
import 'package:cure_app/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  User? _currentUser;
  UserModel? _currentUserProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(AuthService authService) {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // معالجة تغيّر حالة تسجيل الدخول
  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await fetchCurrentUserProfile();
      if (_errorMessage == null) {
        await _initNotificationsForUser(user.uid);
      }
    } else {
      _currentUserProfile = null;
    }
    notifyListeners();
  }

  // تحميل بيانات المستخدم من Firestore
  Future<void> fetchCurrentUserProfile() async {
    if (_currentUser != null) {
      try {
        final userProfile = await _firestoreService.getUser(_currentUser!.uid);
        if (userProfile != null) {
          _currentUserProfile = userProfile;
          _errorMessage = null;
        } else {
          _errorMessage = "لم يتم العثور على ملف المستخدم.";
        }
      } catch (e) {
        _errorMessage = "حدث خطأ أثناء تحميل البيانات: $e";
      }
    }
  }

  // تهيئة الإشعارات
  Future<void> _initNotificationsForUser(String uid) async {
    try {
      await _notificationService.requestPermission();
      final token = await _notificationService.getFcmToken();
      if (token != null && currentUserProfile?.fcmToken != token) {
        await _firestoreService.updateUser(uid, {'fcmToken': token});
      }
    } catch (e) {
      print("خطأ في الإشعارات: $e");
      _errorMessage = "فشل تهيئة الإشعارات.";
    }
  }

  // تحديث حالة التوفر
  Future<void> updateAvailability(bool available) async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.updateUser(
        _currentUser!.uid,
        {'isAvailable': available},
      );
      await fetchCurrentUserProfile();
    } catch (e) {
      _errorMessage = "فشل تحديث التوفر: $e";
      notifyListeners();
    }
  }

  // تحديث بيانات المستخدم
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateUser(_currentUser!.uid, data);
      await fetchCurrentUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "فشل تحديث البيانات.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // رفع صورة الملف الشخصي
  Future<void> pickAndUploadProfileImage() async {
    if (_currentUser == null) return;
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        _isLoading = true;
        notifyListeners();
        File imageFile = File(pickedFile.path);
        String uid = _currentUser!.uid;
        String downloadUrl =
            await _storageService.uploadImage(imageFile, 'profile_images/$uid');
        await updateUserProfile({'profileImageUrl': downloadUrl});
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'فشل رفع الصورة: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تسجيل الدخول بالإيميل وكلمة المرور
  Future<void> signIn(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateFirebaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تسجيل الخروج
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج.';
    }
    _isLoading = false;
    notifyListeners();
  }

  // تسجيل حساب جديد
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? newUser = userCredential.user;
      if (newUser != null) {
        UserModel userModel = UserModel(
          id: newUser.uid,
          name: name,
          email: email,
          phone: phone,
        );
        await _firestoreService.addUser(userModel);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ تسجيل الدخول عبر Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _errorMessage = 'تم إلغاء تسجيل الدخول عبر Google.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        final existingUser = await _firestoreService.getUser(user.uid);
        if (existingUser == null) {
          UserModel userModel = UserModel(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            profileImageUrl: user.photoURL,
          );
          await _firestoreService.addUser(userModel);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateFirebaseError(e);
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول عبر Google.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ✅ ترجمة الأخطاء
  String _translateFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد مستخدم بالفعل.';
      case 'invalid-email':
        return 'بريد إلكتروني غير صالح.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة.';
      default:
        return e.message ?? 'حدث خطأ غير معروف.';
    }
  }
}
