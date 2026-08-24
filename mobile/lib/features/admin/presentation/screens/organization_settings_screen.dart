import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/repositories/company_repository.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationSettingsScreen> createState() => _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState extends State<OrganizationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadGeofence();
  }

  Future<void> _loadGeofence() async {
    try {
      final repo = context.read<CompanyRepository>();
      final data = await repo.getGeofence();
      setState(() {
        _latController.text = data['latitude']?.toString() ?? '';
        _lngController.text = data['longitude']?.toString() ?? '';
        _radiusController.text = data['geofence_radius_meters']?.toString() ?? '50';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil data geofence')));
      }
    }
  }

  Future<void> _saveGeofence() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final repo = context.read<CompanyRepository>();
      await repo.updateGeofence(
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        radius: double.parse(_radiusController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geofence berhasil diperbarui!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui geofence')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface, 
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Pengaturan Geofence', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    borderLeftColor: AppColors.infoCerulean,
                    child: Text(
                      'Tentukan koordinat pusat kantor dan radius maksimal untuk mengizinkan absensi karyawan.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text('Latitude', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      hintText: '-6.200000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16.h),
                  Text('Longitude', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      hintText: '106.816666',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16.h),
                  Text('Radius Jarak (Meter)', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '50',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(val) == null) return 'Format angka tidak valid';
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveGeofence,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
