import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/admin_pagination_bar.dart';

class PayrollRunListScreen extends StatefulWidget {
  const PayrollRunListScreen({super.key});

  @override
  State<PayrollRunListScreen> createState() => _PayrollRunListScreenState();
}

class _PayrollRunListScreenState extends State<PayrollRunListScreen> {
  late final ApiClient _api;
  bool _loading = true;
  bool _generating = false;
  List<dynamic> _runs = [];
  String? _error;
  int _page = 1;
  int _lastPage = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadRuns();
  }

  Future<void> _loadRuns({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get('/admin/payroll/runs',
          queryParameters: {'page': page, 'per_page': 15});
      final body = Map<String, dynamic>.from(response.data as Map);
      final rows = body['data'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _runs = rows;
        _page = int.tryParse('${body['current_page']}') ?? page;
        _lastPage = int.tryParse('${body['last_page']}') ?? 1;
        _total = int.tryParse('${body['total']}') ?? rows.length;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _apiMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _generatePayroll(int month, int year,
      {List<Map<String, dynamic>>? manualEmployees}) async {
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final payload = <String, dynamic>{
        'period_month': month,
        'period_year': year,
      };
      if (manualEmployees != null) payload['employees'] = manualEmployees;
      final response = await _api.post(
          manualEmployees == null
              ? '/admin/payroll/runs'
              : '/admin/payroll/runs/manual',
          data: payload);
      if (!mounted) return;
      final data = response.data is Map ? response.data['data'] : null;
      final runId = int.tryParse('${data is Map ? data['id'] : ''}');
      await _loadRuns(page: 1);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(manualEmployees == null
            ? 'Draf payroll otomatis berhasil dihitung. Tinjau aturan dan rincian sebelum menerbitkan.'
            : 'Draf jumlah manual tersimpan. Tinjau rincian sebelum menerbitkan.'),
      ));
      if (runId != null) context.push('/admin/payroll/detail', extra: runId);
    } catch (e) {
      if (mounted) setState(() => _error = _apiMessage(e));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String _apiMessage(Object error) {
    final text = error.toString();
    final match = RegExp(r'\[(\d{3})\]\s*(.*)').firstMatch(text);
    return match?.group(2)?.trim().isNotEmpty == true
        ? match!.group(2)!.trim()
        : 'Permintaan payroll gagal. Periksa koneksi dan coba lagi.';
  }

  String _date(dynamic value) {
    if (value == null || '$value'.isEmpty) return '—';
    final parsed = DateTime.tryParse('${value}T00:00:00');
    return parsed == null
        ? '$value'
        : DateFormat('d MMM yyyy', 'id_ID').format(parsed);
  }

  String _statusLabel(String status) => switch (status) {
        'draft' => 'Draf · belum diterbitkan',
        'finalized' => 'Final · slip tersedia',
        'paid' => 'Sudah dibayar',
        _ => status,
      };

  Color _statusColor(String status) => switch (status) {
        'paid' => AppColors.infoCerulean,
        'finalized' => AppColors.successEmerald,
        _ => AppColors.warningAmber,
      };

  Future<void> _showGenerateDialog() async {
    var month = DateTime.now().month;
    var year = DateTime.now().year;
    var mode = 'automatic';
    var employeesLoading = false;
    var employeesLoaded = false;
    List<Map<String, dynamic>> eligibleEmployees = [];
    final amounts = <int, String>{};
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat draf payroll'),
          content: SizedBox(
            width: 520.w,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: mode,
                decoration: const InputDecoration(
                    labelText: 'Cara penggajian', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'automatic',
                      child: Text('Otomatis · aturan aktif')),
                  DropdownMenuItem(
                      value: 'manual',
                      child: Text('Manual · jumlah bersih dari keuangan')),
                ],
                onChanged: (value) async {
                  setDialogState(() => mode = value ?? 'automatic');
                  if (mode != 'manual' || employeesLoaded || employeesLoading) {
                    return;
                  }
                  setDialogState(() => employeesLoading = true);
                  try {
                    final response =
                        await _api.get('/admin/payroll/eligible-employees');
                    final rows = response.data is Map
                        ? response.data['data'] as List? ?? const []
                        : const [];
                    setDialogState(() {
                      eligibleEmployees = rows
                          .whereType<Map>()
                          .map((row) => Map<String, dynamic>.from(row))
                          .toList();
                      employeesLoaded = true;
                    });
                  } catch (e) {
                    setDialogState(() => _error = _apiMessage(e));
                  } finally {
                    setDialogState(() => employeesLoading = false);
                  }
                },
              ),
              SizedBox(height: 8.h),
              Text(
                  mode == 'automatic'
                      ? 'Sistem menghitung gaji dari komponen dan aturan aktif (absensi, pajak, BPJS). Periksa konfigurasi terlebih dahulu.'
                      : 'Masukkan jumlah bersih final dari bagian keuangan. Potongan dan pajak tidak dihitung ulang oleh aplikasi.',
                  style: TextStyle(
                      fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
              if (mode == 'manual') ...[
                SizedBox(height: 12.h),
                if (employeesLoading)
                  const LinearProgressIndicator()
                else if (eligibleEmployees.isEmpty)
                  const Text('Daftar karyawan aktif tidak tersedia.'
                      ' Muat ulang lalu coba lagi.')
                else
                  SizedBox(
                    height: 260.h,
                    child: ListView.builder(
                      itemCount: eligibleEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = eligibleEmployees[index];
                        final id = int.tryParse('${employee['id']}') ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(children: [
                            Expanded(
                                child: Text(
                                    '${employee['full_name'] ?? 'Karyawan'}\n${employee['employee_number'] ?? ''}',
                                    style: TextStyle(fontSize: 11.sp))),
                            SizedBox(
                                width: 150.w,
                                child: TextFormField(
                                  initialValue: amounts[id] ?? '',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Jumlah bersih (Rp)',
                                      border: OutlineInputBorder(),
                                      isDense: true),
                                  onChanged: (value) => amounts[id] = value,
                                )),
                          ]),
                        );
                      },
                    ),
                  ),
              ],
              SizedBox(height: 18.h),
              DropdownButtonFormField<int>(
                initialValue: month,
                decoration: const InputDecoration(
                    labelText: 'Bulan gaji', border: OutlineInputBorder()),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(DateFormat('MMMM', 'id_ID')
                              .format(DateTime(year, i + 1))),
                        )),
                onChanged: (value) =>
                    setDialogState(() => month = value ?? month),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<int>(
                initialValue: year,
                decoration: const InputDecoration(
                    labelText: 'Tahun', border: OutlineInputBorder()),
                items: List.generate(81, (i) => 2020 + i)
                    .map((value) =>
                        DropdownMenuItem(value: value, child: Text('$value')))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => year = value ?? year),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal')),
            FilledButton(
              onPressed: _generating
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      if (mode == 'manual') {
                        final manual = amounts.entries
                            .where(
                                (entry) => (num.tryParse(entry.value) ?? 0) > 0)
                            .map((entry) => <String, dynamic>{
                                  'employee_id': entry.key,
                                  'net_amount': num.parse(entry.value),
                                })
                            .toList();
                        if (manual.isEmpty) {
                          setDialogState(() => _error =
                              'Masukkan jumlah bersih untuk minimal satu karyawan.');
                          return;
                        }
                        Navigator.pop(dialogContext);
                        _generatePayroll(month, year, manualEmployees: manual);
                      } else {
                        Navigator.pop(dialogContext);
                        _generatePayroll(month, year);
                      }
                    },
              child: Text(mode == 'manual'
                  ? 'Simpan jumlah manual'
                  : 'Hitung draf otomatis'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BrandPageBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const AppBrandTitle(section: 'Penggajian'),
            centerTitle: true,
            actions: [
              IconButton(
                  tooltip: 'Muat ulang',
                  onPressed: _loading ? null : () => _loadRuns(page: _page),
                  icon: const Icon(Icons.refresh_rounded))
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _generating ? null : _showGenerateDialog,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: _generating
                ? SizedBox.square(
                    dimension: 18.w,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.calculate_rounded),
            label: Text(_generating ? 'Menghitung…' : 'Hitung payroll'),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  onRefresh: () => _loadRuns(page: _page),
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    children: [
                      _Hero(total: _total),
                      if (_error != null) ...[
                        SizedBox(height: 12.h),
                        _ErrorBanner(
                            message: _error!,
                            onRetry: () => _loadRuns(page: _page)),
                      ],
                      SizedBox(height: 18.h),
                      Text('Riwayat payroll',
                          style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 10.h),
                      if (_runs.isEmpty)
                        _Empty(onRetry: () => _loadRuns(page: 1))
                      else
                        ..._runs.map((raw) {
                          final run = Map<String, dynamic>.from(raw as Map);
                          final month =
                              int.tryParse('${run['period_month']}') ?? 1;
                          final year = int.tryParse('${run['period_year']}') ??
                              DateTime.now().year;
                          final status = '${run['status'] ?? 'draft'}';
                          final period = DateFormat('MMMM yyyy', 'id_ID')
                              .format(DateTime(year, month));
                          final range =
                              '${_date(run['period_start'])} – ${_date(run['period_end'])}';
                          return Padding(
                            padding: EdgeInsets.only(bottom: 11.h),
                            child: Material(
                              color: Colors.white.withValues(alpha: .92),
                              borderRadius: BorderRadius.circular(20.r),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.r),
                                onTap: () => context.push(
                                    '/admin/payroll/detail',
                                    extra: run['id']),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                          color: AppColors.outlineVariant)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: 44.w,
                                                  height: 44.w,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryFixed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14.r)),
                                                  child: Icon(
                                                      Icons.payments_outlined,
                                                      color: AppColors.primary,
                                                      size: 22.w)),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Text(period,
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .onSurface,
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800)),
                                                    SizedBox(height: 4.h),
                                                    Text('Rekap $range',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                            fontSize: 11.sp)),
                                                  ])),
                                              _StatusPill(
                                                  label: _statusLabel(status),
                                                  color: _statusColor(status)),
                                            ]),
                                        SizedBox(height: 14.h),
                                        Row(children: [
                                          Expanded(
                                              child: _Meta(
                                                  icon: Icons.groups_2_outlined,
                                                  label:
                                                      '${run['payslips_count'] ?? 0} karyawan')),
                                          Expanded(
                                              child: _Meta(
                                                  icon: Icons
                                                      .event_available_outlined,
                                                  label:
                                                      'Bayar ${_date(run['scheduled_payment_date'])}')),
                                          Icon(Icons.chevron_right_rounded,
                                              color: AppColors.onSurfaceVariant,
                                              size: 20.w),
                                        ]),
                                      ]),
                                ),
                              ),
                            ),
                          );
                        }),
                      if (_lastPage > 1)
                        AdminPaginationBar(
                            currentPage: _page,
                            lastPage: _lastPage,
                            total: _total,
                            onPageChanged: (page) => _loadRuns(page: page)),
                    ],
                  ),
                ),
        ),
      );
}

