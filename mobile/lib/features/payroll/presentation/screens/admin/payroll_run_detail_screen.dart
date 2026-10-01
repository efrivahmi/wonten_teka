import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';

class PayrollRunDetailScreen extends StatefulWidget {
  final int runId;
  const PayrollRunDetailScreen({super.key, required this.runId});

  @override
  State<PayrollRunDetailScreen> createState() => _PayrollRunDetailScreenState();
}

class _PayrollRunDetailScreenState extends State<PayrollRunDetailScreen> {
  late final ApiClient _api;
  bool _loading = true;
  bool _busy = false;
  Map<String, dynamic>? _run;
  Map<String, dynamic>? _summary;
  List<dynamic> _slips = [];
  String? _error;

  String _money(dynamic value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(_number(value));

  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final response = await _api.get('/admin/payroll/runs/${widget.runId}');
      final body = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _run = Map<String, dynamic>.from(body['run'] as Map);
        _summary = Map<String, dynamic>.from(body['summary'] as Map);
        _slips = body['payslips'] as List? ?? const [];
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

  String _apiMessage(Object error) {
    final text = error.toString();
    final match = RegExp(r'\[(\d{3})\]\s*(.*)').firstMatch(text);
    return match?.group(2)?.trim().isNotEmpty == true
        ? match!.group(2)!.trim()
        : 'Detail payroll gagal dimuat. Periksa koneksi lalu coba kembali.';
  }

  String _date(dynamic raw) {
    if (raw == null || '$raw'.isEmpty) return '—';
    final value = DateTime.tryParse('${raw}T00:00:00');
    return value == null
        ? '$raw'
        : DateFormat('d MMM yyyy', 'id_ID').format(value);
  }

  Future<void> _changeStatus(String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terbitkan slip gaji?'),
        content: const Text(
            'Slip akan terlihat bagi karyawan dan notifikasi aplikasi akan dikirim. Pastikan rincian payroll sudah diperiksa.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Terbitkan slip')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.post('/admin/payroll/runs/${widget.runId}/$action');
      await _loadDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slip diterbitkan untuk karyawan.')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = _apiMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = '${_run?['status'] ?? 'draft'}';
    final month = int.tryParse('${_run?['period_month']}') ?? 1;
    final year = int.tryParse('${_run?['period_year']}') ?? DateTime.now().year;
    final period =
        DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year, month));
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: AppBrandTitle(section: period),
          centerTitle: true,
          actions: [
            IconButton(
                tooltip: 'Muat ulang',
                onPressed: _loading ? null : _loadDetail,
                icon: const Icon(Icons.refresh_rounded))
          ],
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null && _run == null
                ? _ErrorState(message: _error!, onRetry: _loadDetail)
                : RefreshIndicator(
                    onRefresh: _loadDetail,
                    color: AppColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                      children: [
                        if (_error != null) _ErrorBanner(message: _error!),
                        _RunHeader(
                          period: period,
                          status: status,
                          start: _date(_run?['period_start']),
                          end: _date(_run?['period_end']),
                          payDate: _date(_run?['scheduled_payment_date']),
                        ),
                        SizedBox(height: 14.h),
                        _SummaryGrid(
                            summary: _summary ?? const {}, money: _money),
                        SizedBox(height: 22.h),
                        Row(children: [
                          Expanded(
                              child: Text(
                                  'Rincian per karyawan (${_slips.length})',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface))),
                          if (status == 'draft')
                            FilledButton.icon(
                              onPressed: _busy || _slips.isEmpty
                                  ? null
                                  : () => _changeStatus('finalize'),
                              icon: const Icon(Icons.publish_rounded, size: 18),
                              label: const Text('Terbitkan'),
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary),
                            )
                        ]),
                        SizedBox(height: 10.h),
                        if (_slips.isEmpty)
                          const _EmptySlips()
                        else
                          ..._slips.map((raw) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _PayslipCard(
                                    slip: Map<String, dynamic>.from(raw as Map),
                                    money: _money,
                                    manual:
                                        _summary?['manual_amount_only'] == true,
                                    busy: _busy,
                                    onCollect: () => _collectSlip(
                                        int.tryParse('${raw['id']}') ?? 0)),
                              )),
                      ],
                    ),
                  ),
        floatingActionButton: _busy
            ? FloatingActionButton.small(
                onPressed: null,
                backgroundColor: AppColors.primary,
                child: SizedBox.square(
                    dimension: 20.w,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)))
            : null,
      ),
    );
  }

  Future<void> _collectSlip(int slipId) async {
    if (slipId <= 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi pengambilan gaji'),
        content: const Text(
            'Pastikan gaji benar-benar sudah diserahkan dan diterima karyawan sebelum mengonfirmasi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sudah diterima')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.post('/admin/payroll/payslips/$slipId/collect');
      await _loadDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Pengambilan gaji berhasil dicatat.')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = _apiMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _RunHeader extends StatelessWidget {
  final String period, status, start, end, payDate;
  const _RunHeader(
      {required this.period,
      required this.status,
      required this.start,
      required this.end,
      required this.payDate});
  @override
  Widget build(BuildContext context) {
    final statusLabel = status == 'paid'
        ? 'Sudah dibayar'
        : status == 'finalized'
            ? 'Final · slip tersedia'
            : 'Draf · belum diterbitkan';
    return Container(
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF087A4B), Color(0xFF16A56A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 6))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(period,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w900))),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .17),
                  borderRadius: BorderRadius.circular(30.r)),
              child: Text(statusLabel,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700)))
        ]),
        SizedBox(height: 15.h),
        _WhiteMeta(
            icon: Icons.date_range_rounded,
            label: 'Periode rekap  $start – $end'),
        SizedBox(height: 7.h),
        _WhiteMeta(
            icon: Icons.event_available_rounded,
            label: 'Jadwal pembayaran  $payDate'),
      ]),
    );
  }
}

