import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'main_sidebar_drawer.dart';

class BottomNavShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const BottomNavShell({super.key, required this.navigationShell});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _selectBranch(int index) {
    if (index != widget.navigationShell.currentIndex) {
      HapticFeedback.selectionClick();
    }
    widget.navigationShell.goBranch(index);
  }

  Future<void> _showAttendanceActions() async {
    HapticFeedback.mediumImpact();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Absensi',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            SizedBox(height: 5.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Pilih tindakan. Aplikasi akan memeriksa izin, lokasi, dan data wajah sebelum mengirim absensi.',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            SizedBox(height: 16.h),
            _attendanceAction(sheetContext,
                icon: Icons.login_rounded,
                title: 'Absen masuk',
                subtitle: 'Catat waktu mulai kerja',
                route: '/app/attendance/check-in'),
            SizedBox(height: 8.h),
            _attendanceAction(sheetContext,
                icon: Icons.logout_rounded,
                title: 'Absen keluar',
                subtitle: 'Catat waktu selesai kerja',
                route: '/app/attendance/check-out'),
            SizedBox(height: 8.h),
            _attendanceAction(sheetContext,
                icon: Icons.calendar_month_rounded,
                title: 'Lihat rekap absensi',
                subtitle: 'Periksa kalender dan riwayat kehadiran',
                route: '/app/attendance',
                history: true),
          ]),
        ),
      ),
    );
  }

  Widget _attendanceAction(BuildContext sheetContext,
      {required IconData icon,
      required String title,
      required String subtitle,
      required String route,
      bool history = false}) {
    return Material(
      color: const Color(0xFFF3F8F4),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.pop(sheetContext);
          if (history) {
            _selectBranch(1);
          } else {
            context.push(route);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0x1A159447),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(icon, color: const Color(0xFF147A3D)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2.h),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp, color: const Color(0xFF64746A))),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded,
                color: const Color(0xFF718078), size: 21.sp),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(
      {required IconData icon,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    final color = selected ? const Color(0xFF147A3D) : const Color(0xFF748078);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: SizedBox(
            height: 62.h,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 21.sp, color: color),
              SizedBox(height: 3.h),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 9.5.sp,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        drawer: const MainSidebarDrawer(),
        body: widget.navigationShell,
        bottomNavigationBar: SafeArea(
          top: false,
          child: SizedBox(
            height: 75.h,
            child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    top: 8.h,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xF5FFFFFF),
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: const Color(0xFFDDE9E0)),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x180F5130),
                              blurRadius: 22,
                              offset: Offset(0, -5))
                        ],
                      ),
                      child: Row(children: [
                        _navItem(
                            icon: Icons.home_rounded,
                            label: 'Beranda',
                            selected: widget.navigationShell.currentIndex == 0,
                            onTap: () => _selectBranch(0)),
                        _navItem(
                            icon: Icons.history_rounded,
                            label: 'Rekap',
                            selected: widget.navigationShell.currentIndex == 1,
                            onTap: () => _selectBranch(1)),
                        SizedBox(width: 66.w),
                        _navItem(
                            icon: Icons.receipt_long_rounded,
                            label: 'Gaji',
                            selected: widget.navigationShell.currentIndex == 2,
                            onTap: () => _selectBranch(2)),
                        _navItem(
                            icon: Icons.grid_view_rounded,
                            label: 'Menu',
                            selected: false,
                            onTap: () =>
                                _scaffoldKey.currentState?.openDrawer()),
                      ]),
                    ),
                  ),
                  Positioned(
                    top: -8.h,
                    child: Semantics(
                      button: true,
                      label: 'Buka tindakan absensi',
                      child: GestureDetector(
                        onTap: _showAttendanceActions,
                        child: Container(
                          width: 62.w,
                          height: 62.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF55C978),
                                  Color(0xFF159447),
                                  Color(0xFF0D6034)
                                ]),
                            border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x3A159447),
                                  blurRadius: 17,
                                  offset: Offset(0, 6))
                            ],
                          ),
                          child: Icon(Icons.fingerprint_rounded,
                              color: Colors.white, size: 27.sp),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50.h,
                    child: IgnorePointer(
                        child: Text('Absensi',
                            style: TextStyle(
                                color: const Color(0xFF147A3D),
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w800))),
                  ),
                ]),
          ),
        ),
      );
}
