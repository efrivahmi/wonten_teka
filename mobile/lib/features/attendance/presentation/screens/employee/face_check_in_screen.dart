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
import '../../../../../core/repositories/attendance_repository.dart';
import '../../../../company/bloc/company_cubit.dart';
import '../../../bloc/attendance_cubit.dart';
import '../../widgets/camera_preview_widget.dart';

class FaceCheckInScreen extends StatefulWidget {
  final bool isCheckOut;
  final bool isOvertime;
  const FaceCheckInScreen({super.key, this.isCheckOut = false, this.isOvertime = false});

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
  Future<Map<String, dynamic>>? _todayInfoFuture;

  @override
  void initState() {
    super.initState();
    _checkLocation();
    _todayInfoFuture = context.read<AttendanceRepository>().getTodayInfo();
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
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        // Fallback if getCurrentPosition times out
        position = await Geolocator.getLastKnownPosition();
      }
      
      if (position == null) {
        if (mounted) setState(() => _locationStatus = "Gagal mendapatkan lokasi GPS.");
        return;
      }
      
      if (!mounted) return;
      
      bool inRadius = true; // Fallback if no geofence data is available
      final companyState = context.read<CompanyCubit>().state;
      if (companyState is CompanyLoaded && companyState.geofence != null) {
        final geofence = companyState.geofence!;
        final double officeLat = double.tryParse(geofence['latitude']?.toString() ?? '') ?? 0.0;
        final double officeLng = double.tryParse(geofence['longitude']?.toString() ?? '') ?? 0.0;
        final double radius = double.tryParse(geofence['geofence_radius_meters']?.toString() ?? '') ?? 100.0;
        
        if (officeLat != 0.0 && officeLng != 0.0) {
          final distance = Geolocator.distanceBetween(
              position.latitude, position.longitude, officeLat, officeLng);
          inRadius = distance <= radius;
        }
      }

