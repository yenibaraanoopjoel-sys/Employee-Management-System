class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String employeeList = '/admin/employees';
  static const String addEmployee = '/admin/employees/add';
  static const String editEmployee = '/admin/employees/edit';
  static const String employeeDetails = '/admin/employees/details';
  static const String departmentList = '/admin/departments';
  static const String addDepartment = '/admin/departments/add';
  static const String editDepartment = '/admin/departments/edit';
  static const String attendanceManagement = '/admin/attendance';

  // Employee
  static const String employeeDashboard = '/employee/dashboard';
  static const String employeeProfile = '/employee/profile';
  static const String employeeAttendance = '/employee/attendance';
}
