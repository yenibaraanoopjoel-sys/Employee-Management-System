class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'EmpManage';
  static const String appTagline = 'Smart Employee Management';

  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginSubtitle = 'Sign in to your account';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalEmployees = 'Total Employees';
  static const String activeEmployees = 'Active Employees';
  static const String inactiveEmployees = 'Inactive Employees';
  static const String onLeave = 'On Leave';
  static const String totalDepartments = 'Total Departments';
  static const String presentToday = 'Present Today';
  static const String absentToday = 'Absent Today';
  static const String recentEmployees = 'Recent Employees';
  static const String todayAttendance = "Today's Attendance";

  // Employees
  static const String employees = 'Employees';
  static const String employeeList = 'Employee List';
  static const String addEmployee = 'Add Employee';
  static const String editEmployee = 'Edit Employee';
  static const String employeeDetails = 'Employee Details';
  static const String deleteEmployee = 'Delete Employee';
  static const String deleteEmployeeConfirm =
      'Are you sure you want to permanently delete this employee? This action cannot be undone.';
  static const String noEmployeesFound = 'No employees found';
  static const String noEmployeesSubtitle = 'Try adding a new employee or adjusting your search.';
  static const String searchEmployees = 'Search by name, ID, email...';

  // Employee fields
  static const String fullName = 'Full Name';
  static const String employeeId = 'Employee ID';
  static const String phone = 'Phone';
  static const String department = 'Department';
  static const String designation = 'Designation';
  static const String joiningDate = 'Joining Date';
  static const String salary = 'Salary';
  static const String employmentType = 'Employment Type';
  static const String status = 'Status';
  static const String address = 'Address';
  static const String dateOfBirth = 'Date of Birth';
  static const String gender = 'Gender';
  static const String profileImage = 'Profile Image';

  // Departments
  static const String departments = 'Departments';
  static const String addDepartment = 'Add Department';
  static const String editDepartment = 'Edit Department';
  static const String deleteDepartment = 'Delete Department';
  static const String deleteDepartmentConfirm =
      'Are you sure you want to delete this department?';
  static const String noDepartmentsFound = 'No departments found';
  static const String noDepartmentsSubtitle = 'Try adding a new department.';
  static const String departmentName = 'Department Name';
  static const String description = 'Description';
  static const String manager = 'Manager';
  static const String employeeCount = 'Employee Count';

  // Attendance
  static const String attendance = 'Attendance';
  static const String checkIn = 'Check In';
  static const String checkOut = 'Check Out';
  static const String checkInTime = 'Check-In Time';
  static const String checkOutTime = 'Check-Out Time';
  static const String attendanceHistory = 'Attendance History';
  static const String attendanceManagement = 'Attendance Management';
  static const String todayStatus = "Today's Status";
  static const String noAttendanceFound = 'No attendance records found';
  static const String alreadyCheckedIn = 'You have already checked in today.';
  static const String alreadyCheckedOut = 'You have already checked out today.';
  static const String mustCheckInFirst = 'Please check in first.';
  static const String checkInSuccess = 'Checked in successfully!';
  static const String checkOutSuccess = 'Checked out successfully!';

  // Attendance Stats
  static const String present = 'Present';
  static const String absent = 'Absent';
  static const String late = 'Late';
  static const String halfDay = 'Half Day';
  static const String leave = 'Leave';

  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String updateProfile = 'Update Profile';
  static const String profileUpdated = 'Profile updated successfully!';

  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String reset = 'Reset';
  static const String refresh = 'Refresh';
  static const String confirm = 'Confirm';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String view = 'View';
  static const String all = 'All';
  static const String select = 'Select';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String permissionDenied = 'You do not have permission to perform this action.';
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidSalary = 'Please enter a valid salary amount';
  static const String employeeIdExists = 'This Employee ID already exists';
  static const String emailExists = 'This email already exists';

  // Employment Types
  static const List<String> employmentTypes = [
    'Full Time',
    'Part Time',
    'Contract',
    'Intern',
  ];

  // Employee Statuses
  static const List<String> employeeStatuses = [
    'Active',
    'Inactive',
    'On Leave',
    'Resigned',
  ];

  // Genders
  static const List<String> genders = ['Male', 'Female', 'Other'];

  // Attendance Statuses
  static const List<String> attendanceStatuses = [
    'Present',
    'Absent',
    'Late',
    'Half Day',
    'Leave',
  ];
}
