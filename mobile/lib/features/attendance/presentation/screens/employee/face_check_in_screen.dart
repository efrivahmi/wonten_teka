import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/services/face_matcher_service.dart';
import '../../../bloc/attendance_cubit.dart';
import '../../widgets/camera_preview_widget.dart';

class FaceCheckInScreen extends StatefulWidget {
  const FaceCheckInScreen({super.key});

  @override
  State<FaceCheckInScreen> createState() => _FaceCheckInScreenState();
}

class _FaceCheckInScreenState extends State<FaceCheckInScreen> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey();

  String _locationStatus = "Memeriksa Lokasi...";
  String _currentAddress = "Mencari alamat...";
  bool _isLocationValid = false;
  Position? _currentPosition;

  bool _isFaceDetected = false;
  bool _isFaceProper = false;
  bool _isTooDark = false;
  List<double> _liveEmbedding = [];
  File? _capturedImage;
  bool _isCapturing = false;
  
  // Debug panel state
  bool _showDebug = false;

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
      if (mounted) {
        setState(() {
          _locationStatus = "Layanan lokasi dinonaktifkan";
          _currentAddress = "GPS Mati";
        });
      }
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
      if (mounted) {
        setState(() => _locationStatus = "Izin lokasi ditolak permanen");
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      
      // Simulate checking against office radius
      // In a real app, calculate distance to office lat/long
      bool inRadius = true; // Placeholder for actual radius check

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocationValid = inRadius;
          _locationStatus = inRadius ? "Lokasi Sesuai Radius" : "Di Luar Radius Kantor";
        });
      }
      
      // Reverse Geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks[0];
          setState(() {
            _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
          });
        }
      } catch (e) {
        if (mounted) setState(() => _currentAddress = "Alamat tidak ditemukan");
      }
      
    } catch (e) {
      if (mounted) setState(() => _locationStatus = "Gagal mendapatkan lokasi");
    }
  }

  void _handleFaceValidation(bool isDetected, bool isProper, double angleY, bool isTooDark) {
    // For check-in, we just want them to face forward
    bool isAngleCorrect = (isProper && angleY > -15 && angleY < 15);
    
    if (_isFaceDetected != isDetected || _isFaceProper != isAngleCorrect || _isTooDark != isTooDark) {
      setState(() {
        _isFaceDetected = isDetected;
        _isFaceProper = isAngleCorrect;
        _isTooDark = isTooDark;
      });
    }
  }

  void _handleFaceEmbedding(List<double> embedding) {
    _liveEmbedding = embedding;
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null || !_isFaceProper || _isTooDark || _isCapturing) return;

    setState(() => _isCapturing = true);
    await _cameraKey.currentState?.takePhoto();
  }

  void _onPhotoCaptured(XFile? file) async {
    if (file != null) {
      setState(() => _capturedImage = File(file.path));

      final storage = SecureStorage();
      final deviceId = await storage.getDeviceFingerprint() ?? 'unknown';
      final registeredEmbeddingStr = await storage.getFaceEmbedding();

      double faceMatchScore = 0.0;
      if (registeredEmbeddingStr != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(registeredEmbeddingStr);
          final registeredEmbedding = jsonList.map((e) => (e as num).toDouble()).toList();
          faceMatchScore = FaceMatcherService.calculateCosineSimilarity(
              _liveEmbedding, registeredEmbedding);
        } catch (_) {}
      }

      final isMock = _currentPosition?.isMocked ?? false;

      if (mounted) {
        context.read<AttendanceCubit>().checkIn(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          deviceId: deviceId,
          faceMatchScore: faceMatchScore,
          photo: _capturedImage,
          flags: {
            'is_mock_location': isMock,
            'address': _currentAddress,
          },
        );
      }
    } else {
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal mengambil foto wajah.'),
            backgroundColor: AppColors.error),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: AppColors.secondary),
            onPressed: () {
              setState(() => _showDebug = !_showDebug);
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is CheckInSuccess) {
            context.go('/app/attendance/success');
          } else if (state is AttendanceError) {
            setState(() => _isCapturing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  child: Column(
                    children: [
                      Text(
                        timeString,
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
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
                        color: _isFaceProper && !_isTooDark
                            ? AppColors.primaryContainer
                            : (_isTooDark ? AppColors.error : AppColors.secondary),
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isFaceProper && !_isTooDark
                                  ? AppColors.primaryContainer
                                  : AppColors.secondary)
                              .withValues(alpha: 0.2),
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
                              onFaceEmbeddingGenerated: _handleFaceEmbedding,
                              onPhotoCaptured: _onPhotoCaptured,
                            ),
                    ),
                  ).animate(target: (_isFaceProper && !_isTooDark) ? 1 : 0).scale(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                      end: const Offset(1.05, 1.05)),
                ),

                SizedBox(height: 16.h),
                // Face Detection Status
                Text(
                  _isTooDark
                      ? "Cahaya terlalu gelap"
                      : _isFaceProper
                          ? "Wajah terdeteksi (Lurus ke Depan)"
                          : _isFaceDetected
                              ? "Arahkan wajah lurus ke depan"
                              : "Wajah tidak terdeteksi",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isTooDark
                            ? AppColors.error
                            : (_isFaceProper ? AppColors.primary : AppColors.secondary),
                        fontWeight: FontWeight.bold,
                      ),
                ).animate(target: (_isFaceProper && !_isTooDark) ? 1 : 0).fade().scale(),

                SizedBox(height: 24.h),

                // GPS Indicator
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _isLocationValid
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.w,
                        color: _isLocationValid
                            ? const Color(0xFF10B981)
                            : AppColors.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _locationStatus,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _isLocationValid
                                  ? const Color(0xFF10B981)
                                  : AppColors.secondary,
                            ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),
                
                // Detailed Address
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    _currentAddress,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                if (_showDebug) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('DEBUG PANEL', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        SizedBox(height: 4.h),
                        Text('Mock Location: ${_currentPosition?.isMocked ?? false}', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                        Text('Lat/Lng: ${_currentPosition?.latitude ?? "-"}, ${_currentPosition?.longitude ?? "-"}', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                        Text('Face Detected: $_isFaceDetected | Proper: $_isFaceProper', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                        Text('Too Dark: $_isTooDark', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Action Button
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: (_isFaceProper &&
                              !_isTooDark &&
                              _isLocationValid &&
                              !isLoading &&
                              _capturedImage == null)
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
