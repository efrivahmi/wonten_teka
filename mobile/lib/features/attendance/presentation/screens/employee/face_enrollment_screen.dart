import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/repositories/attendance_repository.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../widgets/camera_preview_widget.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey();
  bool _isScanning = true;
  double _scanProgress = 0.0;
  bool _isFaceProper = false;
  List<double> _latestEmbedding = [];
  File? _capturedImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _simulateScanning();
  }

  void _handleFaceValidation(bool isDetected, bool isProper) {
    if (_isFaceProper != isProper) {
      setState(() {
        _isFaceProper = isProper;
      });
    }
  }

  void _handleFaceEmbedding(List<double> embedding) {
    _latestEmbedding = embedding;
  }

  void _onPhotoCaptured(XFile? file) async {
    if (file != null) {
      setState(() => _capturedImage = File(file.path));
      await _submitEnrollment();
    }
  }

  void _simulateScanning() async {
    while (_scanProgress < 1.0) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isFaceProper) {
        setState(() {
          _scanProgress += 0.02;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
      await _cameraKey.currentState?.takePhoto();
    }
  }

  Future<void> _submitEnrollment() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final storage = SecureStorage();
      final deviceId = await storage.getDeviceFingerprint() ?? 'unknown-device';
      
      final attendanceRepo = context.read<AttendanceRepository>();
      await attendanceRepo.enrollFace(
        faceEmbedding: _latestEmbedding.isNotEmpty ? _latestEmbedding : [0.0],
        deviceId: deviceId,
      );

      // Save locally for fast check-in comparison
      await storage.saveFaceEmbedding(jsonEncode(_latestEmbedding));

      // Refresh user data to get updated faceEnrolled status
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckSession());
      }
    } catch (e) {
      // Even if backend fails, navigate forward (offline-first approach)
      if (mounted) {
        _navigateToDashboard();
      }
    }
  }

  void _navigateToDashboard() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.isAdmin) {
        context.go('/admin/dashboard');
      } else if (authState.user.isManager) {
        context.go('/manager/dashboard');
      } else {
        context.go('/app/home');
      }
    } else {
      context.go('/app/home');
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
          'Pendaftaran Wajah',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // After AuthCheckSession completes, navigate based on role
          if (state is AuthAuthenticated && !_isScanning) {
            _navigateToDashboard();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  _isScanning
                      ? 'Arahkan wajah ke kamera dan putar kepala Anda perlahan.'
                      : _isSubmitting
                          ? 'Menyimpan data wajah...'
                          : 'Pendaftaran Berhasil!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error, fontSize: 13.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const Spacer(),

              // Camera Area
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular Progress Indicator
                    SizedBox(
                      width: 300.w,
                      height: 300.w,
                      child: CircularProgressIndicator(
                        value: _scanProgress,
                        strokeWidth: 8.w,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryContainer),
                      ),
                    ),

                    // Camera Feed
                    Container(
                      width: 280.w,
                      height: 280.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isScanning
                              ? (_isFaceProper
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceContainerHigh)
                              : AppColors.successEmerald,
                          width: 4.w,
                        ),
                        color: AppColors.surfaceContainerLow,
                        boxShadow: [
                          BoxShadow(
                            color: (_isFaceProper
                                    ? AppColors.primaryContainer
                                    : Colors.transparent)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _capturedImage != null
                            ? Image.file(_capturedImage!, fit: BoxFit.cover)
                            : CameraPreviewWidget(
                                key: _cameraKey,
                                onFaceValidationChanged: _handleFaceValidation,
                                onFaceEmbeddingGenerated: _handleFaceEmbedding,
                                onPhotoCaptured: _onPhotoCaptured,
                              ),
                      ),
                    ).animate(target: _isFaceProper ? 1 : 0).scale(
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                        end: const Offset(1.02, 1.02)),

                    // Success Overlay
                    if (!_isScanning && !_isSubmitting)
                      Container(
                        width: 280.w,
                        height: 280.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              AppColors.successEmerald.withValues(alpha: 0.8),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 100.w,
                        ),
                      )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.elasticOut)
                          .fade(),

                    // Loading Overlay
                    if (_isSubmitting)
                      Container(
                        width: 280.w,
                        height: 280.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 48.w,
                              height: 48.w,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Menyimpan...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ).animate().fade(),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              Text(
                _isScanning
                    ? (_isFaceProper
                        ? "Tahan posisi ini..."
                        : "Arahkan wajah ke dalam bingkai")
                    : _isSubmitting
                        ? "Mengirim ke server..."
                        : "Wajah berhasil didaftarkan!",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isFaceProper
                          ? AppColors.primary
                          : AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate(target: _isFaceProper ? 1 : 0).fade().scale(),

              const Spacer(),

              // Action Button
              Padding(
                padding: EdgeInsets.all(24.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: (_isScanning || _isSubmitting)
                        ? null
                        : _navigateToDashboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Masuk ke Dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: (_isScanning || _isSubmitting)
                                ? AppColors.onSurfaceVariant
                                : AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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

