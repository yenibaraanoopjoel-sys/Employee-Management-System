import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id;
  final String departmentId;
  final String name;
  final String description;
  final String manager;
  final int employeeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepartmentModel({
    required this.id,
    required this.departmentId,
    required this.name,
    this.description = '',
    this.manager = '',
    this.employeeCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    return DepartmentModel(
      id: id,
      departmentId: map['departmentId'] as String? ?? id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      manager: map['manager'] as String? ?? '',
      employeeCount: map['employeeCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory DepartmentModel.fromDocument(DocumentSnapshot doc) {
    return DepartmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'departmentId': departmentId,
      'name': name,
      'description': description,
      'manager': manager,
      'employeeCount': employeeCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DepartmentModel copyWith({
    String? id,
    String? departmentId,
    String? name,
    String? description,
    String? manager,
    int? employeeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      description: description ?? this.description,
      manager: manager ?? this.manager,
      employeeCount: employeeCount ?? this.employeeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
