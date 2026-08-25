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
        setState(() {
          _deviceName = '${androidInfo.brand} ${androidInfo.model}';
          _deviceOS = 'Android ${androidInfo.version.release}';
          _deviceFingerprint = androidInfo.id;
          _isLoading = false;
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceName = iosInfo.utsname.machine;
          _deviceOS = '${iosInfo.systemName} ${iosInfo.systemVersion}';
          _deviceFingerprint =
              iosInfo.identifierForVendor ?? iosInfo.utsname.machine;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _deviceName = 'Perangkat Tidak Dikenal';
        _deviceOS = 'Gagal mendeteksi';
        _deviceFingerprint =
            'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Keamanan Perangkat',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration / Icon
              Center(
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onSurface.withValues(alpha: 0.05),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.phonelink_lock,
                    size: 64.w,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              // Text Content
              Text(
                'Ikat Perangkat Ini',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Untuk keamanan Anda, akun akan diikat ke perangkat fisik ini. Anda hanya bisa melakukan absensi wajah dari HP ini.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // Device Details Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Platform.isAndroid
                            ? Icons.phone_android
                            : Icons.phone_iphone,
                        color: AppColors.onSurfaceVariant,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _isLoading
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Mendeteksi perangkat...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Perangkat Saat Ini',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _deviceName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (_deviceOS.isNotEmpty)
                                  Text(
                                    _deviceOS,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                    ),
                    if (!_isLoading)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.successEmerald,
                        size: 24.w,
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _isBinding) ? null : _handleBindDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: _isBinding
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimaryContainer),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Konfirmasi & Ikat Perangkat',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.shield, size: 20.w),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                child: Text(
                  'Batal & Logout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
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
