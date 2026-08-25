import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/api_client.dart';

class PayrollRunDetailScreen extends StatefulWidget {
  final int runId;
  const PayrollRunDetailScreen({super.key, required this.runId});

  @override
  State<PayrollRunDetailScreen> createState() => _PayrollRunDetailScreenState();
}

class _PayrollRunDetailScreenState extends State<PayrollRunDetailScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  Map<String, dynamic>? _runData;
  Map<String, dynamic>? _summary;
  List<dynamic> _payslips = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.get('/admin/payroll/runs/${widget.runId}');
      setState(() {
        _runData = response.data['run'];
        _summary = response.data['summary'];
        _payslips = response.data['payslips'] as List;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat detail payroll: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(double.parse(value.toString()));
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
          title: Text('Detail Run Payroll',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.errorCrimson)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoCard(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${DateFormat('MMMM', 'id_ID').format(DateTime(_runData!['period_year'], _runData!['period_month']))} ${_runData!['period_year']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                            color: _runData!['status'] ==
                                                    'finalized'
                                                ? AppColors.successEmerald
                                                    .withValues(alpha: 0.1)
                                                : AppColors.warningAmber
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8.r)),
                                        child: Text(
                                            (_runData!['status'] as String)
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: _runData!['status'] ==
                                                        'finalized'
                                                    ? AppColors.successEmerald
                                                    : AppColors.warningAmber,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold))),
                                  ]),
                              SizedBox(height: 16.h),
                              _Row(
                                  label: 'Total Karyawan',
                                  value: '${_summary!['total_employees']}'),
                              SizedBox(height: 8.h),
                              _Row(
                                  label: 'Total Gaji Pokok',
                                  value: _formatCurrency(
                                      _summary!['total_basic_salary'])),
                              SizedBox(height: 8.h),
                              _Row(
                                  label: 'Total Tunjangan',
                                  value: _formatCurrency(
                                      _summary!['total_earnings'])),
                              SizedBox(height: 8.h),
                              _Row(
                                  label: 'Total Potongan',
                                  value:
                                      '- ${_formatCurrency(_summary!['total_deductions'])}'),
                              Divider(height: 24.h),
                              _Row(
                                  label: 'Total Bersih',
                                  value: _formatCurrency(
                                      _summary!['total_net_salary']),
                                  isBold: true),
                            ])),
                        SizedBox(height: 24.h),
                        Row(children: [
                          Expanded(
                              child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download),
                                  label: const Text('Export Bank'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryContainer,
                                      foregroundColor: AppColors.onPrimary))),
                          SizedBox(width: 12.w),
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.send),
                                  label: const Text('Kirim Slip'),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          AppColors.primaryContainer,
                                      side: const BorderSide(
                                          color: AppColors.primaryContainer)))),
                        ]),
                        SizedBox(height: 24.h),
                        Text('Daftar Slip Gaji',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        SizedBox(height: 12.h),
                        ..._payslips.map((ps) {
                          final empName =
                              ps['employee']?['full_name'] ?? 'Karyawan';
                          return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: InfoCard(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(empName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp)),
                                      SizedBox(height: 4.h),
                                      Text(
                                          'Net: ${_formatCurrency(ps['net_salary'])}',
                                          style: TextStyle(
                                              color: AppColors.successEmerald,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.outline)
                                ],
                              )));
                        })
                      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _Row({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style:
                TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
        Text(value,
            style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: 14.sp)),
      ]);
}
