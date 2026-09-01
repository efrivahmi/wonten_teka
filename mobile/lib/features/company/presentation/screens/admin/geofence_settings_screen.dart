import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/company_cubit.dart';
// Note: In a real app we'd use flutter_map and latlong2 here. 
// For now, this is a placeholder UI for the Geofence setup as requested.

class GeofenceSettingsScreen extends StatefulWidget {
  const GeofenceSettingsScreen({super.key});

  @override
  State<GeofenceSettingsScreen> createState() => _GeofenceSettingsScreenState();
}

class _GeofenceSettingsScreenState extends State<GeofenceSettingsScreen> {
  double _radius = 50.0;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default values or load from company
    final state = context.read<CompanyCubit>().state;
    if (state is CompanyLoaded && state.geofence != null) {
      final geofence = state.geofence!;
      if (geofence['latitude'] != null) _latController.text = geofence['latitude'].toString();
      if (geofence['longitude'] != null) _lngController.text = geofence['longitude'].toString();
      if (geofence['geofence_radius_meters'] != null) _radius = double.tryParse(geofence['geofence_radius_meters'].toString()) ?? 50.0;
    }
  }

  void _saveGeofence() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude dan Longitude harus berupa angka yang valid'), backgroundColor: AppColors.errorCrimson),
      );
      return;
    }
    
    try {
      await context.read<CompanyCubit>().updateGeofence(
        latitude: lat,
        longitude: lng,
        radius: _radius,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan Geofence Berhasil Disimpan'), backgroundColor: AppColors.successEmerald),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan geofence: $e'), backgroundColor: AppColors.errorCrimson),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Geofence'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on, color: AppColors.primary, size: 24.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          'Titik Pusat Absensi',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48.sp, color: Colors.grey[400]),
                          SizedBox(height: 12.h),
                          Text('Peta Interaktif (Google Maps)', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          Text('Drag marker untuk mengatur lokasi', style: TextStyle(color: Colors.grey[500], fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            labelText: 'Latitude',
                            labelStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            prefixIcon: const Icon(Icons.explore),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            labelStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            prefixIcon: const Icon(Icons.explore_off),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.infoCerulean.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.radar, color: AppColors.infoCerulean, size: 24.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Radius Geofence',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Toleransi jarak dari titik pusat',
                              style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_radius.toInt()} m',
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8.h,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      valueIndicatorColor: AppColors.primary,
                    ),
                    child: Slider(
                      value: _radius,
                      min: 10,
                      max: 500,
                      divisions: 49,
                      label: '${_radius.toInt()} m',
                      onChanged: (val) => setState(() => _radius = val),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('10 m', style: TextStyle(color: Colors.grey[500], fontSize: 12.sp)),
                      Text('500 m', style: TextStyle(color: Colors.grey[500], fontSize: 12.sp)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: _saveGeofence,
                child: Text('Simpan Konfigurasi Lokasi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
