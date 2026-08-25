import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    
    try {
      final storage = SecureStorage();
      final fingerprint = await storage.getDeviceFingerprint();
      
      if (fingerprint != null) {
        final deviceRepo = context.read<DeviceRepository>();
        final device = await deviceRepo.getStatus(fingerprint);
        
        if (device.status == 'active') {
          if (mounted) {
            // Trigger auth bloc to re-evaluate routing
            context.read<AuthBloc>().add(AuthCheckSession());
          }
        } else if (device.status == 'pending_approval') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Status perangkat masih menunggu persetujuan.')),
            );
          }
        } else {
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perangkat ditolak atau tidak valid.'), backgroundColor: AppColors.error),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 64.w,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Menunggu Persetujuan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Perangkat Anda sedang ditinjau oleh Admin.\nSilakan hubungi HR atau tunggu beberapa saat lalu tekan "Cek Status".',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isChecking
                      ? const CircularProgressIndicator()
                      : const Text('Cek Status Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

