import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';
import '../../services/attendance_service.dart';
import '../../models/employee_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/employee_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../admin/employees/employee_details_screen.dart';
import '../admin/employees/edit_employee_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final _authService = AuthService();

  final List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.dashboard_rounded),
    _NavItem('Employees', Icons.people_rounded),
    _NavItem('Departments', Icons.corporate_fare_rounded),
    _NavItem('Attendance', Icons.schedule_rounded),
    _NavItem('Profile', Icons.person_rounded),
  ];

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
      appBar: _buildAppBar(),
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _navItems
            .map((n) => NavigationDestination(icon: Icon(n.icon), label: n.label))
            .toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_navItems[_selectedIndex].label),
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: _confirmLogout,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: AppColors.primary,
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildSidebarHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (_, i) => _buildNavTile(i),
            ),
          ),
          const Divider(color: Colors.white24),
          _buildLogoutTile(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Admin Panel',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile(int index) {
    final item = _navItems[index];
    final selected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(item.icon,
            color: selected ? Colors.white : Colors.white60, size: 20),
        title: Text(
          item.label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
        title: const Text('Logout',
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        onTap: _confirmLogout,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardTab();
      case 1:
        return _EmployeesTab(key: const ValueKey('employees'));
      case 2:
        return _DepartmentsTab(key: const ValueKey('departments'));
      case 3:
        return _AttendanceTab(key: const ValueKey('attendance'));
      case 4:
        return _AdminProfileTab(key: const ValueKey('profile'));
      default:
        return const _DashboardTab();
    }
  }

  Future<void> _confirmLogout() async {
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

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

// ─────────────────────────── DASHBOARD TAB ────────────────────────────────
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final _empService = EmployeeService();
  final _deptService = DepartmentService();
  final _attService = AttendanceService();
  bool _loading = true;
  Map<String, int> _empStats = {};
  int _deptCount = 0;
  int _presentToday = 0;
  List<EmployeeModel> _recentEmployees = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _empService.getEmployeeStats(),
        _deptService.getDepartments(),
        _attService.getTodayAllAttendance(),
        _empService.getEmployees(),
      ]);
      if (!mounted) return;
      setState(() {
        _empStats = results[0] as Map<String, int>;
        _deptCount = (results[1] as List).length;
        _presentToday = (results[2] as List).length;
        final all = results[3] as List<EmployeeModel>;
        _recentEmployees = all.take(5).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget(message: 'Loading dashboard...');
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 28),
            _buildRecentEmployees(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                'Welcome back, Admin! Here\'s what\'s happening.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final cards = [
      StatCard(
        title: AppStrings.totalEmployees,
        value: '${_empStats['total'] ?? 0}',
        icon: Icons.people_rounded,
        color: AppColors.primary,
        gradient: AppColors.primaryGradient,
      ),
      StatCard(
        title: AppStrings.activeEmployees,
        value: '${_empStats['active'] ?? 0}',
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        gradient: AppColors.successGradient,
      ),
      StatCard(
        title: AppStrings.presentToday,
        value: '$_presentToday',
        icon: Icons.today_rounded,
        color: AppColors.secondary,
        gradient: AppColors.secondaryGradient,
      ),
      StatCard(
        title: AppStrings.totalDepartments,
        value: '$_deptCount',
        icon: Icons.corporate_fare_rounded,
        color: AppColors.warning,
        gradient: AppColors.warningGradient,
      ),
      StatCard(
        title: AppStrings.inactiveEmployees,
        value: '${_empStats['inactive'] ?? 0}',
        icon: Icons.pause_circle_rounded,
        color: AppColors.textSecondary,
      ),
      StatCard(
        title: AppStrings.onLeave,
        value: '${_empStats['onLeave'] ?? 0}',
        icon: Icons.beach_access_rounded,
        color: AppColors.info,
      ),
    ];

    final crossAxisCount = AppHelpers.isWideScreen(context) ? 3 : 2;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: cards,
    );
  }

  Widget _buildRecentEmployees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.recentEmployees,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (_recentEmployees.isEmpty)
          const Center(child: Text('No employees yet'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentEmployees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => EmployeeCard(
              employee: _recentEmployees[i],
              showActions: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EmployeeDetailsScreen(employee: _recentEmployees[i]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────── EMPLOYEES TAB ────────────────────────────────
class _EmployeesTab extends StatefulWidget {
  const _EmployeesTab({super.key});

  @override
  State<_EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends State<_EmployeesTab> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const _EmployeeListPage(),
        );
      },
    );
  }
}

