import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/glass_dashboard.dart';
import '../../../../../core/widgets/main_sidebar_drawer.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../widgets/admin_dashboard_calendar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<dynamic> _stats;

  @override
  void initState() {
    super.initState();
    _stats = context.read<ApiClient>().get('/admin/dashboard');
  }

  Future<void> _reload() async {
    setState(() => _stats = context.read<ApiClient>().get('/admin/dashboard'));
    try {
      await _stats;
    } catch (_) {
      // FutureBuilder below renders the API error and retry action.
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          return DashboardCanvas(
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              drawer: const MainSidebarDrawer(),
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: DashboardColors.magenta,
                  onRefresh: _reload,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: DashboardColors.magenta,
                        foregroundColor: Colors.white,
                        leading: IconButton(
                          tooltip: 'Buka menu admin',
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                        title: const AppBrandTitle(
                          section: 'Dasbor Admin',
                          inverse: true,
                        ),
                        actions: [
                          IconButton(
                            tooltip: 'Notifikasi',
                            onPressed: () => context.push('/app/notifications'),
                            icon: const Icon(Icons.notifications_none_rounded),
                          ),
                          IconButton(
                            tooltip: 'Keluar',
                            onPressed: () => context
                                .read<AuthBloc>()
                                .add(AuthLogoutRequested()),
                            icon: const Icon(Icons.logout_rounded),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth > 1120
                              ? 1120.0
                              : constraints.maxWidth;
                          return Center(
                            child: SizedBox(
                              width: width,
                              child: Padding(
                                padding: EdgeInsets.all(
                                    constraints.maxWidth < 380 ? 14 : 22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _welcomeHeader(user?.name ?? 'Admin'),
                                    const SizedBox(height: 20),
                                    _buildQuickStats(context),
                                    const SizedBox(height: 25),
                                    const DashboardSectionHeading(
                                      title: 'Akses cepat',
                                      subtitle:
                                          'Pilih modul yang ingin Anda kelola.',
                                    ),
                                    const SizedBox(height: 14),
                                    _buildActionGrid(context),
                                    const SizedBox(height: 25),
                                    const DashboardSectionHeading(
                                      title: 'Kalender perusahaan',
                                      subtitle:
                                          'Agenda dan hari penting dari kalender.',
                                    ),
                                    const SizedBox(height: 14),
                                    const DashboardEntrance(
                                        child: GlassDashboardPanel(
                                            child: AdminDashboardCalendar())),
                                    SizedBox(height: 36.h),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: NavigationBar(
                height: 70,
                backgroundColor: const Color(0xF2F4FCF6),
                indicatorColor: const Color(0x3316A34A),
                selectedIndex: 0,
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.space_dashboard_outlined),
                      selectedIcon: Icon(Icons.space_dashboard_rounded),
                      label: 'Dasbor'),
                  NavigationDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: 'Karyawan'),
                  NavigationDestination(
                      icon: Icon(Icons.fact_check_outlined),
                      selectedIcon: Icon(Icons.fact_check_rounded),
                      label: 'Absensi'),
                  NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: 'Jadwal'),
                  NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Menu'),
                ],
                onDestinationSelected: (index) {
                  switch (index) {
                    case 1:
                      context.push('/admin/employees');
                    case 2:
                      context.push('/admin/attendance-daily');
                    case 3:
                      context.push('/admin/schedule');
                    case 4:
                      _scaffoldKey.currentState?.openDrawer();
                  }
                },
              ),
            ),
          );
        },
      );

  Widget _welcomeHeader(String name) => DashboardEntrance(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DashboardColors.magenta,
                    DashboardColors.magentaDeep
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PUSAT KENDALI',
                      style: TextStyle(
                          color: Color(0xFFFFD6E9),
                          fontSize: 11,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 9),
                  Text('Halo, $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(
                      DateFormat('EEEE, d MMMM y', 'id_ID')
                          .format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: .84),
                          fontSize: 13)),
                ],
              ),
            ),
            Positioned(
              right: -28,
              bottom: -68,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: .15), width: 24),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );

  Widget _buildQuickStats(BuildContext context) => FutureBuilder<dynamic>(
        future: _stats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GlassDashboardPanel(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(18),
                child:
                    CircularProgressIndicator(color: DashboardColors.magenta),
              )),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return GlassDashboardPanel(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: DashboardColors.magenta, size: 30),
                  const SizedBox(height: 8),
                  const Text('Ringkasan belum dapat dimuat dari server.'),
                  TextButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          final stats = _unwrapMap(snapshot.data);
          final employees = _asMap(stats['employees']);
          final attendance = _asMap(stats['attendance_today']);
          final pending = _asMap(stats['pending_approvals']);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardSectionHeading(
                title: 'Ringkasan hari ini',
                subtitle:
                    DateFormat('d MMMM y', 'id_ID').format(DateTime.now()),
                action: TextButton(
                  onPressed: () => context.push('/admin/attendance-daily'),
                  child: const Text('Detail'),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                final items = <Widget>[
                  DashboardMetricCard(
                      label: 'Karyawan',
                      value: '${employees['total'] ?? '—'}',
                      icon: Icons.people_alt_rounded,
                      accent: DashboardColors.cyanDeep),
                  DashboardMetricCard(
                      label: 'Hadir',
                      value: '${attendance['present'] ?? '—'}',
                      icon: Icons.how_to_reg_rounded,
                      accent: const Color(0xFF168B68)),
                  DashboardMetricCard(
                      label: 'Belum hadir',
                      value: '${attendance['absent'] ?? '—'}',
                      icon: Icons.person_off_rounded,
                      accent: const Color(0xFFC34C5B)),
                  DashboardMetricCard(
                      label: 'Menunggu persetujuan',
                      value: '${pending['total'] ?? '—'}',
                      icon: Icons.pending_actions_rounded,
                      accent: DashboardColors.magenta),
                ];
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth >= 760 ? 1.65 : 1.4,
                  children: items,
                );
              }),
              const SizedBox(height: 12),
              _departmentAttendance(stats['department_attendance']),
            ],
          );
        },
      );

  Widget _departmentAttendance(dynamic raw) {
    final departments = raw is List ? raw.whereType<Map>().toList() : const [];
    if (departments.isEmpty) return const SizedBox.shrink();
    return DashboardEntrance(
      child: GlassDashboardPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kehadiran per departemen',
                style: TextStyle(
                    color: DashboardColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const SizedBox(height: 14),
            ...departments.take(5).map((item) {
              final rate = ((item['attendance_rate'] as num?) ?? 0)
                  .toDouble()
                  .clamp(0, 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                          item['department']?.toString() ?? 'Departemen',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: DashboardColors.ink,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text('${rate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: DashboardColors.cyanDeep,
                            fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: rate / 100),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE1F1F4),
                        color: DashboardColors.cyan,
                      ),
                    ),
                  ),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _unwrapMap(dynamic response) {
    dynamic payload = response.data;
    if (payload is Map && payload['data'] is Map) payload = payload['data'];
    return payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  Widget _buildActionGrid(BuildContext context) {
    const groups = <_AdminActionGroup>[
      _AdminActionGroup('Karyawan & persetujuan', [
        _AdminAction(
            'Data karyawan', Icons.people_alt_rounded, '/admin/employees'),
        _AdminAction(
            'Persetujuan', Icons.fact_check_rounded, '/admin/approvals'),
        _AdminAction('Permohonan cuti', Icons.event_busy_rounded,
            '/admin/leave-requests'),
        _AdminAction(
            'Klaim karyawan', Icons.receipt_long_rounded, '/admin/claims'),
      ]),
      _AdminActionGroup('Absensi & jadwal', [
        _AdminAction(
            'Absensi harian', Icons.today_rounded, '/admin/attendance-daily'),
        _AdminAction(
            'Laporan absensi', Icons.summarize_rounded, '/admin/reports'),
        _AdminAction(
            'Jadwal & shift', Icons.calendar_month_rounded, '/admin/schedule'),
        _AdminAction('Penugasan shift', Icons.assignment_ind_rounded,
            '/admin/shift-assignments'),
        _AdminAction('Keamanan GPS', Icons.gps_off_rounded,
            '/admin/attendance-security-events'),
      ]),
      _AdminActionGroup('Operasional', [
        _AdminAction('Payroll', Icons.payments_rounded, '/admin/payroll'),
        _AdminAction('Pengaturan payroll', Icons.request_quote_rounded,
            '/admin/payroll-config'),
        _AdminAction('Kalender event', Icons.event_rounded, '/admin/events'),
        _AdminAction(
            'Pengumuman', Icons.campaign_rounded, '/admin/announcements'),
        _AdminAction(
            'Jenis cuti', Icons.flight_takeoff_rounded, '/admin/leave-types'),
        _AdminAction(
            'Perangkat', Icons.phonelink_lock_rounded, '/admin/devices'),
        _AdminAction('Pengaturan organisasi', Icons.business_rounded,
            '/admin/org-settings'),
        _AdminAction(
            'Pengaturan admin', Icons.settings_rounded, '/admin/settings'),
        _AdminAction('Analitik departemen', Icons.analytics_rounded,
            '/admin/department-analytics'),
        _AdminAction('Ekspor data', Icons.download_rounded, '/admin/export'),
        _AdminAction('Audit log', Icons.history_rounded, '/admin/audit-logs'),
      ]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups
          .map((group) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.title,
                        style: const TextStyle(
                            color: DashboardColors.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    const SizedBox(height: 10),
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 520
                              ? 3
                              : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: group.actions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.55,
                        ),
                        itemBuilder: (context, index) {
                          final action = group.actions[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(21),
                              onTap: () => context.push(action.route),
                              child: GlassDashboardPanel(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 12),
                                radius: 21,
                                tint: const Color(0xEFFFFFFF),
                                child: Row(children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: DashboardColors.cyan
                                          .withValues(alpha: .14),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(action.icon,
                                        color: DashboardColors.cyanDeep,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(action.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: DashboardColors.ink,
                                          fontSize: 12,
                                          height: 1.2,
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: DashboardColors.muted, size: 20),
                                ]),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _AdminAction {
  final String title;
  final IconData icon;
  final String route;
  const _AdminAction(this.title, this.icon, this.route);
}

class _AdminActionGroup {
  final String title;
  final List<_AdminAction> actions;
  const _AdminActionGroup(this.title, this.actions);
}
