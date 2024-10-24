import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../Models/usermodel.dart';

class UserProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool _isLoggingIn = false;

  bool get isLoggingIn => _isLoggingIn;




  Future<void> registerUser(UserModel user) async {
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
      );

      await _dbRef.child('users').push().set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Method to login the user
  Future<String?> loginUser(String email, String password) async {
    _isLoggingIn = true;
    notifyListeners();

    try {
      // Fetch users from the database
      DatabaseEvent event = await _dbRef.child('users').once();
      DataSnapshot snapshot = event.snapshot;

      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>; // Cast to Map

      // Check if the user exists and validate the password
      for (var user in users.values) {
        if (user['email'] == email && user['password'] == password) {
          _isLoggingIn = false;
          notifyListeners();
          return user['role']; // Return the user's role
        }
      }

      // User not found
      _isLoggingIn = false;
      notifyListeners();
      throw Exception('User not found');
    } catch (error) {
      _isLoggingIn = false;
      notifyListeners();
      throw Exception('Login failed: $error');
    }
  }
}
