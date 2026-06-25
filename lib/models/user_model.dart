class UserModel {
  final String id;
  final String name;
  final String role;
  final String contact;
  final String status; // 'pending', 'approved', 'rejected', 'active'

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.contact,
    this.status = 'active',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      contact: map['contact'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}
