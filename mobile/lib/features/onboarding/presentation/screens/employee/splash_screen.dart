import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../auth/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    // 5 seconds delay for loading screen
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final storage = SecureStorage();
    final hasToken = await storage.hasToken();

    if (!mounted) return;

    if (hasToken) {
      // If token exists, trigger session check. The BlocListener in main.dart will handle the rest.
      context.read<AuthBloc>().add(AuthCheckSession());
    } else {
      // No token, check if user has seen tour
      final hasSeenTour = await storage.hasSeenTour();
      
      if (!mounted) return;

      if (hasSeenTour) {
        context.go('/login');
      } else {
        context.go('/app/tour');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Icon(
                Icons.fingerprint,
                size: 72.w,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Wonten Teka',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sistem Presensi Modern',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 64.h),
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
