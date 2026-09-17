import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/success_submission_screen.dart';

class AttendanceAdjustmentFormScreen extends StatefulWidget {
  const AttendanceAdjustmentFormScreen({super.key});
  @override
  State<AttendanceAdjustmentFormScreen> createState() =>
      _AttendanceAdjustmentFormScreenState();
}

class _AttendanceAdjustmentFormScreenState
    extends State<AttendanceAdjustmentFormScreen> {
  final _key = GlobalKey<FormState>();
  ApiClient get _api => context.read<ApiClient>();
  final _date = TextEditingController(),
      _in = TextEditingController(),
      _out = TextEditingController(),
      _reason = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _date.dispose();
    _in.dispose();
    _out.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _datePicker() async {
    final d = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 1)),
        firstDate: DateTime.now().subtract(const Duration(days: 90)),
        lastDate: DateTime.now());
    if (d != null) _date.text = d.toIso8601String().split('T').first;
  }

  Future<void> _timePicker(TextEditingController c) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (t != null) {
      c.text =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.post('/attendance/adjustment', data: {
        'date': _date.text,
        'check_in': _in.text,
        'check_out': _out.text,
        'reason': _reason.text.trim()
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SuccessSubmissionScreen(
                title: 'Koreksi Kehadiran Berhasil!',
                message: 'Pengajuan koreksi absensi Anda telah dicatat dalam sistem dan saat ini sedang menunggu persetujuan dari atasan atau HRD.',
              ),
            ),
          );
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(child: Text(e.message, style: const TextStyle(color: Colors.white))),
              ],
            ),
            backgroundColor: AppColors.errorCrimson,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const AppBrandTitle(section: 'Koreksi Absensi'),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BrandPageBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('Lupa absen',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  SizedBox(height: 8.h),
                  Text(
                      'Tambahkan waktu masuk dan keluar yang seharusnya. Setelah dikirim, pengajuan tidak dapat diedit atau dihapus.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                  SizedBox(height: 24.h),
                  Text('Tanggal', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                      controller: _date,
                      readOnly: true,
                      onTap: _datePicker,
                      decoration: InputDecoration(
                          hintText: 'Pilih Tanggal',
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                          suffixIcon: const Icon(Icons.calendar_month, color: AppColors.primary)),
                      validator: _required),
                  SizedBox(height: 16.h),
                  Row(children: [
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Masuk', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            TextFormField(
                                controller: _in,
                                readOnly: true,
                                onTap: () => _timePicker(_in),
                                decoration: InputDecoration(
                                  hintText: '08:00',
                                  filled: true, fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                ),
                                validator: _required),
                          ],
                        )),
                    SizedBox(width: 16.w),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Keluar', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            TextFormField(
                                controller: _out,
                                readOnly: true,
                                onTap: () => _timePicker(_out),
                                decoration: InputDecoration(
                                  hintText: '17:00',
                                  filled: true, fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                ),
                                validator: _required),
                          ],
                        ))
                  ]),
                  SizedBox(height: 16.h),
                  Text('Alasan Lupa Absen / Kesalahan', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                      controller: _reason,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Jelaskan alasan secara singkat',
                        filled: true, fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                      ),
                      validator: _required),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))
                        ),
                        child: _saving
                            ? SizedBox(height: 24.h, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Kirim Pengajuan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
                  ),
                ]),
            ),
          ),
        ),
      ));
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}
