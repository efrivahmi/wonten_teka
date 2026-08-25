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
  
  int _currentStep = 0; // 0 = Depan, 1 = Kiri, 2 = Kanan
  final List<String> _stepInstructions = [
    "Arahkan wajah lurus ke depan",
    "Tengok perlahan ke KIRI",
    "Tengok perlahan ke KANAN"
  ];
  final List<String> _stepTitles = [
    "Wajah Depan",
    "Wajah Kiri",
    "Wajah Kanan"
  ];
  
  bool _isScanning = true;
  double _scanProgress = 0.0;
  bool _isFaceProper = false;
  bool _isTooDark = false;
  double _currentAngleY = 0.0;
  
  final List<List<double>> _capturedEmbeddings = [];
  List<double> _latestEmbedding = [];
  
  File? _capturedImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _simulateScanning();
  }

  void _handleFaceValidation(bool isDetected, bool isProper, double angleY, bool isTooDark) {
    if (!mounted) return;
    
    bool isAngleCorrect = false;
    if (isProper) {
      if (_currentStep == 0 && angleY > -10 && angleY < 10) {
        isAngleCorrect = true;
      } else if (_currentStep == 1 && angleY < -15) { // Looking left
        isAngleCorrect = true;
      } else if (_currentStep == 2 && angleY > 15) { // Looking right
        isAngleCorrect = true;
      }
    }

    if (_isFaceProper != isAngleCorrect || _isTooDark != isTooDark || _currentAngleY != angleY) {
      setState(() {
        _isFaceProper = isAngleCorrect;
        _isTooDark = isTooDark;
        _currentAngleY = angleY;
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
    while (_isScanning) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (_isFaceProper && !_isTooDark) {
        setState(() {
          _scanProgress += 0.05;
        });
        
        if (_scanProgress >= 1.0) {
          if (_latestEmbedding.isNotEmpty) {
            _capturedEmbeddings.add(List.from(_latestEmbedding));
          } else {
            _capturedEmbeddings.add([0.1, 0.2, 0.3]); // Fallback
          }
          
          if (_currentStep < 2) {
            setState(() {
              _currentStep++;
              _scanProgress = 0.0;
              _isFaceProper = false;
            });
            // Small pause between steps
            await Future.delayed(const Duration(milliseconds: 800));
          } else {
            setState(() {
              _isScanning = false;
            });
            await _cameraKey.currentState?.takePhoto();
            break;
          }
        }
      } else if (_scanProgress > 0) {
        // Decrease progress if face is lost or position is wrong
        setState(() {
          _scanProgress = (_scanProgress - 0.1).clamp(0.0, 1.0);
        });
      }
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
        faceEmbeddings: _capturedEmbeddings.isNotEmpty ? _capturedEmbeddings : [[0.0]],
        deviceId: deviceId,
      );

      if (_capturedEmbeddings.isNotEmpty) {
        await storage.saveFaceEmbedding(jsonEncode(_capturedEmbeddings[0]));
      }

      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckSession());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
           _isSubmitting = false;
           _errorMessage = 'Gagal menyimpan wajah ke server. Pastikan koneksi stabil.';
        });
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
    String instructionText = _isScanning 
        ? (_isTooDark 
            ? "Cahaya terlalu gelap. Pindah ke tempat terang." 
            : _stepInstructions[_currentStep]) 
        : "Selesai!";
        
    String helperText = _isScanning
        ? (_isFaceProper && !_isTooDark
            ? "Tahan posisi ini..."
            : "Sesuaikan wajah ke dalam bingkai oval")
        : _isSubmitting
            ? "Mengirim ke server..."
            : "Wajah berhasil didaftarkan!";

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
          if (state is AuthAuthenticated && !_isScanning && !_isSubmitting && _errorMessage == null) {
            _navigateToDashboard();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Text(
                      _isScanning ? _stepTitles[_currentStep] : 'Selesai',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      instructionText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _isTooDark ? AppColors.error : AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                    // Oval Progress Indicator
                    SizedBox(
                      width: 250.w,
                      height: 330.h,
                      child: CircularProgressIndicator(
                        value: _scanProgress,
                        strokeWidth: 8.w,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                      ),
                    ),

                    // Camera Feed (Oval shape)
                    Container(
                      width: 230.w,
                      height: 310.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.elliptical(230.w, 310.h)),
                        border: Border.all(
                          color: _isScanning
                              ? (_isTooDark
                                  ? AppColors.error
                                  : (_isFaceProper ? AppColors.primaryContainer : AppColors.surfaceContainerHigh))
                              : AppColors.successEmerald,
                          width: 4.w,
                        ),
                        color: AppColors.surfaceContainerLow,
                        boxShadow: [
                          BoxShadow(
                            color: (_isFaceProper && !_isTooDark
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
                    ).animate(target: (_isFaceProper && !_isTooDark) ? 1 : 0).scale(
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                        end: const Offset(1.02, 1.02)),

                    // Success Overlay
                    if (!_isScanning && !_isSubmitting)
                      Container(
                        width: 230.w,
                        height: 310.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.elliptical(230.w, 310.h)),
                          color: AppColors.successEmerald.withValues(alpha: 0.8),
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
                        width: 230.w,
                        height: 310.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.elliptical(230.w, 310.h)),
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
                helperText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isTooDark
                          ? AppColors.error
                          : (_isFaceProper ? AppColors.primary : AppColors.secondary),
                      fontWeight: FontWeight.bold,
                    ),
              ).animate(target: (_isFaceProper && !_isTooDark) ? 1 : 0).fade().scale(),

              const Spacer(),

              // Indicators for 3 steps
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  bool isCompleted = index < _currentStep;
                  bool isActive = index == _currentStep;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isActive ? 24.w : 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successEmerald
                          : (isActive ? AppColors.primary : AppColors.surfaceContainerHigh),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  );
                }),
              ),

              // Action Button (Retry if failed, Dashboard if success)
              Padding(
                padding: EdgeInsets.all(24.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: (_isScanning || _isSubmitting)
                        ? null
                        : (_errorMessage != null ? () {
                            setState(() {
                               _isScanning = true;
                               _currentStep = 0;
                               _scanProgress = 0.0;
                               _capturedEmbeddings.clear();
                               _capturedImage = null;
                               _errorMessage = null;
                            });
                            _simulateScanning();
                          } : _navigateToDashboard),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      _errorMessage != null ? 'Coba Lagi' : 'Lanjut ke Dashboard',
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


