import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department_model.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedInitialDataIfEmpty() async {
    try {
      final deptSnap = await _db.collection(AppConstants.departmentsCollection).limit(1).get();
      if (deptSnap.docs.isNotEmpty) return;

      // 1. Seed Users for demo accounts
      final adminUser = UserModel(
        userId: 'demo_admin_uid',
        name: 'Admin User',
        email: 'admin@empmanage.com',
        role: 'admin',
        employeeId: 'EMP001',
        createdAt: DateTime.now(),
      );
      final employeeUser = UserModel(
        userId: 'demo_employee_uid',
        name: 'Rahul Sharma',
        email: 'rahul@empmanage.com',
        role: 'employee',
        employeeId: 'EMP102',
        createdAt: DateTime.now(),
      );

      await _db.collection(AppConstants.usersCollection).doc(adminUser.userId).set(adminUser.toMap());
      await _db.collection(AppConstants.usersCollection).doc(employeeUser.userId).set(employeeUser.toMap());

      // 2. Seed Departments
      final depts = [
        DepartmentModel(
          id: 'dept_eng',
          departmentId: 'DEP-ENG',
          name: 'Engineering',
          description: 'Software development, infrastructure, and technical design.',
          manager: 'Priya Patel',
          employeeCount: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DepartmentModel(
          id: 'dept_hr',
          departmentId: 'DEP-HR',
          name: 'Human Resources',
          description: 'Talent recruitment, culture, and employee welfare.',
          manager: 'Amit Verma',
          employeeCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DepartmentModel(
          id: 'dept_mkt',
          departmentId: 'DEP-MKT',
          name: 'Marketing',
          description: 'Brand strategy, social media, and market growth.',
          manager: 'Sneha Reddy',
          employeeCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DepartmentModel(
          id: 'dept_fin',
          departmentId: 'DEP-FIN',
          name: 'Finance',
          description: 'Corporate budgeting, payroll, and accounting.',
          manager: 'Vikram Joshi',
          employeeCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final d in depts) {
        await _db.collection(AppConstants.departmentsCollection).doc(d.id).set(d.toMap());
      }

      // 3. Seed Employees
      final employees = [
        EmployeeModel(
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
        ),
        EmployeeModel(
          id: 'emp_priya',
          employeeId: 'EMP101',
          userId: 'usr_priya',
          fullName: 'Priya Patel',
          email: 'priya.patel@empmanage.com',
          phone: '+91 98765 43211',
          departmentId: 'dept_eng',
          departmentName: 'Engineering',
          designation: 'Lead Architect',
          joiningDate: DateTime(2022, 1, 10),
          salary: 110000,
          employmentType: 'Full Time',
          status: 'Active',
          address: '15 Silicon Boulevard, Bengaluru, India',
          gender: 'Female',
          dateOfBirth: DateTime(1992, 4, 18),
          createdAt: DateTime(2022, 1, 10),
          updatedAt: DateTime.now(),
        ),
        EmployeeModel(
          id: 'emp_amit',
          employeeId: 'EMP103',
          userId: 'usr_amit',
          fullName: 'Amit Verma',
          email: 'amit.verma@empmanage.com',
          phone: '+91 98765 43212',
          departmentId: 'dept_hr',
          departmentName: 'Human Resources',
          designation: 'HR Manager',
          joiningDate: DateTime(2023, 5, 20),
          salary: 72000,
          employmentType: 'Full Time',
          status: 'Active',
          address: '88 Cyber City, Gurugram, India',
          gender: 'Male',
          dateOfBirth: DateTime(1994, 9, 25),
          createdAt: DateTime(2023, 5, 20),
          updatedAt: DateTime.now(),
        ),
        EmployeeModel(
          id: 'emp_sneha',
          employeeId: 'EMP104',
          userId: 'usr_sneha',
          fullName: 'Sneha Reddy',
          email: 'sneha.reddy@empmanage.com',
          phone: '+91 98765 43213',
          departmentId: 'dept_mkt',
          departmentName: 'Marketing',
          designation: 'Marketing Lead',
          joiningDate: DateTime(2023, 8, 15),
          salary: 68000,
          employmentType: 'Full Time',
          status: 'Active',
          address: '24 Jubilee Hills, Hyderabad, India',
          gender: 'Female',
          dateOfBirth: DateTime(1996, 11, 5),
          createdAt: DateTime(2023, 8, 15),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final emp in employees) {
        await _db.collection(AppConstants.employeesCollection).doc(emp.id).set(emp.toMap());
      }

      // 4. Seed Attendance for Rahul Sharma for the past few days
      final now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        final d = now.subtract(Duration(days: i));
        final dateOnly = DateTime(d.year, d.month, d.day);
        final attId = 'att_EMP102_${dateOnly.millisecondsSinceEpoch}';
        final checkIn = DateTime(d.year, d.month, d.day, 9, 15);
        final checkOut = i == 0 ? null : DateTime(d.year, d.month, d.day, 18, 10);
        final att = AttendanceModel(
          id: attId,
          attendanceId: attId,
          employeeId: 'EMP102',
          employeeName: 'Rahul Sharma',
          departmentName: 'Engineering',
          date: dateOnly,
          checkInTime: checkIn,
          checkOutTime: checkOut,
          status: 'Present',
          remarks: i == 0 ? 'On time' : 'Completed 8h 55m',
          createdAt: checkIn,
        );
        await _db.collection(AppConstants.attendanceCollection).doc(attId).set(att.toMap());
      }
    } catch (_) {}
  }
}
