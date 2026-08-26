import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../../core/repositories/device_repository.dart';
import '../../../../../core/storage/secure_storage.dart';

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
    setState(() => _isChecking = true);

    try {
      final storage = SecureStorage();
      final fingerprint = await storage.getDeviceFingerprint();

      if (fingerprint != null) {
        final deviceRepo = context.read<DeviceRepository>();
        final device = await deviceRepo.getStatus(fingerprint);

        if (device.status == 'active') {
          _timer?.cancel(); // Stop polling when active
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckSession());
          }
        } else if (device.status == 'pending_approval') {
          if (mounted && showSnackbar) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Status perangkat masih menunggu persetujuan.')),
            );
          }
        } else {
          if (mounted && showSnackbar) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perangkat ditolak atau tidak valid.'), backgroundColor: AppColors.error),
            );
          }
        }
      }
    } catch (e) {
      if (mounted && showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memeriksa status perangkat.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Extended Primary Colored Header (Warning Style)
          Container(
            height: 320.h,
            decoration: BoxDecoration(
              color: Colors.amber[700], // Warning color for pending
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
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
                        Icon(Icons.devices_other, size: 64.w, color: Colors.white),
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
                  
                  // Floating Status Card
                  Container(
                    padding: EdgeInsets.all(32.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pending_actions,
                            size: 48.w,
                            color: Colors.amber[700],
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
                          'Perangkat Anda belum diverifikasi atau telah terikat dengan akun lain.\n\nSilakan hubungi Admin atau HRD Anda untuk melakukan persetujuan (Approval) perangkat ini agar Anda dapat melakukan absensi.',
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
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Keluar & Kembali ke Login', style: TextStyle(fontWeight: FontWeight.bold)),
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
