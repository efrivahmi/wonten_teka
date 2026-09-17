import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/success_submission_screen.dart';

class BusinessTripFormScreen extends StatefulWidget {
  const BusinessTripFormScreen({super.key});
  @override
  State<BusinessTripFormScreen> createState() => _BusinessTripFormScreenState();
}

class _BusinessTripFormScreenState extends State<BusinessTripFormScreen> {
  final _key = GlobalKey<FormState>();
  ApiClient get _api => context.read<ApiClient>();
  final _start = TextEditingController(),
      _end = TextEditingController(),
      _location = TextEditingController(),
      _description = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(TextEditingController c, {DateTime? first}) async {
    final now = DateTime.now();
    final d = await showDatePicker(
        context: context,
        initialDate: first ?? now,
        firstDate: first ?? now,
        lastDate: now.add(const Duration(days: 730)));
    if (d != null) c.text = d.toIso8601String().split('T').first;
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.post('/attendance/business-trip', data: {
        'start_date': _start.text,
        'end_date': _end.text,
        'location': _location.text.trim(),
        'description': _description.text.trim()
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SuccessSubmissionScreen(
                title: 'Pengajuan Dinas Berhasil!',
                message: 'Pengajuan dinas luar Anda telah dicatat dalam sistem dan saat ini sedang menunggu persetujuan.',
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
        title: const AppBrandTitle(section: 'Pengajuan Dinas'),
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
                  Text('Rencana perjalanan',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  SizedBox(height: 8.h),
                  Text(
                      'Dinas luar yang disetujui akan dicatat sebagai kehadiran.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                  SizedBox(height: 24.h),
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Mulai', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          TextFormField(
                              controller: _start,
                              readOnly: true,
                              onTap: () => _pick(_start),
                              decoration: InputDecoration(
                                  hintText: 'Pilih Tanggal',
                                  filled: true, fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                  suffixIcon: const Icon(Icons.calendar_month, color: AppColors.primary)),
                              validator: _required),
                        ],
                      )
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Selesai', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          TextFormField(
                              controller: _end,
                              readOnly: true,
                              onTap: () =>
                                  _pick(_end, first: DateTime.tryParse(_start.text)),
                              decoration: InputDecoration(
                                  hintText: 'Pilih Tanggal',
                                  filled: true, fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                  suffixIcon: const Icon(Icons.calendar_month, color: AppColors.primary)),
                              validator: _required),
                        ],
                      )
                    )
                  ]),
                  SizedBox(height: 16.h),
                  Text('Lokasi Tujuan', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                      controller: _location,
                      decoration: InputDecoration(
                          hintText: 'Masukkan nama kota / lokasi',
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary)),
                      validator: _required),
                  SizedBox(height: 16.h),
                  Text('Keperluan Dinas', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  TextFormField(
                      controller: _description,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Jelaskan kegiatan dinas luar',
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
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
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
