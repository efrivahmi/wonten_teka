import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../bloc/attendance_cubit.dart';
import '../widgets/camera_preview_widget.dart';

class FaceCheckInScreen extends StatefulWidget {
  const FaceCheckInScreen({Key? key}) : super(key: key);

  @override
  State<FaceCheckInScreen> createState() => _FaceCheckInScreenState();
}

class _FaceCheckInScreenState extends State<FaceCheckInScreen> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey();
  
  String _locationStatus = "Memeriksa Lokasi...";
  bool _isLocationValid = false;
  Position? _currentPosition;

  bool _isFaceDetected = false;
  bool _isFaceProper = false;
  File? _capturedImage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationStatus = "Layanan lokasi dinonaktifkan");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationStatus = "Izin lokasi ditolak");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationStatus = "Izin lokasi ditolak permanen");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocationValid = true;
          _locationStatus = "Lokasi Sesuai (Di Dalam Radius)";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _locationStatus = "Gagal mendapatkan lokasi");
    }
  }

  void _handleFaceValidation(bool isDetected, bool isProper) {
    if (_isFaceDetected != isDetected || _isFaceProper != isProper) {
      setState(() {
        _isFaceDetected = isDetected;
        _isFaceProper = isProper;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null || !_isFaceProper || _isCapturing) return;
    
    setState(() => _isCapturing = true);

    // Capture the photo using the preview widget
    await _cameraKey.currentState?.takePhoto();
  }

  void _onPhotoCaptured(XFile? file) {
    if (file != null) {
      setState(() => _capturedImage = File(file.path));
      
      // Submit the attendance
      context.read<AttendanceCubit>().checkIn(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        deviceId: 'current-device-id', // Would come from DeviceInfo in real app
        photo: _capturedImage,
      );
    } else {
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto wajah.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);
    final dateString = DateFormat('EEEE, d MMM y', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Check In'),
        centerTitle: true,
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is CheckInSuccess) {
            context.go('/app/attendance/success');
          } else if (state is AttendanceError) {
            setState(() => _isCapturing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AttendanceLoading || _isCapturing;
          
          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    children: [
                      Text(
                        timeString,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        dateString,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Face Detection Area
                Center(
                  child: Container(
                    width: 280.w,
                    height: 280.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                      border: Border.all(
                        color: _isFaceProper ? AppColors.primaryContainer : AppColors.secondary,
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isFaceProper ? AppColors.primaryContainer : AppColors.secondary).withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 4,
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
                  ).animate(target: _isFaceProper ? 1 : 0).scale(duration: 300.ms, curve: Curves.easeOutBack, end: const Offset(1.05, 1.05)),
                ),

                SizedBox(height: 16.h),
                // Face Detection Status
                Text(
                  _isFaceProper
                      ? "Wajah terdeteksi"
                      : _isFaceDetected 
                          ? "Posisikan wajah lebih jelas" 
                          : "Arahkan wajah ke kamera",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _isFaceProper ? AppColors.primary : AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate(target: _isFaceProper ? 1 : 0).fade().scale(),

                SizedBox(height: 24.h),

                // GPS Indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _isLocationValid ? const Color(0xFF10B981).withOpacity(0.1) : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.w,
                        color: _isLocationValid ? const Color(0xFF10B981) : AppColors.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _locationStatus,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _isLocationValid ? const Color(0xFF10B981) : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action Button
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: (_isFaceProper && _isLocationValid && !isLoading && _capturedImage == null) 
                          ? _handleCheckIn 
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        disabledBackgroundColor: AppColors.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Check In Sekarang'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
