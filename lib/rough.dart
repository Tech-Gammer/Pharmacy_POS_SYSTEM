// class UserProvider with ChangeNotifier {
//   // Other properties and methods...
//
//   Future<void> setUserActive(String uid) async {
//     // Assuming you're using Firebase
//     await FirebaseFirestore.instance.collection('users').doc(uid).update({
//       'isActive': true,
//     });
//     // Update local list of users and notify listeners
//     final userIndex = _users.indexWhere((user) => user.uid == uid);
//     if (userIndex != -1) {
//       _users[userIndex] = UserModel(
//         uid: _users[userIndex].uid,
//         name: _users[userIndex].name,
//         email: _users[userIndex].email,
//         phone: _users[userIndex].phone,
//         password: _users[userIndex].password,
//         role: _users[userIndex].role,
//         isActive: true,
//       );
//       notifyListeners();
//     }
//   }
//
//   Future<void> setUserInactive(String uid) async {
//     await FirebaseFirestore.instance.collection('users').doc(uid).update({
//       'isActive': false,
//     });
//     final userIndex = _users.indexWhere((user) => user.uid == uid);
//     if (userIndex != -1) {
//       _users[userIndex] = UserModel(
//         uid: _users[userIndex].uid,
//         name: _users[userIndex].name,
//         email: _users[userIndex].email,
//         phone: _users[userIndex].phone,
//         password: _users[userIndex].password,
//         role: _users[userIndex].role,
//         isActive: false,
//       );
//       notifyListeners();
//     }
//   }
// }