class _EmployeeListPage extends StatefulWidget {
  const _EmployeeListPage();

  @override
  State<_EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<_EmployeeListPage> {
  final _empService = EmployeeService();
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filterStatus = '';
  String _filterType = '';
  bool _loading = false;
  List<EmployeeModel> _employees = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _employees = await _empService.getEmployees();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<EmployeeModel> get _filtered {
    var list = _employees;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((e) =>
              e.fullName.toLowerCase().contains(q) ||
              e.employeeId.toLowerCase().contains(q) ||
              e.email.toLowerCase().contains(q) ||
              e.departmentName.toLowerCase().contains(q))
          .toList();
    }
    if (_filterStatus.isNotEmpty) {
      list = list.where((e) => e.status == _filterStatus).toList();
    }
    if (_filterType.isNotEmpty) {
      list = list.where((e) => e.employmentType == _filterType).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: _loading
              ? const LoadingWidget()
              : _filtered.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.employees,
                    style: Theme.of(context).textTheme.headlineMedium),
                Text('${_employees.length} total employees',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                  context, AppRoutes.addEmployee);
              if (result == true) _load();
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppStrings.searchEmployees,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<Map<String, String>>(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded),
                if (_filterStatus.isNotEmpty || _filterType.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onSelected: (val) => setState(() {
              _filterStatus = val['status'] ?? _filterStatus;
              _filterType = val['type'] ?? _filterType;
            }),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: {'status': '', 'type': ''},
                  child: Text('Clear Filters')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  enabled: false,
                  child: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.w700))),
              ...['Active', 'Inactive', 'On Leave', 'Resigned'].map(
                (s) => PopupMenuItem(
                  value: {'status': s, 'type': _filterType},
                  child: Row(children: [
                    if (_filterStatus == s)
                      const Icon(Icons.check, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(s),
                  ]),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(AppStrings.noEmployeesFound,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(AppStrings.noEmployeesSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final emp = _filtered[i];
        return EmployeeCard(
          employee: emp,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EmployeeDetailsScreen(employee: emp)),
            );
            if (result == true) _load();
          },
          onEdit: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditEmployeeScreen(employee: emp)),
            );
            if (result == true) _load();
          },
          onDelete: () => _deleteEmployee(emp),
        );
      },
    );
  }

  Future<void> _deleteEmployee(EmployeeModel emp) async {
    final ok = await AppHelpers.showConfirmDialog(
      context,
      title: AppStrings.deleteEmployee,
      message: AppStrings.deleteEmployeeConfirm,
    );
    if (ok == true) {
      try {
        await _empService.deleteEmployee(emp.id);
        if (!mounted) return;
        AppHelpers.showSnackBar(context, 'Employee deleted successfully.',
            isSuccess: true);
        _load();
      } catch (e) {
        if (!mounted) return;
        AppHelpers.showSnackBar(context, AppStrings.genericError, isError: true);
      }
    }
  }
}

// ─────────────────────────── DEPARTMENTS TAB ──────────────────────────────
class _DepartmentsTab extends StatefulWidget {
  const _DepartmentsTab({super.key});

  @override
  State<_DepartmentsTab> createState() => _DepartmentsTabState();
}

class _DepartmentsTabState extends State<_DepartmentsTab> {
  final _deptService = DepartmentService();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _DeptListPage(),
      ),
    );
  }
}

