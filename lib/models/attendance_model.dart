import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String attendanceId;
  final String employeeId;
  final String employeeName;
  final String departmentName;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String remarks;
  final DateTime createdAt;

  const AttendanceModel({
    required this.id,
    required this.attendanceId,
    required this.employeeId,
    this.employeeName = '',
    this.departmentName = '',
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.remarks = '',
    required this.createdAt,
  });

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  Duration? get workDuration {
    if (checkInTime == null || checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime!);
  }

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceModel(
      id: id,
      attendanceId: map['attendanceId'] as String? ?? id,
      employeeId: map['employeeId'] as String? ?? '',
      employeeName: map['employeeName'] as String? ?? '',
      departmentName: map['departmentName'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkInTime: (map['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (map['checkOutTime'] as Timestamp?)?.toDate(),
      status: map['status'] as String? ?? 'Present',
      remarks: map['remarks'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AttendanceModel.fromDocument(DocumentSnapshot doc) {
    return AttendanceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'departmentName': departmentName,
      'date': Timestamp.fromDate(date),
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'status': status,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? attendanceId,
    String? employeeId,
    String? employeeName,
    String? departmentName,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? remarks,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      attendanceId: attendanceId ?? this.attendanceId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      departmentName: departmentName ?? this.departmentName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
