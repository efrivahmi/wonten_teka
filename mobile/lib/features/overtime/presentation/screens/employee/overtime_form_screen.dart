import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/success_submission_screen.dart';

class OvertimeFormScreen extends StatefulWidget {
  const OvertimeFormScreen({super.key});
  @override
  State<OvertimeFormScreen> createState() => _OvertimeFormScreenState();
}

class _OvertimeFormScreenState extends State<OvertimeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  ApiClient get _api => context.read<ApiClient>();
  final _date = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _reason = TextEditingController();
  String _type = 'Hari Kerja';
  bool _saving = false;

  @override
  void dispose() {
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (value != null) _date.text = value.toIso8601String().split('T').first;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final value =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (value != null) {
      controller.text =
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.post('/overtime/request', data: {
        'date': _date.text,
        'start_time': _start.text,
        'end_time': _end.text,
        'overtime_type': _type,
        'reason': _reason.text.trim()
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SuccessSubmissionScreen(
                title: 'Pengajuan Lembur Berhasil!',
                message: 'Pengajuan lembur Anda telah dicatat dalam sistem dan saat ini sedang menunggu persetujuan.',
              ),
            ),
          );
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(child: Text(error.message, style: const TextStyle(color: Colors.white))),
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
          title: const AppBrandTitle(section: 'Pengajuan Lembur'),
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Detail pekerjaan',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    SizedBox(height: 8.h),
                    Text(
                        'Lengkapi waktu dan pekerjaan yang memerlukan persetujuan.',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                    SizedBox(height: 24.h),
                    Text('Tanggal', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    TextFormField(
                        controller: _date,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                            hintText: 'Pilih Tanggal',
                            filled: true, fillColor: Colors.grey[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                            suffixIcon: const Icon(Icons.calendar_month, color: AppColors.primary)),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Tanggal wajib dipilih' : null),
                    SizedBox(height: 16.h),
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Mulai', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            TextFormField(
                                controller: _start,
                                readOnly: true,
                                onTap: () => _pickTime(_start),
                                decoration: InputDecoration(
                                    hintText: '17:00',
                                    filled: true, fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Wajib' : null),
                          ],
                        )
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Selesai', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            TextFormField(
                                controller: _end,
                                readOnly: true,
                                onTap: () => _pickTime(_end),
                                decoration: InputDecoration(
                                    hintText: '20:00',
                                    filled: true, fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Wajib' : null),
                          ],
                        )
                      )
                    ]),
                    SizedBox(height: 16.h),
                    Text('Jenis Lembur', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: InputDecoration(
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Hari Kerja', child: Text('Hari Kerja')),
                          DropdownMenuItem(
                              value: 'Hari Libur', child: Text('Hari Libur'))
                        ],
                        onChanged: (v) => setState(() => _type = v!)),
                    SizedBox(height: 16.h),
                    Text('Pekerjaan / Alasan', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    TextFormField(
                        controller: _reason,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan pekerjaan yang diselesaikan',
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Pekerjaan wajib dijelaskan'
                            : null),
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
        ),
      );
}
