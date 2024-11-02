class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;
  final bool isActive; // Add isActive field

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'uid': uid,
      'active': isActive, // Save isActive status as "active" in Firebase
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? 'User',
      isActive: data['active'] ?? false, // Fetch the active status
    );
  }
}
