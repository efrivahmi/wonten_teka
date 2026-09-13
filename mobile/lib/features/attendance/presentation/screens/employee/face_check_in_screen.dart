import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../../../../core/services/face_matcher_service.dart';
import '../../../../../core/repositories/attendance_repository.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../company/bloc/company_cubit.dart';
import '../../../bloc/attendance_cubit.dart';
import '../../widgets/camera_preview_widget.dart';

class FaceCheckInScreen extends StatefulWidget {
  final bool isCheckOut;
  final bool isOvertime;
  const FaceCheckInScreen(
      {super.key, this.isCheckOut = false, this.isOvertime = false});

  @override
  State<FaceCheckInScreen> createState() => _FaceCheckInScreenState();
}

class _FaceCheckInScreenState extends State<FaceCheckInScreen> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey();

  String _locationStatus = "Memeriksa Lokasi...";
  String _currentAddress = "Mencari alamat...";
  bool _isLocationValid = false;
  bool _isOutOfRadius = false;
  Position? _currentPosition;

  bool _isFaceDetected = false;
  bool _isFaceProper = false;
  bool _isTooDark = false;
  List<double> _liveEmbedding = [];
  double _liveSimilarity = 0;
  File? _capturedImage;
  bool _isCapturing = false;
  bool _submissionStarted = false;
  Timer? _autoCaptureTimer;
  List<List<double>> _registeredEmbeddings = const [];
  String? _faceReferenceError;

  // Debug panel state
  Future<Map<String, dynamic>>? _todayInfoFuture;
  Map<String, dynamic>? _selectedShift;
  String? _selectedShiftKey;

  @override
  void initState() {
    super.initState();
    _checkLocation();
    _todayInfoFuture = _loadTodayInfo();
    _loadFaceReferences();
  }

  Future<void> _loadFaceReferences() async {
    final repository = context.read<AttendanceRepository>();
    List<List<double>>? references;
    var mayUseOfflineCache = false;
    try {
      references = await repository.syncFace();
    } on NotFoundException {
      await SecureStorage().deleteFaceEmbedding();
    } on NetworkException {
      mayUseOfflineCache = true;
    } catch (_) {
      mayUseOfflineCache = true;
    }

    if (mayUseOfflineCache && (references == null || references.isEmpty)) {
      final cached = await SecureStorage().getFaceEmbedding();
      if (cached != null) {
        try {
          final raw = jsonDecode(cached) as List<dynamic>;
          references = raw.isNotEmpty && raw.first is List
              ? raw
                  .map((item) => (item as List)
                      .map((value) => (value as num).toDouble())
                      .toList())
                  .toList()
              : [raw.map((value) => (value as num).toDouble()).toList()];
        } catch (_) {
          references = null;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _registeredEmbeddings = references ?? const [];
      _faceReferenceError = _registeredEmbeddings.isEmpty
          ? 'Data wajah belum tersedia. Daftarkan wajah terlebih dahulu.'
          : null;
      _liveSimilarity =
          _calculateBestSimilarity(_liveEmbedding, references ?? const []);
    });
    _scheduleAutomaticCapture();
  }

  String _shiftKey(Map<String, dynamic> shift) =>
      '${shift['assignment_id'] ?? 'default'}-${shift['template_id']}';

  Future<Map<String, dynamic>> _loadTodayInfo() async {
    final data = await context.read<AttendanceRepository>().getTodayInfo();
    final shifts = (data['shifts'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    Map<String, dynamic>? selected;
    for (final shift in shifts) {
      final attendance = shift['attendance'] as Map?;
      final canUse = widget.isCheckOut
          ? attendance != null &&
              attendance['check_in_time'] != null &&
              attendance['check_out_time'] == null
          : attendance == null;
      if (canUse) {
        selected = shift;
        break;
      }
    }
    if (mounted) {
      setState(() {
        _selectedShift = selected;
        _selectedShiftKey = selected == null ? null : _shiftKey(selected);
      });
    }
    _scheduleAutomaticCapture();
    return data;
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
        _scheduleAutomaticCapture();
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
        if (mounted) {
          setState(() => _locationStatus = "Gagal mendapatkan lokasi GPS.");
        }
        return;
      }

      if (!mounted) return;

      bool inRadius = true; // Fallback if no geofence data is available
      final companyState = context.read<CompanyCubit>().state;
      if (companyState is CompanyLoaded && companyState.geofence != null) {
        final geofence = companyState.geofence!;
        final double officeLat =
            double.tryParse(geofence['latitude']?.toString() ?? '') ?? 0.0;
        final double officeLng =
            double.tryParse(geofence['longitude']?.toString() ?? '') ?? 0.0;
        final double radius = double.tryParse(
                geofence['geofence_radius_meters']?.toString() ?? '') ??
            100.0;

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
            _isOutOfRadius = false;
            _locationStatus =
                "Terdeteksi Fake GPS! Harap matikan aplikasi lokasi palsu Anda.";
          } else {
            _isLocationValid = true; // allow check-in even outside radius
            _isOutOfRadius = !inRadius;
            _locationStatus = inRadius
                ? "Lokasi Sesuai Radius"
                : "Anda berada di luar radius absen kantor.";
          }
        });
      }

      // Reverse Geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
                position.latitude, position.longitude)
            .timeout(const Duration(seconds: 5));
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks[0];
          setState(() {
            _currentAddress =
                "${place.street}, ${place.subLocality}, ${place.locality}";
          });
        }
      } catch (e) {
        if (mounted) setState(() => _currentAddress = "Alamat tidak ditemukan");
      }
    } catch (e) {
      if (mounted) setState(() => _locationStatus = "Gagal mendapatkan lokasi");
    }
  }

  void _handleFaceValidation(
      bool isDetected, bool isProper, double angleY, bool isTooDark) {
    // For check-in, loosen angle restriction so it's not too strict
    bool isAngleCorrect = (isProper && angleY > -35 && angleY < 35);

    if (_isFaceDetected != isDetected ||
        _isFaceProper != isAngleCorrect ||
        _isTooDark != isTooDark) {
      setState(() {
        _isFaceDetected = isDetected;
        _isFaceProper = isAngleCorrect;
        _isTooDark = isTooDark;
      });
    }
    if (!isAngleCorrect || isTooDark || !isDetected) {
      _autoCaptureTimer?.cancel();
    } else {
      _scheduleAutomaticCapture();
    }
  }

  void _handleFaceEmbedding(List<double> embedding) {
    _liveEmbedding = embedding;
    final bestScore =
        _calculateBestSimilarity(embedding, _registeredEmbeddings);
    if (mounted && (_liveSimilarity - bestScore).abs() >= .005) {
      setState(() => _liveSimilarity = bestScore);
    }
    _scheduleAutomaticCapture();
  }

  double _calculateBestSimilarity(
    List<double> liveEmbedding,
    List<List<double>> references,
  ) {
    var bestScore = 0.0;
    for (final reference in references) {
      final score = FaceMatcherService.calculateCosineSimilarity(
          liveEmbedding, reference);
      if (score > bestScore) bestScore = score;
    }
    return bestScore;
  }

  bool get _isReadyForAutomaticCapture =>
      mounted &&
      _currentPosition != null &&
      _isLocationValid &&
      _selectedShift != null &&
      _isFaceDetected &&
      _isFaceProper &&
      !_isTooDark &&
      _liveEmbedding.isNotEmpty &&
      _registeredEmbeddings.isNotEmpty &&
      _liveSimilarity >= .80 &&
      !_isCapturing &&
      !_submissionStarted;

  void _scheduleAutomaticCapture() {
    if (!_isReadyForAutomaticCapture ||
        (_autoCaptureTimer?.isActive ?? false)) {
      return;
    }
    _autoCaptureTimer = Timer(const Duration(milliseconds: 1200), () {
      if (_isReadyForAutomaticCapture) _handleCheckIn();
    });
  }

  Future<void> _handleCheckIn() async {
    if (!_isReadyForAutomaticCapture) return;

    _autoCaptureTimer?.cancel();
    setState(() {
      _isCapturing = true;
      _submissionStarted = true;
    });
    await _cameraKey.currentState?.takePhoto();
  }

  void _onPhotoCaptured(XFile? file) async {
    if (file != null) {
      setState(() => _capturedImage = File(file.path));

      final storage = SecureStorage();
      final deviceId = await storage.getDeviceFingerprint() ?? 'unknown';

      final faceMatchScore = _calculateBestSimilarity(
        _liveEmbedding,
        _registeredEmbeddings,
      );

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
                  'is_out_of_radius': _isOutOfRadius,
                  'address': _currentAddress,
                  'is_overtime': widget.isOvertime,
                },
                shiftAssignmentId: _selectedShift?['assignment_id'] as int?,
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
                  'is_out_of_radius': _isOutOfRadius,
                  'address': _currentAddress,
                  'is_overtime': widget.isOvertime,
                },
                shiftAssignmentId: _selectedShift?['assignment_id'] as int?,
                shiftTemplateId: _selectedShift?['template_id'] as int?,
              );
        }
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _submissionStarted = false;
        _capturedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal mengambil foto wajah.'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _autoCaptureTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);
    final dateString = DateFormat('EEEE, d MMM y', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    context.go('/app/attendance/success',
                        extra: {'log': state.log, 'isCheckOut': false});
                  }
                } else if (state is CheckOutSuccess) {
                  if (mounted) {
                    context.go('/app/attendance/success',
                        extra: {'log': state.log, 'isCheckOut': true});
                  }
                } else if (state is AttendanceError) {
                  setState(() {
                    _isCapturing = false;
                    _submissionStarted = false;
                    _capturedImage = null;
                  });

                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24.r))),
                    builder: (context) => Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 48.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.r))),
                          SizedBox(height: 24.h),
                          Icon(Icons.error_outline,
                              size: 64.w, color: AppColors.error),
                          SizedBox(height: 16.h),
                          Text(
                              widget.isCheckOut
                                  ? 'Check-out Gagal'
                                  : 'Check-in Gagal',
                              style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface)),
                          SizedBox(height: 8.h),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14.sp)),
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r)),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Text(
                              widget.isCheckOut
                                  ? 'Absen Keluar'
                                  : 'Absen Masuk',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48.w),
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
                            Text(timeString,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1)),
                            Text(dateString,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 16.sp)),
                            SizedBox(height: 32.h),

                            // Floating Card for Camera
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(32.r),
                                border:
                                    Border.all(color: AppColors.outlineVariant),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10))
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Rectangular face scanner
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 300.w,
                                          height: 360.h,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(28.r),
                                            border: Border.all(
                                              color: _liveSimilarity >= .80
                                                  ? AppColors.primary
                                                  : (_isTooDark
                                                      ? AppColors.error
                                                      : Colors.grey[300]!),
                                              width: 4.w,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.r),
                                            child: _capturedImage != null
                                                ? Image.file(_capturedImage!,
                                                    fit: BoxFit.cover)
                                                : CameraPreviewWidget(
                                                    key: _cameraKey,
                                                    onFaceValidationChanged:
                                                        _handleFaceValidation,
                                                    onFaceEmbeddingGenerated:
                                                        _handleFaceEmbedding,
                                                    onPhotoCaptured:
                                                        _onPhotoCaptured,
                                                  ),
                                          ),
                                        )
                                            .animate(
                                                target: (_isFaceProper &&
                                                        !_isTooDark)
                                                    ? 1
                                                    : 0)
                                            .scale(
                                                duration: 300.ms,
                                                curve: Curves.easeOutBack,
                                                end:
                                                    const Offset(1.015, 1.015)),
                                        if (_isFaceProper &&
                                            !_isTooDark &&
                                            _capturedImage == null &&
                                            !isLoading)
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(26.r),
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 4.h,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color:
                                                              AppColors.primary,
                                                          boxShadow: [
                                                        BoxShadow(
                                                            color: AppColors
                                                                .primary,
                                                            blurRadius: 10)
                                                      ]),
                                                )
                                                    .animate(
                                                        onPlay: (c) => c.repeat(
                                                            reverse: true))
                                                    .moveY(
                                                        begin: 8.h,
                                                        end: 340.h,
                                                        duration: 1500.ms,
                                                        curve:
                                                            Curves.easeInOut),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24.h),

                                  // Status Text
                                  Text(
                                    _isTooDark
                                        ? 'Cahaya terlalu gelap'
                                        : _liveSimilarity >= .80
                                            ? 'Wajah cocok • ${(_liveSimilarity * 100).toStringAsFixed(0)}%'
                                            : _isFaceProper &&
                                                    _registeredEmbeddings
                                                        .isNotEmpty
                                                ? _liveEmbedding.isEmpty
                                                    ? 'Menganalisis detail wajah...'
                                                    : 'Mencocokkan wajah • ${(_liveSimilarity * 100).toStringAsFixed(0)}%'
                                                : _isFaceDetected
                                                    ? 'Arahkan wajah lurus ke depan'
                                                    : 'Wajah tidak terdeteksi',
                                    style: TextStyle(
                                      color: _isTooDark
                                          ? AppColors.error
                                          : (_isFaceProper
                                              ? AppColors.primary
                                              : Colors.grey[600]),
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
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          final data = snapshot.data!;
                                          final shifts =
                                              (data['shifts'] as List? ??
                                                      const [])
                                                  .map((item) =>
                                                      Map<String, dynamic>.from(
                                                          item as Map))
                                                  .toList();
                                          final availableShifts =
                                              shifts.where((shift) {
                                            final attendance =
                                                shift['attendance'] as Map?;
                                            return widget.isCheckOut
                                                ? attendance != null &&
                                                    attendance[
                                                            'check_in_time'] !=
                                                        null &&
                                                    attendance[
                                                            'check_out_time'] ==
                                                        null
                                                : attendance == null;
                                          }).toList();
                                          final role =
                                              Map<String, dynamic>.from(
                                                  data['role'] as Map? ?? {});
                                          return Container(
                                            margin:
                                                EdgeInsets.only(bottom: 12.h),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 12.h),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.surfaceContainerLow,
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              border: Border.all(
                                                  color:
                                                      AppColors.outlineVariant),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.work_outline,
                                                        color:
                                                            AppColors.primary,
                                                        size: 18.w),
                                                    SizedBox(width: 8.w),
                                                    Expanded(
                                                        child: Text(
                                                            role['employee_name']
                                                                    ?.toString() ??
                                                                'Karyawan',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.sp,
                                                                color: AppColors
                                                                    .onSurface))),
                                                  ],
                                                ),
                                                SizedBox(height: 5.h),
                                                Text(
                                                    '${role['department'] ?? 'Belum ada departemen'} • ${role['position'] ?? 'Belum ada jabatan'}',
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: AppColors
                                                            .onSurfaceVariant)),
                                                SizedBox(height: 12.h),
                                                if (availableShifts.isEmpty)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(10.w),
                                                    decoration: BoxDecoration(
                                                        color: AppColors
                                                            .warningAmber
                                                            .withValues(
                                                                alpha: .12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10.r)),
                                                    child: Text(shifts.isEmpty
                                                        ? 'Belum ada shift aktif. Hubungi admin untuk menugaskan shift sebelum melakukan absensi.'
                                                        : widget.isCheckOut
                                                            ? 'Tidak ada shift yang sedang menunggu absen keluar.'
                                                            : 'Semua shift hari ini sudah memiliki catatan absensi.'),
                                                  )
                                                else
                                                  DropdownButtonFormField<
                                                      String>(
                                                    initialValue:
                                                        _selectedShiftKey,
                                                    isExpanded: true,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText:
                                                                'Shift untuk absensi ini',
                                                            prefixIcon: Icon(
                                                                Icons
                                                                    .schedule)),
                                                    items: availableShifts
                                                        .map((shift) =>
                                                            DropdownMenuItem(
                                                              value: _shiftKey(
                                                                  shift),
                                                              child: Text(
                                                                  '${shift['name']} • ${shift['start_time']}–${shift['end_time']}'),
                                                            ))
                                                        .toList(),
                                                    onChanged: (key) {
                                                      setState(() {
                                                        _selectedShiftKey = key;
                                                        _selectedShift =
                                                            availableShifts
                                                                .firstWhere((shift) =>
                                                                    _shiftKey(
                                                                        shift) ==
                                                                    key);
                                                      });
                                                      _scheduleAutomaticCapture();
                                                    },
                                                  ),
                                                if (_selectedShift != null) ...[
                                                  SizedBox(height: 10.h),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          widget.isCheckOut
                                                              ? Icons.logout
                                                              : Icons.login,
                                                          color:
                                                              Colors.grey[700],
                                                          size: 16.w),
                                                      SizedBox(width: 6.w),
                                                      Expanded(
                                                          child: Text(
                                                              widget.isCheckOut
                                                                  ? 'Jadwal pulang ${_selectedShift!['end_time']}'
                                                                  : 'Jadwal masuk ${_selectedShift!['start_time']} • pulang ${_selectedShift!['end_time']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  color: Colors
                                                                          .grey[
                                                                      800]))),
                                                      Text(
                                                          _selectedShift![
                                                                      'time_status_label']
                                                                  ?.toString() ??
                                                              '',
                                                          style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: AppColors
                                                                  .primary)),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          );
                                        }
                                        return Container(
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                              color: AppColors.error
                                                  .withValues(alpha: .08),
                                              borderRadius:
                                                  BorderRadius.circular(12.r)),
                                          child: const Text(
                                              'Informasi shift gagal dimuat. Periksa koneksi lalu buka ulang halaman.'),
                                        );
                                      }),

                                  // Location Indicator (Compact inside card)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: _isLocationValid
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : AppColors.error
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            _isLocationValid
                                                ? Icons.check_circle
                                                : Icons.location_off,
                                            color: _isLocationValid
                                                ? Colors.green
                                                : AppColors.error,
                                            size: 24.w),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(_locationStatus,
                                                  style: TextStyle(
                                                      color: _isLocationValid
                                                          ? Colors.green[800]
                                                          : AppColors.error,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.sp)),
                                              Text(_currentAddress,
                                                  style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 11.sp),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 24.h),

                                  // Automatic capture status
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18.w, vertical: 15.h),
                                    decoration: BoxDecoration(
                                      color: isLoading
                                          ? AppColors.primary
                                          : AppColors.primary
                                              .withValues(alpha: .10),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: .28)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (isLoading)
                                          SizedBox(
                                              height: 22.w,
                                              width: 22.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2))
                                        else
                                          Icon(Icons.center_focus_strong,
                                              color: AppColors.primary,
                                              size: 22.w),
                                        SizedBox(width: 10.w),
                                        Flexible(
                                          child: Text(
                                            isLoading
                                                ? 'Memverifikasi dan mengirim absensi...'
                                                : _faceReferenceError != null
                                                    ? _faceReferenceError!
                                                    : _isReadyForAutomaticCapture
                                                        ? 'Tahan posisi, foto diambil otomatis'
                                                        : 'Siap otomatis setelah wajah, lokasi, dan shift valid',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: isLoading
                                                  ? Colors.white
                                                  : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
