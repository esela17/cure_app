import 'dart:io';
import 'package:cure_app/models/user_model.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/services/notification_service.dart';
import 'package:cure_app/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  User? _currentUser;
  UserModel? _currentUserProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> fetchCurrentUserProfile() async {
    if (_currentUser != null) {
      try {
        final userProfile = await _firestoreService.getUser(_currentUser!.uid);
        if (userProfile != null) {
          _currentUserProfile = userProfile;
          _errorMessage = null;
        } else {
          _errorMessage = "User profile document not found in Firestore.";
        }
      } catch (e) {
        _errorMessage = "An error occurred while fetching profile: $e";
      }
    }
  }

  Future<void> _initNotificationsForUser(String uid) async {
    try {
      await _notificationService.requestPermission();
      final token = await _notificationService.getFcmToken();
      if (token != null && currentUserProfile?.fcmToken != token) {
        await _firestoreService.updateUser(uid, {'fcmToken': token});
      }
    } catch (e) {
      print("Error initializing notifications: $e");
      _errorMessage = "Failed to initialize notifications.";
    }
  }

  Future<void> updateAvailability(bool available) async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.updateUser(
        _currentUser!.uid,
        {'isAvailable': available},
      );
      await fetchCurrentUserProfile();
    } catch (e) {
      _errorMessage = "Failed to update availability: $e";
      notifyListeners();
    }
  }

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
      _errorMessage = "Failed to update data.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
      _errorMessage = 'Failed to upload image: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
    }
    _isLoading = false;
    notifyListeners();
  }

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
        UserModel userModel =
            UserModel(id: newUser.uid, name: name, email: email, phone: phone);
        await _firestoreService.addUser(userModel);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
