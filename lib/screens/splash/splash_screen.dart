import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2000), _navigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final user = _authService.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }
    final userModel = await _authService.getCurrentUserModel();
    if (!mounted) return;
    if (userModel == null) {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }
    if (userModel.isAdmin) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.employeeDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.appTagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
