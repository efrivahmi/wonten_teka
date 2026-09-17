import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceDisputeScreen extends StatefulWidget {
  const AttendanceDisputeScreen({super.key});
  @override
  State<AttendanceDisputeScreen> createState() =>
      _AttendanceDisputeScreenState();
}

class _AttendanceDisputeScreenState extends State<AttendanceDisputeScreen> {
  String _selectedReason = 'Lupa Check-out';
  final _notesController = TextEditingController();
  final _reasons = [
    'Lupa Check-out',
    'Lupa Check-in',
    'Lokasi Tidak Terdeteksi',
    'Masalah Teknis',
    'Lainnya'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
          title: const AppBrandTitle(section: 'Dispute Absensi'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Date display
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.warningAmber, size: 24.w),
                SizedBox(width: 12.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Senin, 7 Juli 2025',
                      style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp)),
                  Text('Check-out tidak tercatat',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                ]),
              ]),
            ),
            SizedBox(height: 24.h),

            Text('ALASAN DISPUTE',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason,
              items: _reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedReason = v);
              },
              decoration: _inputDeco('Pilih alasan'),
            ),
            SizedBox(height: 24.h),

            Text('WAKTU SEBENARNYA',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      decoration: _inputDeco('08:00'), initialValue: '08:00')),
              SizedBox(width: 12.w),
              Text('—',
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 18.sp)),
              SizedBox(width: 12.w),
              Expanded(
                  child: TextFormField(
                      decoration: _inputDeco('17:00'), initialValue: '17:00')),
            ]),
            SizedBox(height: 24.h),

            Text('CATATAN',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            SizedBox(height: 8.h),
            TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDeco('Jelaskan detail dispute...')),
            SizedBox(height: 24.h),

            Text('BUKTI PENDUKUNG (OPSIONAL)',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color:
                            AppColors.outlineVariant.withValues(alpha: 0.5))),
                child: Column(children: [
                  Icon(Icons.cloud_upload_outlined,
                      color: AppColors.onSurfaceVariant, size: 32.w),
                  SizedBox(height: 8.h),
                  Text('Tap untuk upload',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                ]),
              ),
            ),
            SizedBox(height: 32.h),

            SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Dispute berhasil dikirim!')));
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                      
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r))),
                  child: Text('Kirim Dispute',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16.sp)),
                )),
          ]),
        ),
      ),
    ));
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.primaryContainer)),
      );
}

