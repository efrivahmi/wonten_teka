import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/api_client.dart';

class PayrollRunListScreen extends StatefulWidget {
  const PayrollRunListScreen({super.key});

  @override
  State<PayrollRunListScreen> createState() => _PayrollRunListScreenState();
}

class _PayrollRunListScreenState extends State<PayrollRunListScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<dynamic> _runs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.get('/admin/payroll/runs');
      final data = response.data['data'] as List;
      setState(() {
        _runs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat riwayat payroll: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePayroll(int month, int year) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()));
      await _api.post('/admin/payroll/runs', data: {
        'period_month': month,
        'period_year': year,
      });
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Payroll berhasil digenerate'),
            backgroundColor: AppColors.successEmerald));
        _loadRuns();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal generate payroll: $e'),
            backgroundColor: AppColors.errorCrimson));
      }
    }
  }

  void _showGenerateDialog() {
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Generate Payroll Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Pilih periode bulan dan tahun untuk kalkulasi massal.'),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Bulan',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                          ),
                          initialValue: selectedMonth,
                          items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                  value: i + 1, child: Text('${i + 1}'))),
                          onChanged: (v) => setState(() => selectedMonth = v!),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Tahun',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                          ),
                          initialValue: selectedYear,
                          items: List.generate(5, (i) {
                            final y = DateTime.now().year - 2 + i;
                            return DropdownMenuItem(
                                value: y, child: Text('$y'));
                          }),
                          onChanged: (v) => setState(() => selectedYear = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _generatePayroll(selectedMonth, selectedYear);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary),
                  child: const Text('Proses'),
                ),
              ],
            );
          });
        });
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
          title: Text('Riwayat Penggajian',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateDialog,
        backgroundColor: AppColors.primaryContainer,
        icon: const Icon(Icons.play_arrow, color: AppColors.onPrimary),
        label: const Text('Run Payroll',
            style: TextStyle(color: AppColors.onPrimary)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.errorCrimson)))
              : _runs.isEmpty
                  ? const Center(child: Text('Belum ada riwayat payroll'))
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _runs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final run = _runs[i];
                        final month = run['period_month'];
                        final year = run['period_year'];
                        final payslipsCount = run['payslips_count'] ?? 0;
                        final status = run['status'] ?? 'draft';

                        final monthName = DateFormat('MMMM', 'id_ID')
                            .format(DateTime(year, month));

                        return InfoCard(
                            onTap: () => context.push('/admin/payroll/detail',
                                extra: run['id']),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('$monthName $year',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp)),
                                        SizedBox(height: 4.h),
                                        Row(children: [
                                          Icon(Icons.people,
                                              size: 14.w,
                                              color:
                                                  AppColors.onSurfaceVariant),
                                          SizedBox(width: 4.w),
                                          Text('$payslipsCount Karyawan',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                  fontSize: 12.sp)),
                                        ])
                                      ]),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: status == 'finalized'
                                            ? AppColors.successEmerald
                                                .withValues(alpha: 0.1)
                                            : AppColors.warningAmber
                                                .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(status.toUpperCase(),
                                          style: TextStyle(
                                              color: status == 'finalized'
                                                  ? AppColors.successEmerald
                                                  : AppColors.warningAmber,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold))),
                                ]));
                      }),
    );
  }
}