class _Hero extends StatelessWidget {
  final int total;
  const _Hero({required this.total});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF087A4B), Color(0xFF16A56A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .18),
                blurRadius: 20,
                offset: const Offset(0, 7))
          ],
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Siklus gaji, jelas dan terkontrol',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 6.h),
                Text(
                    'Hitung draf → tinjau → terbitkan slip → catat pembayaran.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .86),
                        fontSize: 11.sp)),
                SizedBox(height: 12.h),
                Text('$total proses payroll',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp)),
              ])),
          SizedBox(width: 12.w),
          Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white.withValues(alpha: .9), size: 40.w),
        ]),
      );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(maxWidth: 130.w),
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(30.r)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontSize: 9.sp, fontWeight: FontWeight.w800)),
      );
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15.w, color: AppColors.onSurfaceVariant),
        SizedBox(width: 5.w),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 10.sp),
                overflow: TextOverflow.ellipsis))
      ]);
}

class _Empty extends StatelessWidget {
  final VoidCallback onRetry;
  const _Empty({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: EdgeInsets.all(28.w),
          child: Column(children: [
            Icon(Icons.receipt_long_outlined,
                size: 48.w, color: AppColors.primary),
            SizedBox(height: 10.h),
            const Text('Belum ada proses payroll'),
            TextButton(onPressed: onRetry, child: const Text('Muat ulang'))
          ])));
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12.r)),
      child: Row(children: [
        Expanded(
            child: Text(message,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp))),
        TextButton(onPressed: onRetry, child: const Text('Coba lagi'))
      ]));
}
