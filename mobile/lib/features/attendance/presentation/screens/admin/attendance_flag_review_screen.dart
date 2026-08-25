import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';

class AttendanceFlagReviewScreen extends StatefulWidget {
  const AttendanceFlagReviewScreen({super.key});

  @override
  State<AttendanceFlagReviewScreen> createState() =>
      _AttendanceFlagReviewScreenState();
}

class _AttendanceFlagReviewScreenState
    extends State<AttendanceFlagReviewScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<dynamic> _flags = [];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/admin/attendance-flags');
      if (mounted) {
        setState(() {
          _flags = response.data['data'] as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showResolveDialog(Map<String, dynamic> flag, bool isApprove) {
    final noteController = TextEditingController();
    bool isSaving = false;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isApprove ? 'Terima Absensi?' : 'Tolak Absensi?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isApprove
                        ? 'Apakah Anda yakin ingin menerima absensi ini? Status absensi akan diubah menjadi Hadir/Valid.'
                        : 'Apakah Anda yakin ingin menolak absensi ini? Status absensi akan dianggap Tidak Valid/Alpha.',
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(ctx),
                    child: const Text('Batal')),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            await _api.post(
                                '/admin/attendance-flags/${flag['id']}/resolve',
                                data: {
                                  'action': isApprove ? 'approve' : 'reject',
                                  'notes': noteController.text,
                                });
                            if (mounted) {
                              Navigator.pop(ctx);
                              _loadFlags();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Absensi berhasil ${isApprove ? 'diterima' : 'ditolak'}')));
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApprove
                        ? AppColors.successEmerald
                        : AppColors.errorCrimson,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(isApprove ? 'Terima' : 'Tolak'),
                ),
              ],
            );
          });
        });
  }

  String _formatFlags(List<dynamic>? flags) {
    if (flags == null || flags.isEmpty) return 'Anomali';
    return flags.join(', ').replaceAll('_', ' ').toUpperCase();
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
              onPressed: () => context.pop()),
          title: Text('Review Anomali',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flags.isEmpty
              ? const Center(
                  child: Text('Tidak ada anomali absensi untuk di-review'))
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _flags.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) {
                    final f = _flags[i];
                    final empName = f['employee']?['full_name'] ?? 'Unknown';
                    final checkInAt = f['check_in_at'] != null
                        ? DateFormat('dd MMM yyyy HH:mm')
                            .format(DateTime.parse(f['check_in_at']))
                        : '-';

                    return InfoCard(
                      borderLeftColor: AppColors.warningAmber,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(empName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp)),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                          color: AppColors.warningAmber
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8.r)),
                                      child: Text(
                                          _formatFlags(
                                              f['flags'] as List<dynamic>?),
                                          style: TextStyle(
                                              color: AppColors.warningAmber,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold))),
                                ]),
                            SizedBox(height: 8.h),
                            Text('Waktu Check In: $checkInAt',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12.sp)),
                            if (f['check_out_at'] != null)
                              Text(
                                  'Waktu Check Out: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(f['check_out_at']))}',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12.sp)),
                            if (f['notes'] != null &&
                                (f['notes'] as String).isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text('Catatan Karyawan: ${f['notes']}',
                                    style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12.sp,
                                        fontStyle: FontStyle.italic)),
                              ),
                            SizedBox(height: 12.h),
                            Row(children: [
                              Expanded(
                                  child: OutlinedButton(
                                      onPressed: () =>
                                          _showResolveDialog(f, false),
                                      style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppColors.errorCrimson,
                                          side: const BorderSide(
                                              color: AppColors.errorCrimson)),
                                      child: const Text('Tolak'))),
                              SizedBox(width: 12.w),
                              Expanded(
                                  child: ElevatedButton(
                                      onPressed: () =>
                                          _showResolveDialog(f, true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.successEmerald,
                                          foregroundColor: Colors.white),
                                      child: const Text('Terima'))),
                            ]),
                          ]),
                    );
                  }),
    );
  }
}

