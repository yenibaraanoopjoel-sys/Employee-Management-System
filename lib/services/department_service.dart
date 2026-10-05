import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department_model.dart';
import '../core/constants/app_constants.dart';

class DepartmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _db.collection(AppConstants.departmentsCollection);

  Stream<List<DepartmentModel>> getDepartmentsStream() {
    return _collection.orderBy('name').snapshots().map((snap) =>
        snap.docs
            .map((d) => DepartmentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<DepartmentModel>> getDepartments() async {
    final snap = await _collection.orderBy('name').get();
    return snap.docs
        .map((d) => DepartmentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<DepartmentModel?> getDepartmentById(String docId) async {
    final doc = await _collection.doc(docId).get();
    if (!doc.exists) return null;
    return DepartmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<String> addDepartment(DepartmentModel department) async {
    final ref = await _collection.add(department.toMap());
    return ref.id;
  }

  Future<void> updateDepartment(String docId, DepartmentModel department) async {
    final data = department.toMap();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _collection.doc(docId).update(data);
  }

  Future<void> deleteDepartment(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<void> updateEmployeeCount(String docId, int count) async {
    await _collection.doc(docId).update({
      'employeeCount': count,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> seedDefaultDepartments() async {
    final snap = await _collection.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final defaults = [
      'Human Resources',
      'Software Development',
      'Finance',
      'Marketing',
      'Sales',
      'Operations',
      'Design',
    ];

    for (final name in defaults) {
      final now = DateTime.now();
      final dept = DepartmentModel(
        id: '',
        departmentId: '',
        name: name,
        description: '$name department',
        createdAt: now,
        updatedAt: now,
      );
      final ref = await _collection.add(dept.toMap());
      await ref.update({'departmentId': ref.id});
    }
  }
}
