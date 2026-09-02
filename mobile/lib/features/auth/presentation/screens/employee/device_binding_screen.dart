import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/repositories/device_repository.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../auth/bloc/auth_bloc.dart';

class DeviceBindingScreen extends StatefulWidget {
  const DeviceBindingScreen({super.key});

  @override
  State<DeviceBindingScreen> createState() => _DeviceBindingScreenState();
}

class _DeviceBindingScreenState extends State<DeviceBindingScreen> {
  String _deviceName = 'Mendeteksi perangkat...';
  String _deviceOS = '';
  String _deviceFingerprint = '';
  bool _isLoading = true;
  bool _isBinding = false;

  @override
  void initState() {
    super.initState();
    _detectDevice();
  }

  Future<void> _detectDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
        _deviceOS = 'Android ${androidInfo.version.release}';
        _deviceFingerprint = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.utsname.machine;
        _deviceOS = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        _deviceFingerprint =
            iosInfo.identifierForVendor ?? iosInfo.utsname.machine;
      }
      
      // Auto check status before asking user to bind
      try {
        final deviceRepo = context.read<DeviceRepository>();
        final device = await deviceRepo.getStatus(_deviceFingerprint);
        
        final secureStorage = SecureStorage();
        await secureStorage.saveDeviceFingerprint(_deviceFingerprint);
        
        if (device.status == 'active') {
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckSession());
            return;
          }
        } else if (device.status == 'pending_approval') {
          if (mounted) {
            context.go('/device-pending');
            return;
          }
        }
      } catch (_) {
        // Device not registered yet, automatically attempt to bind
        if (mounted) {
          _handleBindDevice();
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deviceName = 'Perangkat Tidak Dikenal';
          _deviceOS = 'Gagal mendeteksi';
          _deviceFingerprint =
              'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBindDevice() async {
    setState(() => _isBinding = true);

    try {
      // Register device with backend
      final deviceRepo = context.read<DeviceRepository>();
      final device = await deviceRepo.register(
        deviceFingerprint: _deviceFingerprint,
        deviceName: _deviceName,
        osVersion: _deviceOS,
      );

      // Save fingerprint locally
      final secureStorage = SecureStorage();
      await secureStorage.saveDeviceFingerprint(_deviceFingerprint);

      if (mounted) {
        if (device.status == 'pending_approval') {
          context.go('/device-pending');
        } else {
          // Status is active, trigger auth re-evaluation to go to face enrollment
          context.read<AuthBloc>().add(AuthCheckSession());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBinding = false);
        String errorMessage = 'Gagal mendaftarkan perangkat. Silakan coba lagi.';
        if (e is ApiException) {
           errorMessage = e.message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there is an error during binding, we'll store it here to display properly
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Background Header
          Container(
            height: 320.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.devices, size: 64.w, color: Colors.white),
                        SizedBox(height: 16.h),
                        Text(
                          'Deteksi Perangkat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Mengamankan akun Anda',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.h),
                  
                  // Card
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
                      children: [
                        if (_isLoading) ...[
                          const CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 24.h),
                          Text('Membaca identitas perangkat...', style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon(Icons.smartphone, size: 48.w, color: AppColors.primary),
                          ),
                          SizedBox(height: 24.h),
                          Text(_deviceName, style: TextStyle(color: AppColors.onSurface, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          SizedBox(height: 8.h),
                          Text(_deviceOS, style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: _isBinding ? null : _handleBindDevice,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                elevation: 0,
                              ),
                              child: _isBinding
                                  ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Daftarkan Perangkat Ini', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: _isBinding ? null : () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                            child: Text('Gunakan Akun Lain', style: TextStyle(color: Colors.grey[600])),
                          ),
                        ],
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
