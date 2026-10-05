import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/employees/add_employee_screen.dart';
import 'screens/admin/employees/edit_employee_screen.dart';
import 'screens/admin/employees/employee_details_screen.dart';
import 'screens/admin/departments/add_department_screen.dart';
import 'screens/admin/departments/edit_department_screen.dart';
import 'screens/employee/employee_dashboard.dart';
import 'models/employee_model.dart';
import 'models/department_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EmployeeManagementApp());
}

class EmployeeManagementApp extends StatelessWidget {
  const EmployeeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmpManage — Employee Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return _fade(const SplashScreen());

          case AppRoutes.login:
            return _fade(const LoginScreen());

          // ── Admin routes ────────────────────────────────────────────────
          case AppRoutes.adminDashboard:
            return _fade(const AdminDashboard());

          case AppRoutes.addEmployee:
            return _slide(const AddEmployeeScreen());

          case AppRoutes.editEmployee:
            final emp = settings.arguments as EmployeeModel;
            return _slide(EditEmployeeScreen(employee: emp));

          case AppRoutes.employeeDetails:
            final emp = settings.arguments as EmployeeModel;
            return _slide(EmployeeDetailsScreen(employee: emp));

          case AppRoutes.addDepartment:
            return _slide(const AddDepartmentScreen());

          case AppRoutes.editDepartment:
            final dept = settings.arguments as DepartmentModel;
            return _slide(EditDepartmentScreen(department: dept));

          // ── Employee routes ─────────────────────────────────────────────
          case AppRoutes.employeeDashboard:
            return _fade(const EmployeeDashboard());

          default:
            return _fade(const SplashScreen());
        }
      },
    );
  }

  PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}