class _WhiteMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WhiteMeta({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: Colors.white.withValues(alpha: .85), size: 16.w),
        SizedBox(width: 7.w),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .88),
                    fontSize: 11.sp)))
      ]);
}

class _SummaryGrid extends StatelessWidget {
  final Map<String, dynamic> summary;
  final String Function(dynamic) money;
  const _SummaryGrid({required this.summary, required this.money});
  @override
  Widget build(BuildContext context) {
    final manual = summary['manual_amount_only'] == true;
    final items = <(String, String, IconData)>[
      ('Karyawan', '${summary['total_employees'] ?? 0}', Icons.groups_rounded),
      (
        manual ? 'Jumlah bersih manual' : 'Gaji pokok',
        money(manual
            ? summary['total_manual_amount']
            : summary['total_basic_salary']),
        Icons.payments_outlined
      ),
      (
        'Potongan karyawan',
        money(summary['total_deductions']),
        Icons.remove_circle_outline
      ),
      (
        'Iuran perusahaan',
        money(summary['total_employer_contributions']),
        Icons.business_outlined
      ),
      (
        'Total bersih',
        money(summary['total_net_salary']),
        Icons.account_balance_wallet_rounded
      ),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 520 ? 3 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 9.w,
            mainAxisSpacing: 9.h,
            mainAxisExtent: 86.h),
        itemBuilder: (context, index) {
          final (title, value, icon) = items[index];
          return Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.outlineVariant)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(icon, size: 15.w, color: AppColors.primary),
                      SizedBox(width: 5.w),
                      Expanded(
                          child: Text(title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10.sp)))
                    ]),
                    const Spacer(),
                    FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(value,
                            style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800)))
                  ]));
        },
      );
    });
  }
}

class _PayslipCard extends StatelessWidget {
  final Map<String, dynamic> slip;
  final String Function(dynamic) money;
  final bool manual;
  final VoidCallback onCollect;
  final bool busy;
  const _PayslipCard(
      {required this.slip,
      required this.money,
      required this.manual,
      required this.onCollect,
      required this.busy});
  @override
  Widget build(BuildContext context) {
    final employee = slip['employee'] is Map
        ? Map<String, dynamic>.from(slip['employee'] as Map)
        : <String, dynamic>{};
    final absence = int.tryParse('${slip['attendance_absence_days']}') ?? 0;
    final payoutStatus = slip['payment_status']?.toString() ?? 'pending';
    final payoutLabel = switch (payoutStatus) {
      'collected' => 'Sudah diambil',
      'available' => 'Tersedia untuk diambil',
      _ => 'Belum diproses',
    };
    final detail = (slip['components_detail'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.outlineVariant)),
      child: ExpansionTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        leading: CircleAvatar(
            backgroundColor: AppColors.primaryFixed,
            child: Icon(Icons.person_outline_rounded,
                color: AppColors.primary, size: 20.w)),
        title: Text('${employee['full_name'] ?? 'Karyawan'}',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface)),
        subtitle: Text('Bersih ${money(slip['net_salary'])}',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11.sp)),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        children: [
          _DataLine(label: 'Status pengambilan', value: payoutLabel),
          if (manual)
            _DataLine(
                label: 'Jumlah bersih dari keuangan',
                value: money(slip['net_salary']))
          else ...[
            _DataLine(label: 'Gaji pokok', value: money(slip['basic_salary'])),
            _DataLine(
                label: 'Hari alpha',
                value:
                    '$absence hari · ${money(slip['attendance_deduction_amount'])}'),
            _DataLine(
                label: 'Penghasilan bruto', value: money(slip['gross_salary'])),
          ],
          _DataLine(
              label: 'Total potongan',
              value: '- ${money(slip['total_deductions'])}'),
          if (detail.isNotEmpty) ...[
            const Divider(),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Komponen slip',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 11.sp))),
            SizedBox(height: 4.h),
            ...detail.map((item) => _DataLine(
                label: '${item['name'] ?? 'Komponen'}',
                value: money(item['amount']))),
          ],
          if (payoutStatus == 'available') ...[
            SizedBox(height: 10.h),
            SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : onCollect,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Konfirmasi sudah diterima'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary),
                )),
          ],
        ],
      ),
    );
  }
}

class _DataLine extends StatelessWidget {
  final String label, value;
  const _DataLine({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 11.sp, color: AppColors.onSurfaceVariant))),
        SizedBox(width: 8.w),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700)))
      ]));
}

class _EmptySlips extends StatelessWidget {
  const _EmptySlips();
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(18.r)),
      child: Column(children: [
        Icon(Icons.receipt_long_outlined, size: 42.w, color: AppColors.primary),
        SizedBox(height: 8.h),
        const Text('Belum ada slip untuk periode ini')
      ]));
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12.r)),
          child: Text(message,
              style: TextStyle(color: AppColors.error, fontSize: 12.sp))));
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 44.w),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'))
          ])));
}
