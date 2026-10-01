import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../auth/bloc/auth_bloc.dart';

class PayrollProfileScreen extends StatefulWidget {
  const PayrollProfileScreen({super.key});

  @override
  State<PayrollProfileScreen> createState() => _PayrollProfileScreenState();
}

class _PayrollProfileScreenState extends State<PayrollProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _npwp = TextEditingController();
  final _healthBpjs = TextEditingController();
  final _employmentBpjs = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _accountHolder = TextEditingController();
  late final ApiClient _api;
  String _ptkp = 'TK/0';
  bool _saving = false;
  String? _error;

  static const _ptkpOptions = [
    'TK/0',
    'TK/1',
    'TK/2',
    'TK/3',
    'K/0',
    'K/1',
    'K/2',
    'K/3',
    'K/I/0',
    'K/I/1',
    'K/I/2',
    'K/I/3',
  ];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final employee = state.user.employee;
      _npwp.text = employee?.npwp ?? '';
      _healthBpjs.text = employee?.bpjsKesehatan ?? '';
      _employmentBpjs.text = employee?.bpjsKetenagakerjaan ?? '';
      _bankName.text = employee?.bankName ?? '';
      _accountNumber.text = employee?.bankAccount ?? '';
      _accountHolder.text = employee?.bankAccountHolder ?? '';
      if (_ptkpOptions.contains(employee?.ptkpStatus)) {
        _ptkp = employee!.ptkpStatus!;
      }
    }
  }

  @override
  void dispose() {
    _npwp.dispose();
    _healthBpjs.dispose();
    _employmentBpjs.dispose();
    _bankName.dispose();
    _accountNumber.dispose();
    _accountHolder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.put('/employee/profile', data: {
        'full_name': state.user.employee?.fullName ?? state.user.name,
        'email': state.user.email,
        'npwp': _npwp.text.trim(),
        'ptkp_status': _ptkp,
        'bpjs_kesehatan_number': _healthBpjs.text.trim(),
        'bpjs_ketenagakerjaan_number': _employmentBpjs.text.trim(),
        'bank_name': _bankName.text.trim(),
        'bank_account_number': _accountNumber.text.trim(),
        'bank_account_holder': _accountHolder.text.trim(),
      });
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthRefreshUserRequested());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data penggajian berhasil diperbarui.'),
        backgroundColor: AppColors.successEmerald,
      ));
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _errorMessage(Object error) {
    final text = error.toString();
    final match = RegExp(r'\[(\d{3})\]\s*(.*)').firstMatch(text);
    return match?.group(2)?.trim().isNotEmpty == true
        ? match!.group(2)!.trim()
        : 'Data belum dapat disimpan. Periksa koneksi lalu coba kembali.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Data Penggajian'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          scrolledUnderElevation: 1,
        ),
        body: BrandPageBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BrandPanel(
                        padding: EdgeInsets.all(20.w),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_outline, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Lengkapi data pajak, BPJS, dan rekening agar admin dapat menyiapkan penggajian dengan benar. Nominal gaji pokok dan kebijakan payroll dikelola oleh admin.',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Form(
                        key: _formKey,
                        child: Card(
                          color: AppColors.surface,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r),
                            side: const BorderSide(color: AppColors.outlineVariant),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(18.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _sectionTitle('Pajak dan kepesertaan',
                                    Icons.receipt_long_outlined),
                                SizedBox(height: 14.h),
                                TextFormField(
                                  controller: _npwp,
                                  decoration: const InputDecoration(
                                      labelText: 'Nomor NPWP (opsional)',
                                      prefixIcon: Icon(Icons.badge_outlined)),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                DropdownButtonFormField<String>(
                                  initialValue: _ptkp,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Status PTKP untuk PPh 21'),
                                  items: _ptkpOptions
                                      .map((value) => DropdownMenuItem(
                                          value: value, child: Text(value)))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _ptkp = value);
                                    }
                                  },
                                ),
                                SizedBox(height: 12.h),
                                TextFormField(
                                  controller: _healthBpjs,
                                  decoration: const InputDecoration(
                                      labelText:
                                          'Nomor BPJS Kesehatan (opsional)',
                                      prefixIcon: Icon(
                                          Icons.health_and_safety_outlined)),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                TextFormField(
                                  controller: _employmentBpjs,
                                  decoration: const InputDecoration(
                                      labelText:
                                          'Nomor BPJS Ketenagakerjaan (opsional)',
                                      prefixIcon: Icon(Icons.work_outline)),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                SizedBox(height: 22.h),
                                _sectionTitle('Rekening penerima gaji',
                                    Icons.account_balance_outlined),
                                SizedBox(height: 14.h),
                                TextFormField(
                                  controller: _bankName,
                                  decoration: const InputDecoration(
                                      labelText: 'Nama bank'),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                SizedBox(height: 12.h),
                                TextFormField(
                                  controller: _accountNumber,
                                  decoration: const InputDecoration(
                                      labelText: 'Nomor rekening'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value) => value != null &&
                                          value.isNotEmpty &&
                                          value.length < 5
                                      ? 'Nomor rekening terlalu pendek.'
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                TextFormField(
                                  controller: _accountHolder,
                                  decoration: const InputDecoration(
                                      labelText: 'Nama pemilik rekening'),
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) =>
                                      _accountNumber.text.isNotEmpty &&
                                              (value == null ||
                                                  value.trim().isEmpty)
                                          ? 'Isi nama sesuai pemilik rekening.'
                                          : null,
                                ),
                                if (_error != null) ...[
                                  SizedBox(height: 14.h),
                                  Text(_error!,
                                      style: const TextStyle(
                                          color: AppColors.errorCrimson)),
                                ],
                                SizedBox(height: 18.h),
                                SizedBox(
                                  height: 52.h,
                                  child: FilledButton.icon(
                                    onPressed: _saving ? null : _save,
                                    icon: _saving
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.w,
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white))
                                        : const Icon(Icons.save_outlined),
                                    label: Text(_saving
                                        ? 'Menyimpan…'
                                        : 'Simpan data penggajian'),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _sectionTitle(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 21.w),
          SizedBox(width: 8.w),
          Text(title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface)),
        ],
      );
}
