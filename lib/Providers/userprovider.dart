import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../Models/usermodel.dart';

class UserProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool _isLoggingIn = false;
  UserModel? _currentUser; // This holds the current user details.
  UserModel? get currentUser => _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool get isLoggingIn => _isLoggingIn;
  User? _user;
  User? get user => _user;
  UserProvider(){
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Notify listeners when the authentication state changes
    });
  }
  Future<void> registerUser(UserModel user, String uid) async {
    try {
      // Check if any users already exist in the database
      final snapshot = await _dbRef.child('users').once();
      bool isFirstUser = snapshot.snapshot.value == null;

      // Assign role based on whether this is the first user or not
      String role = isFirstUser ? 'Manager' : 'User';
      user = UserModel(
        name: user.name,
        email: user.email,
        phone: user.phone,
        password: user.password,
        role: role,
        uid: uid, // Save the uid here
      );

      // Save user details to the database, indexed by their UID
      await _dbRef.child('users').child(uid).set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }


  Future<String?> loginUser(String email, String password) async {
    _isLoggingIn = true;
    notifyListeners();

    try {
      // Step 1: Authenticate with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());

      // Step 2: Fetch user details from Firebase Realtime Database using UID
      String uid = userCredential.user!.uid;

      DatabaseEvent event = await _dbRef.child('users').child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value == null) {
        _isLoggingIn = false;
        notifyListeners();
        throw Exception('User not found in the database.');
      }

      Map<dynamic, dynamic> user = snapshot.value as Map<dynamic, dynamic>; // Cast to Map

      // Step 3: Get the role of the user
      String role = user['role'];

      // Step 4: Return the role if login is successful
      _isLoggingIn = false;
      notifyListeners();
      return role; // Return the user's role ("Manager" or "User")

    } catch (error) {
      _isLoggingIn = false;
      notifyListeners();
      throw Exception('Login failed: ${error.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut(); // Sign out the user from Firebase
      _user = null; // Clear the user variable
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      throw Exception("Error logging out: ${e.toString()}"); // Handle any errors
    }
  }


  Future<void> fetchUserDetails(String uid) async {
    try {
      // Fetch user details directly using the UID
      DatabaseEvent event = await _dbRef.child('users').child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value == null) {
        throw Exception('User not found.');
      }

      // Convert the data to UserModel
      Map<dynamic, dynamic> user = snapshot.value as Map<dynamic, dynamic>;
      _currentUser = UserModel(
        name: user['name'],
        email: user['email'],
        phone: user['phone'],
        password: user['password'],
        role: user['role'],
        uid: user['uid']
      );

      notifyListeners(); // Notify listeners that user data has been updated
    } catch (error) {
      print('Failed to fetch user details: ${error.toString()}');
      throw Exception('Failed to fetch user details: ${error.toString()}');
    }
  }

}