      bool isMock = position.isMocked;

      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (isMock) {
            _isLocationValid = false;
            _locationStatus = "Terdeteksi Fake GPS! Harap matikan aplikasi lokasi palsu Anda.";
          } else {
            _isLocationValid = inRadius;
            _locationStatus = inRadius ? "Lokasi Sesuai Radius" : "Anda berada di luar radius absen kantor.";
          }
        });
      }
      
      // Reverse Geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude).timeout(const Duration(seconds: 5));
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
    // For check-in, loosen angle restriction so it's not too strict
    bool isAngleCorrect = (isProper && angleY > -35 && angleY < 35);
    
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
    if (_currentPosition == null || !_isFaceProper || _isTooDark || _isCapturing || !_isLocationValid) return;

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
        if (widget.isCheckOut) {
          context.read<AttendanceCubit>().checkOut(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            deviceId: deviceId,
            faceMatchScore: faceMatchScore,
            photo: _capturedImage,
            flags: {
              'is_mock_location': isMock,
              'address': _currentAddress,
              'is_overtime': widget.isOvertime,
            },
          );
        } else {
          context.read<AttendanceCubit>().checkIn(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            deviceId: deviceId,
            faceMatchScore: faceMatchScore,
            photo: _capturedImage,
            flags: {
              'is_mock_location': isMock,
              'address': _currentAddress,
              'is_overtime': widget.isOvertime,
            },
          );
        }
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
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Background Header
          Container(
            height: 280.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          
          SafeArea(
            child: BlocConsumer<AttendanceCubit, AttendanceState>(
              listener: (context, state) {
                if (state is CheckInSuccess) {
                  if (mounted) {
                    context.go('/app/attendance/success', extra: {'log': state.log, 'isCheckOut': false});
                  }
                } else if (state is CheckOutSuccess) {
                  if (mounted) {
                    context.go('/app/attendance/success', extra: {'log': state.log, 'isCheckOut': true});
                  }
                } else if (state is AttendanceError) {
                  setState(() => _isCapturing = false);
                  
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
                    builder: (context) => Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 48.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r))),
                          SizedBox(height: 24.h),
                          Icon(Icons.error_outline, size: 64.w, color: AppColors.error),
                          SizedBox(height: 16.h),
                          Text(widget.isCheckOut ? 'Check-out Gagal' : 'Check-in Gagal', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                          SizedBox(height: 8.h),
                          Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tutup & Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AttendanceLoading || _isCapturing;

                return Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Text(
                              'Absen Masuk',
                              style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.bug_report, color: _showDebug ? Colors.white : Colors.white54),
                            onPressed: () => setState(() => _showDebug = !_showDebug),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 16.h),
                            // Date Time Info
                            Text(timeString, style: TextStyle(color: Colors.white, fontSize: 48.sp, fontWeight: FontWeight.bold, letterSpacing: -1)),
                            Text(dateString, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16.sp)),
                            SizedBox(height: 32.h),
                            
                            // Floating Card for Camera
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32.r),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Camera preview circle
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 260.w,
                                          height: 260.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[100],
                                            border: Border.all(
                                              color: _isFaceProper && !_isTooDark ? AppColors.primary : (_isTooDark ? AppColors.error : Colors.grey[300]!),
                                              width: 6.w,
                                            ),
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
                                        ).animate(target: (_isFaceProper && !_isTooDark) ? 1 : 0).scale(duration: 300.ms, curve: Curves.easeOutBack, end: const Offset(1.05, 1.05)),
                                        
                                        if (_isFaceProper && !_isTooDark && _capturedImage == null && !isLoading)
                                          Positioned.fill(
                                            child: ClipOval(
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 4.h,
                                                  decoration: const BoxDecoration(color: AppColors.primary, boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 10)]),
                                                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 260.w, duration: 1500.ms, curve: Curves.easeInOut),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  
                                  // Status Text
                                  Text(
                                    _isTooDark ? "Cahaya terlalu gelap" : _isFaceProper ? "Wajah terdeteksi sempurna" : _isFaceDetected ? "Arahkan wajah lurus ke depan" : "Wajah tidak terdeteksi",
                                    style: TextStyle(
                                      color: _isTooDark ? AppColors.error : (_isFaceProper ? AppColors.primary : Colors.grey[600]),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  SizedBox(height: 24.h),

                                  // Info Card
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: _todayInfoFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasData && snapshot.data != null) {
                                        final data = snapshot.data!;
                                        final shift = data['shift'] ?? {};
                                        final role = data['role'] ?? {};
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12.h),
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(16.r),
                                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.work_outline, color: Colors.blue[700], size: 18.w),
                                                  SizedBox(width: 8.w),
                                                  Text(role['position'] ?? 'Karyawan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.blue[800])),
                                                ],
                                              ),
                                              SizedBox(height: 8.h),
                                              Row(
                                                children: [
                                                  Icon(Icons.schedule, color: Colors.grey[700], size: 16.w),
                                                  SizedBox(width: 6.w),
                                                  Text("${shift['name']} (${shift['start_time']} - ${shift['end_time']})", style: TextStyle(fontSize: 12.sp, color: Colors.grey[800])),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    }
                                  ),
                                  
                                  // Location Indicator (Compact inside card)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: _isLocationValid ? Colors.green.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(_isLocationValid ? Icons.check_circle : Icons.location_off, color: _isLocationValid ? Colors.green : AppColors.error, size: 24.w),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_locationStatus, style: TextStyle(color: _isLocationValid ? Colors.green[800] : AppColors.error, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                              Text(_currentAddress, style: TextStyle(color: Colors.grey[700], fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 24.h),
                                  
                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56.h,
                                    child: ElevatedButton(
                                      onPressed: (!isLoading && _isFaceProper && !_isTooDark && _isLocationValid) ? _handleCheckIn : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                        elevation: 0,
                                        disabledBackgroundColor: Colors.grey[300],
                                      ),
                                      child: isLoading
                                          ? SizedBox(height: 24.w, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text(widget.isCheckOut ? 'Rekam Absen Keluar' : 'Rekam Absen Masuk', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            if (_showDebug)
                              Container(
                                margin: EdgeInsets.only(top: 24.h),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16.r)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DEBUG INFO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                                    Text('Lat: ${_currentPosition?.latitude}', style: TextStyle(color: Colors.greenAccent, fontSize: 10.sp)),
                                    Text('Lng: ${_currentPosition?.longitude}', style: TextStyle(color: Colors.greenAccent, fontSize: 10.sp)),
                                    Text('Mocked: ${_currentPosition?.isMocked}', style: TextStyle(color: _currentPosition?.isMocked == true ? Colors.redAccent : Colors.greenAccent, fontSize: 10.sp)),
                                  ],
                                ),
                              ),
                              
                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
