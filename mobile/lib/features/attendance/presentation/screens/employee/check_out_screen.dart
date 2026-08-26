import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/attendance_cubit.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  Position? _currentPosition;
  String _currentAddress = 'Mencari lokasi...';
  bool _isLoadingLocation = true;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'GPS tidak aktif';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Izin lokasi ditolak';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      setState(() {
        _currentPosition = position;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}';
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _currentAddress = 'Lokasi ditemukan';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Gagal mendapatkan lokasi';
        _isLoadingLocation = false;
      });
    }
  }

  void _performCheckOut() {
    if (_currentPosition == null) return;
    
    setState(() => _isCheckingOut = true);
    
    context.read<AttendanceCubit>().checkOut(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );
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
                if (state is CheckOutSuccess) {
                  context.go('/app/attendance/success', extra: {'log': state.log, 'isCheckOut': true});
                } else if (state is AttendanceError) {
                  setState(() => _isCheckingOut = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
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
                              'Absen Keluar',
                              style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48.w), // Balance for centering
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 16.h),
                            Text(timeString, style: TextStyle(color: Colors.white, fontSize: 48.sp, fontWeight: FontWeight.bold, letterSpacing: -1)),
                            Text(dateString, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16.sp)),
                            SizedBox(height: 32.h),
                            
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32.r),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(24.w),
                                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                                    child: Icon(Icons.exit_to_app_rounded, size: 64.w, color: AppColors.error),
                                  ),
                                  SizedBox(height: 24.h),
                                  Text('Konfirmasi Pulang', style: TextStyle(color: AppColors.onSurface, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8.h),
                                  Text('Pastikan Anda sudah menyelesaikan semua pekerjaan hari ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                                  
                                  SizedBox(height: 24.h),
                                  
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey[200]!)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on, color: AppColors.primary, size: 24.w),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Lokasi Saat Ini', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                                              SizedBox(height: 4.h),
                                              _isLoadingLocation
                                                  ? SizedBox(height: 12.w, width: 12.w, child: const CircularProgressIndicator(strokeWidth: 2))
                                                  : Text(_currentAddress, style: TextStyle(color: Colors.grey[600], fontSize: 11.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 32.h),
                                  
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56.h,
                                    child: ElevatedButton(
                                      onPressed: (_currentPosition == null || _isCheckingOut) ? null : _performCheckOut,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                        elevation: 0,
                                      ),
                                      child: _isCheckingOut
                                          ? SizedBox(height: 24.w, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text('Akhiri Shift (Check-Out)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
