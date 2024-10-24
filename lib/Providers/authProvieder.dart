import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  AuthProvider() {
    _currentUser = _auth.currentUser; // Initialize with the current user
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user; // Update the user whenever authentication state changes
      notifyListeners();
    });
  }

  // Getter for current user ID
  String? get currentUserId => _currentUser?.uid;

  // Method to sign in
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle errors
      throw e;
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
