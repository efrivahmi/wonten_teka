import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/repositories/company_repository.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState
    extends State<OrganizationSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  LatLng? _selectedLocation;
  double _radius = 100.0;
  GoogleMapController? _mapController;

  // Default fallback (Jakarta)
  final LatLng _defaultLocation = const LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _loadGeofence();
  }

  Future<void> _loadGeofence() async {
    try {
      final companyRepo = context.read<CompanyRepository>();
      final geofence = await companyRepo.getGeofence();

      if (mounted) {
        setState(() {
          final lat = geofence['latitude'];
          final lng = geofence['longitude'];

          if (lat != null && lng != null) {
            _selectedLocation = LatLng(
                double.tryParse(lat.toString()) ?? _defaultLocation.latitude,
                double.tryParse(lng.toString()) ?? _defaultLocation.longitude);
          }

          final r = geofence['geofence_radius_meters'];
          if (r != null) {
            _radius = double.tryParse(r.toString()) ?? 100.0;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGeofence() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Silakan tentukan titik koordinat di peta terlebih dahulu'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final companyRepo = context.read<CompanyRepository>();
      await companyRepo.updateGeofence(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        radius: _radius,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Geofence berhasil disimpan!'),
              backgroundColor: AppColors.successEmerald),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      controller
          .animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Geofence & Lokasi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info Card Area
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,
                          color: AppColors.errorCrimson, size: 24.w),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Titik Lokasi Kantor',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Ketuk peta di bawah ini untuk memindahkan pin ke lokasi kantor Anda.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Map Area
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? _defaultLocation,
                          zoom: 15,
                        ),
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onTap: (latLng) {
                          setState(() {
                            _selectedLocation = latLng;
                          });
                        },
                        markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('office_location'),
                                  position: _selectedLocation!,
                                  infoWindow:
                                      const InfoWindow(title: 'Lokasi Kantor'),
                                )
                              }
                            : {},
                        circles: _selectedLocation != null
                            ? {
                                Circle(
                                  circleId: const CircleId('geofence_radius'),
                                  center: _selectedLocation!,
                                  radius: _radius,
                                  fillColor:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  strokeColor: AppColors.primary,
                                  strokeWidth: 2,
                                )
                              }
                            : {},
                      ),

                      // Radius Slider Floating Panel
                      Positioned(
                        bottom: 16.h,
                        left: 16.w,
                        right: 16.w,
                        child: InfoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Radius Absensi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(4.r)),
                                    child: Text(
                                      '${_radius.toInt()} meter',
                                      style: TextStyle(
                                          color: AppColors.onPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Slider(
                                value: _radius,
                                min: 10,
                                max: 1000,
                                divisions: 99,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.outlineVariant,
                                onChanged: (val) {
                                  setState(() {
                                    _radius = val;
                                  });
                                },
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                width: double.infinity,
                                height: 44.h,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveGeofence,
                                  icon: _isSaving
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.w,
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2))
                                      : const Icon(Icons.save, size: 18),
                                  label: Text(_isSaving
                                      ? 'Menyimpan...'
                                      : 'Simpan Geofence'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
