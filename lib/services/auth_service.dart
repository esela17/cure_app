import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Provides a stream to listen for changes in the user's authentication state (login/logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Authenticates a user with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Catch specific Firebase authentication errors and re-throw them for higher-level handling
      rethrow;
    }
  }

  // Registers a new user with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Signs out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Gets the currently authenticated user object
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
