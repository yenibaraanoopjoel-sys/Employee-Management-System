class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String employeesCollection = 'employees';
  static const String departmentsCollection = 'departments';
  static const String attendanceCollection = 'attendance';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';

  // Firebase Storage paths
  static const String profileImagesPath = 'profile_images';

  // Pagination
  static const int pageSize = 20;

  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String dateInputFormat = 'yyyy-MM-dd';
  static const String monthYearFormat = 'MMMM yyyy';

  // Default avatar
  static const String defaultAvatarUrl = '';

  // Animation durations
  static const int shortAnimDuration = 200;
  static const int mediumAnimDuration = 350;
  static const int longAnimDuration = 500;

  // UI
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double cardElevation = 0.0;
  static const double appBarElevation = 0.0;
  static const double spacing = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingLarge = 24.0;
  static const double spacingXL = 32.0;

  // Sidebar breakpoint (show sidebar on screens wider than this)
  static const double sidebarBreakpoint = 800.0;
}
