class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.uid,


  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'uid':uid
    };
  }
}
