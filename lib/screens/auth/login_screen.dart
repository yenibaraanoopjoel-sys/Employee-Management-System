import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _quickLogin(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _authService.signInDemo(role);
      if (!mounted) return;
      if (user.isAdmin) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.employeeDashboard);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailCtrl.text,
        _passwordCtrl.text,
      );
      if (!mounted) return;
      if (user.isAdmin) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.employeeDashboard);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _parseError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String error) {
    if (error.contains('CONFIGURATION_NOT_FOUND') ||
        error.contains('configuration-not-found') ||
        error.contains('Firebase Auth is not enabled')) {
      return 'Firebase Authentication is not activated yet in console. Click Quick Login below to enter immediately.';
    }
    if (error.contains('user-not-found') ||
        error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return AppStrings.invalidCredentials;
    }
    if (error.contains('network')) return AppStrings.networkError;
    if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    }
    if (error.contains('User profile not found')) {
      return 'Your account profile is not set up. Please contact admin.';
    }
    final clean = error.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll('Exception:', '').trim();
    return clean.isNotEmpty ? clean : AppStrings.genericError;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    return Scaffold(
      body: Row(
        children: [
          if (isWide) _buildLeftPanel(),
          Expanded(child: _buildLoginForm()),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 420,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            ..._buildFeatureItems(),
            const Spacer(flex: 2),
            Text(
              '© 2026 EmpManage. All rights reserved.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = [
      ('Manage Employees', Icons.manage_accounts_rounded),
      ('Track Attendance', Icons.schedule_rounded),
      ('Department Control', Icons.corporate_fare_rounded),
      ('Role-Based Access', Icons.security_rounded),
    ];
    return features
        .map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(f.$2, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildLoginForm() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.elevatedShadow,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome Back 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.loginSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            CustomTextField(
                              label: AppStrings.email,
                              hint: 'Enter your email',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: AppStrings.password,
                              hint: 'Enter your password',
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              validator: Validators.password,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPassword,
                                child: const Text(AppStrings.forgotPassword),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppColors.error, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            CustomButton(
                              label: AppStrings.login,
                              onPressed: _login,
                              isLoading: _isLoading,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDemoCredentials(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 18, color: AppColors.info),
              const SizedBox(width: 6),
              Text(
                'Demo Accounts (Instant Access)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _demoRow('Admin', 'admin@empmanage.com', 'Admin@123', () => _quickLogin('admin')),
          const SizedBox(height: 8),
          _demoRow('Employee', 'rahul@empmanage.com', 'Emp@12345', () => _quickLogin('employee')),
        ],
      ),
    );
  }

  Widget _demoRow(String role, String email, String pass, VoidCallback onQuickLogin) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'Admin' ? AppColors.primaryLight : AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: role == 'Admin' ? AppColors.primary : AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                _emailCtrl.text = email;
                _passwordCtrl.text = pass;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(email, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(pass, style: const TextStyle(fontSize: 11, color: AppColors.textHint, fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onQuickLogin,
            icon: const Icon(Icons.login_rounded, size: 14),
            label: const Text('Login', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 32),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _authService.sendPasswordResetEmail(ctrl.text);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (_) {}
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
