import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
    // Keep startup calm and fast; the session check does the real work.
    await Future.delayed(const Duration(milliseconds: 1200));

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
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                  color: AppColors.onSurface,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]),
              child: Image.asset(
                'assets/images/lemdiklat-logo.png',
                width: 92.w,
                height: 92.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'e-Absensi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Lemdiklat Taruna Nusantara Indonesia',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 64.h),
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
