import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/camera_preview_widget.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({Key? key}) : super(key: key);

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey();
  bool _isScanning = true;
  double _scanProgress = 0.0;
  bool _isFaceProper = false;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    // Simulate the time it takes to capture multiple angles
    _simulateScanning();
  }

  void _handleFaceValidation(bool isDetected, bool isProper) {
    if (_isFaceProper != isProper) {
      setState(() {
        _isFaceProper = isProper;
      });
    }
  }

  void _onPhotoCaptured(XFile? file) {
    if (file != null) {
      setState(() => _capturedImage = File(file.path));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Face Enrollment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                _isScanning 
                    ? 'Look directly at the camera and slowly turn your head.' 
                    : 'Enrollment Complete!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                    ),
                  ),
                  
                  // Camera Feed Placeholder
                  Container(
                    width: 280.w,
                    height: 280.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isScanning 
                            ? (_isFaceProper ? AppColors.primaryContainer : AppColors.surfaceContainerHigh)
                            : AppColors.successEmerald,
                        width: 4.w,
                      ),
                      color: AppColors.surfaceContainerLow,
                      boxShadow: [
                        BoxShadow(
                          color: (_isFaceProper ? AppColors.primaryContainer : Colors.transparent).withOpacity(0.3),
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
                              onPhotoCaptured: _onPhotoCaptured,
                            ),
                    ),
                  ).animate(target: _isFaceProper ? 1 : 0).scale(duration: 300.ms, curve: Curves.easeOutBack, end: const Offset(1.02, 1.02)),
                  
                  // Success Overlay
                  if (!_isScanning)
                    Container(
                      width: 280.w,
                      height: 280.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.successEmerald.withOpacity(0.8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 100.w,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fade(),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              _isScanning
                  ? (_isFaceProper ? "Tahan posisi ini..." : "Arahkan wajah ke dalam bingkai")
                  : "Wajah berhasil didaftarkan!",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _isFaceProper ? AppColors.primary : AppColors.secondary,
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
                  onPressed: _isScanning 
                      ? null 
                      : () {
                          // Complete enrollment and go to dashboard
                          context.go('/app/home');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Go to Dashboard',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isScanning ? AppColors.onSurfaceVariant : AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
