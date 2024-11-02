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

  List<UserModel> _users = []; // Initialize the _users list

  List<UserModel> get users => _users; // Expose the users list


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
        isActive: true
      );

      // Save user details to the database, indexed by their UID
      await _dbRef.child('users').child(uid).set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }


  // Future<String?> loginUser(String email, String password) async {
  //   _isLoggingIn = true;
  //   notifyListeners();
  //
  //   try {
  //     // Step 1: Authenticate with Firebase Authentication
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(email: email.trim(), password: password.trim());
  //
  //     // Step 2: Fetch user details from Firebase Realtime Database using UID
  //     String uid = userCredential.user!.uid;
  //
  //     DatabaseEvent event = await _dbRef.child('users').child(uid).once();
  //     DataSnapshot snapshot = event.snapshot;
  //
  //     if (snapshot.value == null) {
  //       _isLoggingIn = false;
  //       notifyListeners();
  //       throw Exception('User not found in the database.');
  //     }
  //
  //     Map<dynamic, dynamic> user = snapshot.value as Map<dynamic, dynamic>; // Cast to Map
  //
  //     // Step 3: Get the role of the user
  //     String role = user['role'];
  //
  //     // Step 4: Return the role if login is successful
  //     _isLoggingIn = false;
  //     notifyListeners();
  //     return role; // Return the user's role ("Manager" or "User")
  //
  //   } catch (error) {
  //     _isLoggingIn = false;
  //     notifyListeners();
  //     throw Exception('Login failed: ${error.toString()}');
  //   }
  // }

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

      // Convert the data safely
      Map<dynamic, dynamic> user = snapshot.value as Map<dynamic, dynamic>;

      // Step 3: Check if user is active
      bool isActive = user['active'] ?? true; // Assuming 'active' defaults to true if not set

      if (!isActive) {
        _isLoggingIn = false;
        notifyListeners();
        throw Exception('User account is inactive.');
      }

      // Step 4: Get the role of the user
      String role = user['role'];

      // Step 5: Return the role if login is successful
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
        uid: user['uid'],
        isActive: user['active']
      );

      notifyListeners(); // Notify listeners that user data has been updated
    } catch (error) {
      print('Failed to fetch user details: ${error.toString()}');
      throw Exception('Failed to fetch user details: ${error.toString()}');
    }
  }

  Future<void> fetchAllUsers() async {
    final DatabaseEvent event = await _dbRef.child('users').once();
    final DataSnapshot snapshot = event.snapshot; // Get the snapshot from DatabaseEvent

    if (snapshot.exists) {
      // Convert snapshot.value to Map<String, dynamic> safely
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // Now we can safely convert it to List<UserModel>
      _users = data.entries.map((entry) {
        return UserModel.fromMap(Map<String, dynamic>.from(entry.value), entry.key);
      }).toList();
    } else {
      _users = []; // Reset users if no data exists
    }
    notifyListeners();
  }


  Future<void> changeUserRole(String uid, String newRole) async {
    try {
      await _dbRef.child('users').child(uid).update({'role': newRole});
      // Re-fetch users if needed to keep the UI updated
      await fetchAllUsers();
    } catch (e) {
      print('Error changing user role: $e');
    }
  }

  Future<void> setUserInactive(String uid) async {
    try {
      await _dbRef.child('users').child(uid).update({'active': false});
      // Re-fetch users if needed to keep the UI updated

      await fetchAllUsers();
    } catch (e) {
      print('Error setting user inactive: $e');
    }
  }

  Future<void> setUserActive(String uid) async {
    try {
      await _dbRef.child('users').child(uid).update({'active': true});
      // Re-fetch users if needed to keep the UI updated
      await fetchAllUsers();
    } catch (e) {
      print('Error setting user active: $e');
    }
  }


}
