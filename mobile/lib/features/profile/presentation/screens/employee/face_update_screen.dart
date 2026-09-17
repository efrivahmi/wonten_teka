import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/repositories/attendance_repository.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class FaceUpdateScreen extends StatefulWidget {
  const FaceUpdateScreen({super.key});

  @override
  State<FaceUpdateScreen> createState() => _FaceUpdateScreenState();
}

class _FaceUpdateScreenState extends State<FaceUpdateScreen> {
  late Future<Map<String, dynamic>> _status;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _status = context.read<AttendanceRepository>().getFaceStatus();
  }

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    return parsed == null
        ? 'Belum pernah diperbarui'
        : DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Data Wajah Saya'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _status,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => setState(_reload),
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang Data Wajah'),
              ),
            );
          }
          final data = snapshot.data ?? const <String, dynamic>{};
          final mobile =
              Map<String, dynamic>.from(data['mobile'] as Map? ?? {});
          final available = mobile['available'] == true;
          final poseCount = mobile['pose_count'] ?? 0;
          return ListView(
            padding: EdgeInsets.all(24.w),
            children: [
              Center(
                child: Container(
                  width: 160.w,
                  height: 190.w,
                  decoration: BoxDecoration(
                    color: available
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: Icon(
                    available ? Icons.face : Icons.face_retouching_off,
                    size: 92.w,
                    color: available
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                available ? 'Wajah sudah terdaftar' : 'Wajah belum lengkap',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                '$poseCount pose tersimpan • ${_date(data['enrolled_at'])}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 24.h),
              const InfoCard(
                borderLeftColor: AppColors.primary,
                child: Text(
                  'Demi keamanan, aplikasi menyimpan pola wajah terenkripsi, bukan foto asli. Rekam ulang jika perubahan wajah membuat absensi sulit dikenali.',
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: () async {
                    await context.push('/face-enrollment');
                    if (mounted) setState(_reload);
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(available
                      ? 'Ganti Wajah Terdaftar'
                      : 'Daftarkan Wajah Sekarang'),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}
