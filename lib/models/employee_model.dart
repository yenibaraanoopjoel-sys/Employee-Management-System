import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id; // Firestore doc ID
  final String employeeId;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String profileImage;
  final String departmentId;
  final String departmentName;
  final String designation;
  final DateTime joiningDate;
  final double salary;
  final String employmentType;
  final String status;
  final String address;
  final DateTime? dateOfBirth;
  final String gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage = '',
    required this.departmentId,
    required this.departmentName,
    required this.designation,
    required this.joiningDate,
    required this.salary,
    required this.employmentType,
    required this.status,
    this.address = '',
    this.dateOfBirth,
    this.gender = 'Male',
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromMap(String id, Map<String, dynamic> map) {
    return EmployeeModel(
      id: id,
      employeeId: map['employeeId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      profileImage: map['profileImage'] as String? ?? '',
      departmentId: map['departmentId'] as String? ?? '',
      departmentName: map['departmentName'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      joiningDate: (map['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      employmentType: map['employmentType'] as String? ?? 'Full Time',
      status: map['status'] as String? ?? 'Active',
      address: map['address'] as String? ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: map['gender'] as String? ?? 'Male',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory EmployeeModel.fromDocument(DocumentSnapshot doc) {
    return EmployeeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'designation': designation,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'salary': salary,
      'employmentType': employmentType,
      'status': status,
      'address': address,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? departmentId,
    String? departmentName,
    String? designation,
    DateTime? joiningDate,
    double? salary,
    String? employmentType,
    String? status,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      designation: designation ?? this.designation,
      joiningDate: joiningDate ?? this.joiningDate,
      salary: salary ?? this.salary,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
