import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';
import '../core/constants/app_constants.dart';

class EmployeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _db.collection(AppConstants.employeesCollection);

  Stream<List<EmployeeModel>> getEmployeesStream() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EmployeeModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<EmployeeModel>> getEmployees() async {
    final snap = await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => EmployeeModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<EmployeeModel?> getEmployeeByUserId(String userId) async {
    try {
      final snap =
          await _collection.where('userId', isEqualTo: userId).limit(1).get();
      if (snap.docs.isNotEmpty) {
        return EmployeeModel.fromMap(snap.docs.first.id, snap.docs.first.data() as Map<String, dynamic>);
      }
    } catch (_) {}
    if (userId == 'demo_employee_uid') {
      return EmployeeModel(
        id: 'emp_rahul',
        employeeId: 'EMP102',
        userId: 'demo_employee_uid',
        fullName: 'Rahul Sharma',
        email: 'rahul@empmanage.com',
        phone: '+91 98765 43210',
        departmentId: 'dept_eng',
        departmentName: 'Engineering',
        designation: 'Senior Flutter Developer',
        joiningDate: DateTime(2023, 3, 1),
        salary: 85000,
        employmentType: 'Full Time',
        status: 'Active',
        address: '42 Tech Park Road, Bengaluru, India',
        gender: 'Male',
        dateOfBirth: DateTime(1995, 6, 12),
        createdAt: DateTime(2023, 3, 1),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      final snap =
          await _collection.where('employeeId', isEqualTo: employeeId).limit(1).get();
      if (snap.docs.isNotEmpty) {
        return EmployeeModel.fromMap(snap.docs.first.id, snap.docs.first.data() as Map<String, dynamic>);
      }
    } catch (_) {}
    if (employeeId == 'EMP102') {
      return getEmployeeByUserId('demo_employee_uid');
    }
    return null;
  }

  Future<EmployeeModel?> getEmployeeByDocId(String docId) async {
    final doc = await _collection.doc(docId).get();
    if (!doc.exists) return null;
    return EmployeeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<bool> employeeIdExists(String employeeId, {String? excludeDocId}) async {
    final snap =
        await _collection.where('employeeId', isEqualTo: employeeId).get();
    if (snap.docs.isEmpty) return false;
    if (excludeDocId != null) {
      return snap.docs.any((d) => d.id != excludeDocId);
    }
    return true;
  }

  Future<bool> emailExists(String email, {String? excludeDocId}) async {
    final snap = await _collection.where('email', isEqualTo: email).get();
    if (snap.docs.isEmpty) return false;
    if (excludeDocId != null) {
      return snap.docs.any((d) => d.id != excludeDocId);
    }
    return true;
  }

  Future<String> addEmployee(EmployeeModel employee) async {
    final ref = await _collection.add(employee.toMap());
    return ref.id;
  }

  Future<void> updateEmployee(String docId, EmployeeModel employee) async {
    final data = employee.toMap();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _collection.doc(docId).update(data);
  }

  Future<void> updateEmployeeField(
      String docId, Map<String, dynamic> fields) async {
    fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _collection.doc(docId).update(fields);
  }

  Future<void> deleteEmployee(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<List<EmployeeModel>> searchEmployees(String query) async {
    final all = await getEmployees();
    final q = query.toLowerCase().trim();
    return all.where((e) {
      return e.fullName.toLowerCase().contains(q) ||
          e.employeeId.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.departmentName.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<EmployeeModel>> getEmployeesByDepartment(String departmentId) async {
    final snap =
        await _collection.where('departmentId', isEqualTo: departmentId).get();
    return snap.docs
        .map((d) => EmployeeModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getEmployeeStats() async {
    final employees = await getEmployees();
    return {
      'total': employees.length,
      'active': employees.where((e) => e.status == 'Active').length,
      'inactive': employees.where((e) => e.status == 'Inactive').length,
      'onLeave': employees.where((e) => e.status == 'On Leave').length,
      'resigned': employees.where((e) => e.status == 'Resigned').length,
    };
  }
}
