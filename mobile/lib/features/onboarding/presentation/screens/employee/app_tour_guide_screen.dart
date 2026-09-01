import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/storage/secure_storage.dart';

class AppTourGuideScreen extends StatefulWidget {
  const AppTourGuideScreen({super.key});
  @override
  State<AppTourGuideScreen> createState() => _AppTourGuideScreenState();
}

class _AppTourGuideScreenState extends State<AppTourGuideScreen> {
  int _currentStep = 0;
  final _steps = [
    {
      'title': 'Selamat Datang di Wonten Teka',
      'desc': 'Mari kita mulai tur singkat aplikasi ini.',
      'icon': Icons.waving_hand
    },
    {
      'title': 'Check-in Wajah',
      'desc':
          'Gunakan fitur face recognition untuk absensi yang cepat dan aman.',
      'icon': Icons.face
    },
    {
      'title': 'Pantau Kehadiran',
      'desc': 'Lihat riwayat dan statistik kehadiran Anda kapan saja.',
      'icon': Icons.analytics
    },
    {
      'title': 'Pengajuan Cuti & Klaim',
      'desc': 'Ajukan cuti, lembur, dan klaim dengan mudah dari HP Anda.',
      'icon': Icons.assignment
    },
  ];

  Future<void> _completeTour() async {
    final storage = SecureStorage();
    await storage.setHasSeenTour(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: SafeArea(
          child: Column(children: [
        Align(
            alignment: Alignment.topRight,
            child: TextButton(
                onPressed: _completeTour,
                child: const Text('Lewati',
                    style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold)))),
        Expanded(
            child: PageView.builder(
          itemCount: _steps.length,
          onPageChanged: (i) => setState(() => _currentStep = i),
          itemBuilder: (context, i) {
            final step = _steps[i];
            return Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.onPrimary.withValues(alpha: 0.2)),
                          child: Icon(step['icon'] as IconData,
                              size: 64.w, color: AppColors.onPrimary)),
                      SizedBox(height: 48.h),
                      Text(step['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold)),
                      SizedBox(height: 16.h),
                      Text(step['desc'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.onPrimary.withValues(alpha: 0.8),
                              fontSize: 16.sp,
                              height: 1.5)),
                    ]));
          },
        )),
        Padding(
            padding: EdgeInsets.all(32.w),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      children: List.generate(
                          _steps.length,
                          (i) => Container(
                              margin: EdgeInsets.only(right: 8.w),
                              width: _currentStep == i ? 24.w : 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                  color: _currentStep == i
                                      ? AppColors.onPrimary
                                      : AppColors.onPrimary
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4.r))))),
                  ElevatedButton(
                      onPressed: () {
                        if (_currentStep < _steps.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          _completeTour();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onPrimary,
                          foregroundColor: AppColors.primaryContainer,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r))),
                      child: Text(
                          _currentStep < _steps.length - 1 ? 'Lanjut' : 'Mulai',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ])),
      ])),
    );
  }
}


