import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/repositories/device_repository.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/wonten_card.dart';
import '../../../../../core/services/device_identity_service.dart';
import '../../../../auth/bloc/auth_bloc.dart';

class DeviceBindingScreen extends StatefulWidget {
  const DeviceBindingScreen({super.key});

  @override
  State<DeviceBindingScreen> createState() => _DeviceBindingScreenState();
}

class _DeviceBindingScreenState extends State<DeviceBindingScreen> {
  final TextEditingController _identityNameController =
      TextEditingController();
  String _deviceName = 'Mendeteksi perangkat...';
  String _deviceOS = '';
  String _deviceFingerprint = '';
  bool _isLoading = true;
  bool _isBinding = false;

  @override
  void dispose() {
    _identityNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _detectDevice();
  }

  Future<void> _detectDevice() async {
    try {
      final identity = await DeviceIdentityService().getIdentity();
      _deviceName = identity.name;
      _deviceOS = identity.osVersion;
      _deviceFingerprint = identity.fingerprint;

      if (!mounted) return;

      // Auto check status before asking user to bind
      try {
        final deviceRepo = context.read<DeviceRepository>();
        final device = await deviceRepo.getStatus(_deviceFingerprint);

        if (device.status == 'active') {
          final secureStorage = SecureStorage();
          await secureStorage.saveDeviceFingerprint(_deviceFingerprint);
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckSession());
            return;
          }
        } else if (device.status == 'pending_approval') {
          final secureStorage = SecureStorage();
          await secureStorage.saveDeviceFingerprint(_deviceFingerprint);
          if (mounted) context.go('/device-pending');
          return;
        } else {
          // Rejected/revoked associations keep the submission action visible so
          // the employee can submit a fresh approval request.
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      } catch (_) {
        // The fingerprint may be new for this account even when the physical
        // device is already used by another account. Keep the action visible
        // so the current account can create its own binding.
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isBinding = false;
          });
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
    if (_deviceFingerprint.isEmpty) return;
    final identityName = _identityNameController.text.trim();
    if (identityName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nama perangkat minimal 3 karakter.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = false;
      _isBinding = true;
    });

    try {
      // Register device with backend
      final deviceRepo = context.read<DeviceRepository>();
      final device = await deviceRepo.register(
        deviceFingerprint: _deviceFingerprint,
        deviceName: identityName,
        deviceModel: _deviceName,
        osVersion: _deviceOS,
      );

      // Save fingerprint locally
      final secureStorage = SecureStorage();
      await secureStorage.saveDeviceFingerprint(_deviceFingerprint);

      if (mounted) {
        if (device.status == 'active') {
          context.read<AuthBloc>().add(AuthCheckSession());
        } else {
          context.go('/device-pending');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBinding = false);
        String errorMessage =
            'Gagal mendaftarkan perangkat. Silakan coba lagi.';
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
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      
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
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.h),
                  WontenCard(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        if (_isLoading) ...[
                          const CircularProgressIndicator(
                              color: AppColors.primary),
                          SizedBox(height: 24.h),
                          Text('Membaca identitas perangkat...',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14.sp)),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(20.r)),
                            child: Icon(Icons.smartphone,
                                size: 48.w, color: AppColors.primary),
                          ),
                          SizedBox(height: 24.h),
                          Text(_deviceName,
                              style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          SizedBox(height: 8.h),
                          Text(_deviceOS,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14.sp)),
                          SizedBox(height: 24.h),
                          TextField(
                            controller: _identityNameController,
                            enabled: !_isBinding,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nama identitas perangkat',
                              hintText: 'Contoh: HP Andi atau Laptop Kantor',
                              prefixIcon: Icon(Icons.badge_outlined),
                              helperText:
                                  'Nama ini akan terlihat oleh admin saat menyetujui.',
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Ajukan perangkat ini untuk dikaitkan ke akun Anda. Akses dashboard tersedia setelah admin menyetujuinya.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12.sp,
                                height: 1.4),
                          ),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: FilledButton(
                              onPressed: _isBinding ? null : _handleBindDevice,
                              child: _isBinding
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.w,
                                      child: const CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text('Ajukan Perangkat',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: _isBinding
                                ? null
                                : () => context
                                    .read<AuthBloc>()
                                    .add(AuthLogoutRequested()),
                            child: Text('Gunakan Akun Lain',
                                style: TextStyle(color: Colors.grey[600])),
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
    ));
  }
}
