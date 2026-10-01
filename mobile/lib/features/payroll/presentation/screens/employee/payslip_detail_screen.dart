import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/models/payslip_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/brand_panel.dart';

class PayslipDetailScreen extends StatefulWidget {
  final PayslipModel payslip;
  const PayslipDetailScreen({super.key, required this.payslip});

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  late final ApiClient _api;
  late PayslipModel _slip;
  bool _loading = true;
  bool _downloading = false;
  String? _error;

  String _money(num amount) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);

  @override
  void initState() {
    super.initState();
    _slip = widget.payslip;
    _api = context.read<ApiClient>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    try {
      final response = await _api.get('/payslips/${widget.payslip.id}');
      final body = Map<String, dynamic>.from(response.data as Map);
      final detail = PayslipModel.fromJson(body);
      if (mounted) {
        setState(() {
          _slip = detail;
          _error = null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Rincian terbaru gagal dimuat. Menampilkan data yang tersedia.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final folder = await getApplicationDocumentsDirectory();
      final fileName = 'slip-gaji-${widget.payslip.id}.pdf';
      final path = '${folder.path}/$fileName';
      await _api.download('/payslips/${widget.payslip.id}/download', path);
      if (!await File(path).exists()) {
        throw Exception('Berkas slip tidak ditemukan.');
      }
      await Share.shareXFiles([XFile(path)],
          text: 'Slip gaji ${_slip.periodLabel}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Slip gagal diunduh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payoutStatus = _slip.paymentStatus;
    final payoutLabel = switch (payoutStatus) {
      'collected' => 'Sudah diambil',
      'available' => 'Tersedia untuk diambil',
      _ => 'Belum diproses',
    };
    final earnings = _slip.earnings;
    final deductions = _slip.deductions;
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Slip ${_slip.periodLabel}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
              tooltip: 'Unduh atau bagikan PDF',
              onPressed: _downloading ? null : _download,
              icon: _downloading
                  ? SizedBox.square(
                      dimension: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadDetail,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _Notice(message: _error!),
                ),
              _TakeHomeCard(
                amount: _money(_slip.netSalary),
                period: _periodRange(_slip),
                status: payoutLabel,
                paid: payoutStatus == 'collected',
              ),
              if (payoutStatus == 'available') ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.successEmerald.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                        color: AppColors.successEmerald.withValues(alpha: .25)),
                  ),
                  child: Text(
                    'Slip sudah tersedia. Silakan hubungi bagian administrasi/keuangan untuk pengambilan gaji.',
                    style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              _SectionCard(
                title: 'Ringkasan penghasilan',
                icon: Icons.trending_up_rounded,
                accent: AppColors.successEmerald,
                children: [
                  if (earnings.isEmpty)
                    _DataRow(
                        label: 'Gaji pokok', value: _money(_slip.basicSalary)),
                  ...earnings.map((item) => _DataRow(
                        label:
                            '${item['name'] ?? 'Penghasilan'}${item['days'] != null ? ' · ${item['days']} hari' : ''}',
                        value: _money(_number(item['amount'])),
                      )),
                  _DataRow(
                    label: 'Total penghasilan bruto',
                    value: _money(_slip.grossSalary),
                    emphasized: true,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _SectionCard(
                title: 'Rincian potongan',
                icon: Icons.remove_circle_outline_rounded,
                accent: AppColors.errorCrimson,
                children: [
                  if (_slip.attendanceAbsenceDays > 0)
                    _DataRow(
                      label: 'Alpha (${_slip.attendanceAbsenceDays} hari)',
                      value: '- ${_money(_slip.attendanceDeductionAmount)}',
                    ),
                  if (deductions.isNotEmpty)
                    ...deductions.map((item) => _DataRow(
                          label:
                              '${item['name'] ?? 'Potongan'}${item['days'] != null ? ' · ${item['days']} hari' : ''}',
                          value: '- ${_money(_number(item['amount']))}',
                        )),
                  if (_slip.pph21Amount > 0 &&
                      !deductions
                          .any((item) => '${item['name']}'.contains('PPh')))
                    _DataRow(
                        label: 'PPh 21',
                        value: '- ${_money(_slip.pph21Amount)}'),
                  _DataRow(
                    label: 'Total potongan',
                    value: '- ${_money(_slip.totalDeductions)}',
                    emphasized: true,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _SectionCard(
                title: 'Informasi periode',
                icon: Icons.calendar_month_rounded,
                accent: AppColors.primary,
                children: [
                  _DataRow(label: 'Periode rekap', value: _periodRange(_slip)),
                  if (_slip.payrollRun?.scheduledPaymentDate != null)
                    _DataRow(
                      label: 'Jadwal pembayaran',
                      value: _date(_slip.payrollRun!.scheduledPaymentDate!),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              FilledButton.icon(
                onPressed: _downloading ? null : _download,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(_downloading
                    ? 'Menyiapkan PDF…'
                    : 'Unduh / bagikan slip PDF'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _periodRange(PayslipModel slip) {
    if (slip.periodStart == null || slip.periodEnd == null) {
      return slip.periodLabel;
    }
    return '${_date(slip.periodStart!)} – ${_date(slip.periodEnd!)}';
  }

  String _date(String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}

class _TakeHomeCard extends StatelessWidget {
  final String amount;
  final String period;
  final String status;
  final bool paid;
  const _TakeHomeCard(
      {required this.amount,
      required this.period,
      required this.status,
      required this.paid});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF087A4B), Color(0xFF16A56A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .2),
                blurRadius: 22,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white),
            SizedBox(width: 8.w),
            Text('GAJI BERSIH',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .85),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .17),
                  borderRadius: BorderRadius.circular(20.r)),
              child: Text(status,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          SizedBox(height: 18.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900)),
          ),
          SizedBox(height: 7.h),
          Text(period,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .86), fontSize: 12.sp)),
        ]),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> children;
  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.accent,
      required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .04),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: accent, size: 20.w),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800))
          ]),
          SizedBox(height: 10.h),
          ...children,
        ]),
      );
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  const _DataRow(
      {required this.label, required this.value, this.emphasized = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: emphasized
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                      fontSize: 12.sp,
                      fontWeight:
                          emphasized ? FontWeight.w800 : FontWeight.w500))),
          SizedBox(width: 10.w),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color:
                          emphasized ? AppColors.primary : AppColors.onSurface,
                      fontSize: 12.sp,
                      fontWeight:
                          emphasized ? FontWeight.w800 : FontWeight.w700))),
        ]),
      );
}

class _Notice extends StatelessWidget {
  final String message;
  const _Notice({required this.message});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: AppColors.warningAmber.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12.r)),
        child: Text(message,
            style: TextStyle(color: AppColors.onSurface, fontSize: 12.sp)),
      );
}
