import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../Models/usermodel.dart';

class UserProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool _isLoggingIn = false;
  UserModel? _currentUser; // This holds the current user details.
  UserModel? get currentUser => _currentUser;

  bool get isLoggingIn => _isLoggingIn;


  Future<void> fetchCurrentUser(String uid) async {
    try {
      _currentUser = await fetchUserDetails(uid); // Fetch and set current user details
      notifyListeners(); // Notify listeners that the user data has been updated
    } catch (e) {
      throw Exception('Failed to load user data');
    }
  }


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

      if (snapshot.value == null) {
        _isLoggingIn = false;
        notifyListeners();
        throw Exception('No users found in the database.');
      }

      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>; // Cast to Map

      // Check if the user exists and validate the password
      for (var user in users.values) {
        // Compare email in a case-insensitive manner
        if (user['email'].toLowerCase() == email.toLowerCase()) {
          if (user['password'] == password) {
            _isLoggingIn = false;
            notifyListeners();
            return user['role']; // Return the user's role
          } else {
            // Password does not match
            _isLoggingIn = false;
            notifyListeners();
            throw Exception('Incorrect password.');
          }
        }
      }

      // User not found
      _isLoggingIn = false;
      notifyListeners();
      throw Exception('User not found.');
    } catch (error) {
      _isLoggingIn = false;
      notifyListeners();
      throw Exception('Login failed: ${error.toString()}');
    }
  }


  // Method to fetch user details by email
  Future<UserModel?> fetchUserDetails(String uid) async {
    try {
      _currentUser = await fetchUserDetails(uid); // Update the current user

      // Fetch users from the database
      DatabaseEvent event = await _dbRef.child('users').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value == null) {
        throw Exception('No users found in the database.');
      }

      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

      // Search for the user by UID
      for (var user in users.values) {
        if (user['uid'] == uid) { // Assuming you save UID in the database
          // Map the user data to UserModel and return
          return UserModel(
            name: user['name'],
            email: user['email'],
            phone: user['phone'],
            password: user['password'],
            role: user['role'],
          );
        }
      }

      throw Exception('User not found.');
    } catch (error) {
      throw Exception('Failed to fetch user details: ${error.toString()}');
    }
  }

}
