import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../../core/repositories/device_repository.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/wonten_card.dart';

class DevicePendingScreen extends StatefulWidget {
  const DevicePendingScreen({super.key});

  @override
  State<DevicePendingScreen> createState() => _DevicePendingScreenState();
}

class _DevicePendingScreenState extends State<DevicePendingScreen> {
  bool _isChecking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-check initially and then every 5 seconds
    _checkStatus(showSnackbar: false);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isChecking) {
        _checkStatus(showSnackbar: false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool showSnackbar = true}) async {
    if (!mounted) return;
    setState(() => _isChecking = true);

    try {
      final storage = SecureStorage();
      final deviceRepo = context.read<DeviceRepository>();
      final fingerprint = await storage.getDeviceFingerprint();

      if (fingerprint != null) {
        final device = await deviceRepo.getStatus(fingerprint);

        if (device.status == 'active') {
          _timer?.cancel(); // Stop polling when active
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckSession());
          }
        } else if (device.status == 'pending_approval') {
          if (mounted && showSnackbar) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Status perangkat masih menunggu persetujuan.')),
            );
          }
        } else if (mounted) {
          _timer?.cancel();
          context.go('/device-binding');
        }
      }
    } catch (e) {
      if (mounted && showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal memeriksa status perangkat.'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _logout() {
    // Stop the five-second approval poll before deleting the session token.
    // Any in-flight status request is then harmless and cannot restart logout.
    _timer?.cancel();
    _timer = null;
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            left: 12.w,
            right: 12.w,
            top: 12.h,
            child: BrandPanel(child: SizedBox(height: 265.h)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60.h),
                  // Header Text
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.devices_other,
                            size: 64.w, color: Colors.white),
                        SizedBox(height: 16.h),
                        Text(
                          'Verifikasi Perangkat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.h),

                  WontenCard(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.pending_actions,
                            size: 48.w,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Menunggu Persetujuan Admin',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Pengajuan perangkat sudah tercatat. Dashboard akan terbuka otomatis setelah admin menyetujuinya.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Keluar & Kembali ke Login',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
