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

    if (hasToken) {
      // If token exists, trigger session check. The BlocListener in main.dart will handle the rest.
      context.read<AuthBloc>().add(AuthCheckSession());
    } else {
      // No token, check if user has seen tour
      final hasSeenTour = await storage.hasSeenTour();
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
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 80.w,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Wonten Teka',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Manajemen HR Tanpa Ribet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

