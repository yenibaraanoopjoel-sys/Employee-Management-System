import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _db.collection(AppConstants.attendanceCollection);

  /// Get today's attendance record for an employee
  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    final today = AppDateUtils.todayKey();
    final snap = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('dateKey', isEqualTo: today)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return AttendanceModel.fromMap(snap.docs.first.id, snap.docs.first.data() as Map<String, dynamic>);
  }

  /// Check in an employee
  Future<AttendanceModel> checkIn({
    required String employeeId,
    required String employeeName,
    required String departmentName,
  }) async {
    final existing = await getTodayAttendance(employeeId);
    if (existing != null) {
      throw Exception('Already checked in today.');
    }
    final now = DateTime.now();
    final today = AppDateUtils.todayKey();
    final lateThreshold = DateTime(now.year, now.month, now.day, 9, 30);
    final status = now.isAfter(lateThreshold) ? 'Late' : 'Present';

    final docRef = _collection.doc();
    final model = AttendanceModel(
      id: docRef.id,
      attendanceId: docRef.id,
      employeeId: employeeId,
      employeeName: employeeName,
      departmentName: departmentName,
      date: now,
      checkInTime: now,
      status: status,
      createdAt: now,
    );
    final data = model.toMap();
    data['dateKey'] = today;
    await docRef.set(data);
    return model;
  }

  /// Check out an employee
  Future<AttendanceModel> checkOut(String employeeId) async {
    final existing = await getTodayAttendance(employeeId);
    if (existing == null) {
      throw Exception('Please check in first.');
    }
    if (existing.hasCheckedOut) {
      throw Exception('Already checked out today.');
    }
    final now = DateTime.now();
    await _collection.doc(existing.id).update({
      'checkOutTime': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return existing.copyWith(checkOutTime: now);
  }

  /// Get attendance history for an employee
  Future<List<AttendanceModel>> getAttendanceHistory(
      String employeeId, {
      int limit = 30,
    }) async {
    final snap = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => AttendanceModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get all attendance for admin with optional filters
  Future<List<AttendanceModel>> getAllAttendance({
    String? employeeId,
    String? departmentName,
    DateTime? date,
    int limit = 50,
  }) async {
    Query query = _collection.orderBy('date', descending: true).limit(limit);
    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    if (departmentName != null && departmentName.isNotEmpty) {
      query = query.where('departmentName', isEqualTo: departmentName);
    }
    if (date != null) {
      final dateKey = AppDateUtils.dateKey(date);
      query = query.where('dateKey', isEqualTo: dateKey);
    }
    final snap = await query.get();
    return snap.docs
        .map((d) => AttendanceModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get today's attendance for all employees
  Future<List<AttendanceModel>> getTodayAllAttendance() async {
    final today = AppDateUtils.todayKey();
    final snap = await _collection.where('dateKey', isEqualTo: today).get();
    return snap.docs
        .map((d) => AttendanceModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get monthly attendance stats for an employee
  Future<Map<String, int>> getMonthlyStats(String employeeId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final snap = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final records = snap.docs
        .map((d) => AttendanceModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();

    return {
      'present': records.where((r) => r.status == 'Present').length,
      'late': records.where((r) => r.status == 'Late').length,
      'absent': records.where((r) => r.status == 'Absent').length,
      'halfDay': records.where((r) => r.status == 'Half Day').length,
      'leave': records.where((r) => r.status == 'Leave').length,
      'total': records.length,
    };
  }
}
