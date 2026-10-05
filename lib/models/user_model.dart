import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String employeeId;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.employeeId,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      userId: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'employee',
      employeeId: map['employeeId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'employeeId': employeeId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    String? employeeId,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
