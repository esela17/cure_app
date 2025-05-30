import 'package:cure_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(AuthService authService) {
    // متابعة حالة تسجيل الدخول تلقائياً
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // تابع لتحديث حالة المستخدم
  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // تسجيل دخول (مثال بسيط، يمكن تخصيصه)
  Future<void> signIn(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      // سيتم تحديث _currentUser تلقائياً عن طريق listener
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
    }

    _isLoading = false;
    notifyListeners();
  }

  // تسجيل خروج
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.signOut();
      // عند تسجيل الخروج _currentUser سيكون null تلقائياً
    } catch (e) {
      _errorMessage = 'فشل في تسجيل الخروج';
    }

    _isLoading = false;
    notifyListeners();
  }

  // تسجيل مستخدم جديد (اختياري)
  Future<void> register(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
    }

    _isLoading = false;
    notifyListeners();
  }
}