class _DeptListPage extends StatefulWidget {
  const _DeptListPage();
  @override
  State<_DeptListPage> createState() => _DeptListPageState();
}

class _DeptListPageState extends State<_DeptListPage> {
  final _deptService = DepartmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(AppStrings.departments,
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addDepartment,
                  ).then((_) => setState(() {})),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Department'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _deptService.getDepartmentsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                final depts = snap.data ?? [];
                if (depts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.corporate_fare_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(AppStrings.noDepartmentsFound,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _deptService.seedDefaultDepartments(),
                          child: const Text('Seed Default Departments'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: depts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final d = depts[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.business_rounded,
                              color: Colors.white, size: 24),
                        ),
                        title: Text(d.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d.description.isNotEmpty)
                              Text(d.description,
                                  style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '${d.employeeCount} employees',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.editDepartment,
                                arguments: d,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error),
                              onPressed: () => _deleteDept(d.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDept(String id) async {
    final ok = await AppHelpers.showConfirmDialog(
      context,
      title: AppStrings.deleteDepartment,
      message: AppStrings.deleteDepartmentConfirm,
    );
    if (ok == true) {
      await _deptService.deleteDepartment(id);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Department deleted.', isSuccess: true);
    }
  }
}

// ─────────────────────────── ATTENDANCE TAB ───────────────────────────────
class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab({super.key});
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) =>
            const _AttendancePage(),
      ),
    );
  }
}

class _AttendancePage extends StatefulWidget {
  const _AttendancePage();
  @override
  State<_AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<_AttendancePage> {
  final _attService = AttendanceService();
  bool _loading = true;
  List _records = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _records = await _attService.getAllAttendance(date: _selectedDate);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _records.where((r) => r.status == 'Present').length;
    final lateCount = _records.where((r) => r.status == 'Late').length;
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.attendanceManagement,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statChip('Present', presentCount, AppColors.success),
                  const SizedBox(width: 8),
                  _statChip('Late', lateCount, AppColors.warning),
                  const SizedBox(width: 8),
                  _statChip('Total', _records.length, AppColors.primary),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(_selectedDate == null
                        ? 'Filter Date'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                  if (_selectedDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedDate = null);
                        _load();
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const LoadingWidget()
              : _records.isEmpty
                  ? const Center(
                      child: Text(AppStrings.noAttendanceFound))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final r = _records[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppHelpers.getAttendanceStatusColor(
                                        r.status)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _statusIcon(r.status),
                                color: AppHelpers.getAttendanceStatusColor(
                                    r.status),
                                size: 20,
                              ),
                            ),
                            title: Text(r.employeeName.isNotEmpty
                                ? r.employeeName
                                : r.employeeId),
                            subtitle: Text(
                              '${r.departmentName} • ${r.date.day}/${r.date.month}/${r.date.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _statusBadge(r.status),
                                if (r.checkInTime != null)
                                  Text(
                                    'In: ${r.checkInTime!.hour.toString().padLeft(2, '0')}:${r.checkInTime!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = AppHelpers.getAttendanceStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      case 'late':
        return Icons.access_time_rounded;
      case 'leave':
        return Icons.beach_access_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      _load();
    }
  }
}

// ─────────────────────────── ADMIN PROFILE TAB ────────────────────────────
class _AdminProfileTab extends StatefulWidget {
  const _AdminProfileTab({super.key});
  @override
  State<_AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<_AdminProfileTab> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.getCurrentUserModel(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        final user = snap.data;
        if (user == null) return const Center(child: Text('No profile found'));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          AppHelpers.getInitials(user.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(user.email,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Administrator',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _infoCard('Account Information', [
                _infoRow(Icons.person_rounded, 'Name', user.name),
                _infoRow(Icons.email_rounded, 'Email', user.email),
                _infoRow(Icons.security_rounded, 'Role', 'Admin'),
                _infoRow(Icons.badge_rounded, 'User ID', user.userId),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
