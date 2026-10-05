import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/employee_service.dart';
import '../../services/attendance_service.dart';
import '../../models/employee_model.dart';
import '../../models/attendance_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/date_utils.dart';
import '../../routes/app_routes.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final isWide = AppHelpers.isWideScreen(context);
    return Scaffold(
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        _buildSidebar(),
        const VerticalDivider(width: 1),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.schedule_rounded), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final tabs = [
      ('Dashboard', Icons.dashboard_rounded),
      ('Attendance', Icons.schedule_rounded),
      ('Profile', Icons.person_rounded),
    ];
    return Container(
      width: 220,
      color: AppColors.primary,
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildSidebarHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: tabs.length,
              itemBuilder: (_, i) {
                final selected = _selectedIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(tabs[i].$2,
                        color: selected ? Colors.white : Colors.white60, size: 20),
                    title: Text(tabs[i].$1,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14,
                        )),
                    onTap: () => setState(() => _selectedIndex = i),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              onTap: _logout,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return FutureBuilder(
      future: _authService.getCurrentUserModel(),
      builder: (context, snap) {
        final name = snap.data?.name ?? 'Employee';
        return Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  AppHelpers.getInitials(name),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(name,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Employee', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _HomeTab(onNavigate: (i) => setState(() => _selectedIndex = i));
      case 1:
        return const _EmployeeAttendanceContent();
      case 2:
        return const _EmployeeProfileContent();
      default:
        return _HomeTab(onNavigate: (i) => setState(() => _selectedIndex = i));
    }
  }

  Future<void> _logout() async {
    final ok = await AppHelpers.showConfirmDialog(
      context,
      title: AppStrings.logout,
      message: AppStrings.logoutConfirm,
      confirmText: 'Logout',
      isDangerous: false,
    );
    if (ok == true && mounted) {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }
}

// ──────────────── HOME TAB ──────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final void Function(int) onNavigate;
  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _authService = AuthService();
  final _empService = EmployeeService();
  final _attService = AttendanceService();
  EmployeeModel? _employee;
  AttendanceModel? _todayAtt;
  bool _loading = true;
  bool _checkingIn = false;
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await _authService.getCurrentUserModel();
      if (user != null) {
        final emp = await _empService.getEmployeeByUserId(user.userId);
        AttendanceModel? att;
        if (emp != null) {
          att = await _attService.getTodayAttendance(emp.employeeId);
        }
        if (mounted) {
          setState(() {
            _employee = emp;
            _todayAtt = att;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _checkIn() async {
    if (_employee == null) return;
    setState(() => _checkingIn = true);
    try {
      final att = await _attService.checkIn(
        employeeId: _employee!.employeeId,
        employeeName: _employee!.fullName,
        departmentName: _employee!.departmentName,
      );
      if (mounted) {
        setState(() => _todayAtt = att);
        AppHelpers.showSnackBar(context, AppStrings.checkInSuccess, isSuccess: true);
      }
    } catch (e) {
      if (mounted) AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  Future<void> _checkOut() async {
    if (_employee == null) return;
    setState(() => _checkingOut = true);
    try {
      final att = await _attService.checkOut(_employee!.employeeId);
      if (mounted) {
        setState(() => _todayAtt = att);
        AppHelpers.showSnackBar(context, AppStrings.checkOutSuccess, isSuccess: true);
      }
    } catch (e) {
      if (mounted) AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget(message: 'Loading dashboard...');
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildEmployeeInfo(),
            const SizedBox(height: 20),
            _buildAttendanceCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting! 👋',
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  _employee?.fullName ?? 'Employee',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _employee?.designation ?? '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                AppHelpers.getInitials(_employee?.fullName ?? '?'),
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    if (_employee == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Information', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 20),
          _infoRow(Icons.badge_rounded, 'Employee ID', _employee!.employeeId),
          _infoRow(Icons.corporate_fare_rounded, 'Department', _employee!.departmentName),
          _infoRow(Icons.work_rounded, 'Employment Type', _employee!.employmentType),
          _infoRow(Icons.circle, 'Status', _employee!.status, isStatus: true),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isStatus = false}) {
    final color = isStatus ? AppHelpers.getStatusColor(value) : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                isStatus
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(value,
                            style: TextStyle(
                                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      )
                    : Text(value,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final hasCheckedIn = _todayAtt?.hasCheckedIn ?? false;
    final hasCheckedOut = _todayAtt?.hasCheckedOut ?? false;
    final statusColor = _todayAtt != null
        ? AppHelpers.getAttendanceStatusColor(_todayAtt!.status)
        : AppColors.textHint;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Today's Attendance", style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(
                AppDateUtils.formatDate(DateTime.now()),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 20),
          if (_todayAtt != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_todayAtt!.status,
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _timeChip('Check In', _todayAtt!.checkInTime, AppColors.success),
                const SizedBox(width: 12),
                _timeChip('Check Out', _todayAtt!.checkOutTime, AppColors.secondary),
              ],
            ),
          ] else ...[
            const Text(
              'You have not checked in today.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (hasCheckedIn || _checkingIn) ? null : _checkIn,
                  icon: _checkingIn
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.login_rounded),
                  label: const Text('Check In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    disabledBackgroundColor: AppColors.success.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (!hasCheckedIn || hasCheckedOut || _checkingOut) ? null : _checkOut,
                  icon: _checkingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.logout_rounded),
                  label: const Text('Check Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String label, DateTime? time, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              time != null ? AppDateUtils.formatTime(time) : '--:--',
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            _quickActionCard('View Attendance', Icons.calendar_month_rounded,
                AppColors.secondary, () => widget.onNavigate(1)),
            const SizedBox(width: 12),
            _quickActionCard('My Profile', Icons.person_rounded,
                AppColors.primary, () => widget.onNavigate(2)),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────── ATTENDANCE CONTENT ─────────────────────────────────
class _EmployeeAttendanceContent extends StatefulWidget {
  const _EmployeeAttendanceContent();

  @override
  State<_EmployeeAttendanceContent> createState() => _EmployeeAttendanceContentState();
}

class _EmployeeAttendanceContentState extends State<_EmployeeAttendanceContent> {
  final _authService = AuthService();
  final _empService = EmployeeService();
  final _attService = AttendanceService();
  EmployeeModel? _employee;
  List<AttendanceModel> _history = [];
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await _authService.getCurrentUserModel();
      if (user != null) {
        final emp = await _empService.getEmployeeByUserId(user.userId);
        if (emp != null) {
          final history = await _attService.getAttendanceHistory(emp.employeeId);
          final stats = await _attService.getMonthlyStats(emp.employeeId, DateTime.now());
          if (mounted) setState(() { _employee = emp; _history = history; _stats = stats; });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget();
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Monthly summary — ${AppDateUtils.formatMonthYear(DateTime.now())}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            _buildMonthlyStats(),
            const SizedBox(height: 20),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final present = _stats['present'] ?? 0;
    final late = _stats['late'] ?? 0;
    final absent = _stats['absent'] ?? 0;
    final leave = _stats['leave'] ?? 0;
    final total = present + late + absent + leave;
    final percentage = total > 0 ? ((present + late) / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Present', present, Colors.white),
              _statItem('Late', late, Colors.amber[200]!),
              _statItem('Absent', absent, Colors.red[200]!),
              _statItem('Leave', leave, Colors.blue[200]!),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.percent_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('$percentage% Attendance Rate',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent History', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          const Center(child: Text(AppStrings.noAttendanceFound,
              style: TextStyle(color: AppColors.textSecondary)))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = _history[i];
              final color = AppHelpers.getAttendanceStatusColor(r.status);
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.cardShadow,
                ),
                child: ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${r.date.day}',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                  title: Text(AppDateUtils.formatDate(r.date),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Row(
                    children: [
                      if (r.checkInTime != null)
                        Text('In: ${AppDateUtils.formatTime(r.checkInTime)}  ',
                            style: const TextStyle(fontSize: 12, color: AppColors.success)),
                      if (r.checkOutTime != null)
                        Text('Out: ${AppDateUtils.formatTime(r.checkOutTime)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(r.status,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ────────────────── PROFILE CONTENT ─────────────────────────────────────
class _EmployeeProfileContent extends StatefulWidget {
  const _EmployeeProfileContent();

  @override
  State<_EmployeeProfileContent> createState() => _EmployeeProfileContentState();
}

class _EmployeeProfileContentState extends State<_EmployeeProfileContent> {
  final _authService = AuthService();
  final _empService = EmployeeService();
  final _storageService = EmployeeService();
  EmployeeModel? _employee;
  bool _loading = true;
  bool _editing = false;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await _authService.getCurrentUserModel();
      if (user != null) {
        final emp = await _empService.getEmployeeByUserId(user.userId);
        if (emp != null && mounted) {
          setState(() {
            _employee = emp;
            _phoneCtrl.text = emp.phone;
            _addressCtrl.text = emp.address;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_employee == null) return;
    setState(() => _loading = true);
    try {
      await _empService.updateEmployeeField(_employee!.id, {
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
      if (!mounted) return;
      AppHelpers.showSnackBar(context, AppStrings.profileUpdated, isSuccess: true);
      setState(() => _editing = false);
      _load();
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, AppStrings.genericError, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget();
    if (_employee == null) return const Center(child: Text('Profile not found'));
    final e = _employee!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(e),
          const SizedBox(height: 20),
          _buildEditableSection(e),
          const SizedBox(height: 16),
          _buildReadOnlySection(e),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(EmployeeModel e) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(AppHelpers.getInitials(e.fullName),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Text(e.fullName,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(e.designation,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          const SizedBox(height: 4),
          Text(e.departmentName,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEditableSection(EmployeeModel e) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Editable Information',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _editing = !_editing),
                icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded, size: 16),
                label: Text(_editing ? 'Cancel' : 'Edit'),
              ),
            ],
          ),
          const Divider(height: 20),
          if (_editing) ...[
            _infoLabel('Phone Number'),
            TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_rounded))),
            const SizedBox(height: 16),
            _infoLabel('Address'),
            TextField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_rounded))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _save, child: const Text('Save Changes')),
            ),
          ] else ...[
            _profileRow(Icons.phone_rounded, 'Phone', e.phone),
            _profileRow(Icons.email_rounded, 'Email', e.email),
            _profileRow(Icons.location_on_rounded, 'Address',
                e.address.isEmpty ? 'Not provided' : e.address),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlySection(EmployeeModel e) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employment Details', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 20),
          _profileRow(Icons.badge_rounded, 'Employee ID', e.employeeId),
          _profileRow(Icons.corporate_fare_rounded, 'Department', e.departmentName),
          _profileRow(Icons.calendar_today_rounded, 'Joining Date',
              AppDateUtils.formatDate(e.joiningDate)),
          _profileRow(Icons.work_history_rounded, 'Employment Type', e.employmentType),
          _profileRow(Icons.attach_money_rounded, 'Salary',
              '₹${e.salary.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }

  Widget _infoLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
}
