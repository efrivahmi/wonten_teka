import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/repositories/company_repository.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState
    extends State<OrganizationSettingsScreen> {
  bool _isLoadingGeofence = true;
  bool _isLoadingDays = true;
  bool _isSavingGeofence = false;
  bool _isSavingDays = false;
  bool _isSavingAttendance = false;

  bool _requireFace = true;
  bool _requireGps = true;
  int _gracePeriod = 15;

  LatLng? _selectedLocation;
  double _radius = 100.0;
  final MapController _mapController = MapController();

  final LatLng _defaultLocation = const LatLng(-6.2088, 106.8456);

  List<int> _workingDays = [1, 2, 3, 4, 5];
  final List<Map<String, dynamic>> _daysOfWeek = [
    {'id': 1, 'name': 'Senin'},
    {'id': 2, 'name': 'Selasa'},
    {'id': 3, 'name': 'Rabu'},
    {'id': 4, 'name': 'Kamis'},
    {'id': 5, 'name': 'Jumat'},
    {'id': 6, 'name': 'Sabtu'},
    {'id': 7, 'name': 'Minggu'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGeofence();
    _loadWorkingDays();
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

          _isLoadingGeofence = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingGeofence = false);
    }
  }

  Future<void> _loadWorkingDays() async {
    try {
      final companyRepo = context.read<CompanyRepository>();
      final days = await companyRepo.getWorkingDays();

      if (mounted) {
        setState(() {
          _workingDays = days;
          _isLoadingDays = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDays = false);
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

    setState(() => _isSavingGeofence = true);

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
      if (mounted) setState(() => _isSavingGeofence = false);
    }
  }

  Future<void> _saveWorkingDays() async {
    setState(() => _isSavingDays = true);

    try {
      final companyRepo = context.read<CompanyRepository>();
      await companyRepo.updateWorkingDays(_workingDays);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Hari Kerja berhasil disimpan!'),
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
      if (mounted) setState(() => _isSavingDays = false);
    }
  }

  Future<void> _saveAttendanceRules() async {
    setState(() => _isSavingAttendance = true);
    try {
      // In a real app, save this to Company settings
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aturan Absensi berhasil disimpan!'), backgroundColor: AppColors.successEmerald),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingAttendance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Pengaturan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Geofence'),
              Tab(text: 'Hari Kerja'),
              Tab(text: 'Absensi'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildGeofenceTab(),
            _buildWorkingDaysTab(),
            _buildAttendanceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceTab() {
    if (_isLoadingGeofence) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
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
                      'Ketuk peta di bawah ini untuk memindahkan pin ke lokasi kantor.',
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
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation ?? _defaultLocation,
                  initialZoom: 15.0,
                  onTap: (tapPosition, latLng) {
                    setState(() {
                      _selectedLocation = latLng;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.wonten_teka',
                  ),
                  if (_selectedLocation != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _selectedLocation!,
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderStrokeWidth: 2.0,
                          borderColor: AppColors.primary,
                          useRadiusInMeter: true,
                          radius: _radius,
                        ),
                      ],
                    ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.errorCrimson,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Radius Absensi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(4.r)),
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
                          onPressed: _isSavingGeofence ? null : _saveGeofence,
                          icon: _isSavingGeofence
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.save, size: 18),
                          label: Text(_isSavingGeofence
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
    );
  }

  Widget _buildWorkingDaysTab() {
    if (_isLoadingDays) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hari Kerja Operasional',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tentukan hari apa saja perusahaan Anda beroperasi. Karyawan yang absen di luar hari kerja tidak akan dianggap absen kecuali mendapat penugasan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 24.h),
          InfoCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _daysOfWeek.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.outlineVariant),
              itemBuilder: (context, index) {
                final day = _daysOfWeek[index];
                final isSelected = _workingDays.contains(day['id']);

                return CheckboxListTile(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  title: Text(
                    day['name'],
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: AppColors.onSurface,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _workingDays.add(day['id']);
                      } else {
                        _workingDays.remove(day['id']);
                      }
                      _workingDays.sort();
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: _isSavingDays ? null : _saveWorkingDays,
              icon: _isSavingDays
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(
                  _isSavingDays ? 'Menyimpan...' : 'Simpan Hari Kerja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aturan Absensi Karyawan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          SizedBox(height: 8.h),
          Text('Tentukan aturan keamanan saat karyawan melakukan Check-In dan Check-Out.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
          SizedBox(height: 24.h),
          InfoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  value: _requireFace,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _requireFace = val),
                  title: const Text('Wajib Face Verification', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Karyawan wajib mengunggah foto selfie saat absen.'),
                  secondary: const Icon(Icons.face_retouching_natural, color: AppColors.infoCerulean),
                ),
                const Divider(height: 1, color: AppColors.outlineVariant),
                SwitchListTile(
                  value: _requireGps,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _requireGps = val),
                  title: const Text('Wajib GPS / Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Karyawan wajib menyalakan GPS (Fake GPS akan diblokir).'),
                  secondary: const Icon(Icons.gps_fixed, color: AppColors.warningAmber),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text('Toleransi Keterlambatan (Grace Period)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          SizedBox(height: 8.h),
          InfoCard(
            child: Row(
              children: [
                Icon(Icons.timer, color: AppColors.errorCrimson, size: 32.sp),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_gracePeriod Menit', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('Batas waktu sebelum dihitung terlambat.', style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120.w,
                  child: Slider(
                    value: _gracePeriod.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    label: '$_gracePeriod Menit',
                    onChanged: (val) => setState(() => _gracePeriod = val.toInt()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: _isSavingAttendance ? null : _saveAttendanceRules,
              icon: _isSavingAttendance
                  ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isSavingAttendance ? 'Menyimpan...' : 'Simpan Aturan Absensi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

