import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../Models/usermodel.dart';

class UserProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

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
}
