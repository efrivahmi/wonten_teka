import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/info_card.dart';

class PayrollConfigurationScreen extends StatefulWidget {
  const PayrollConfigurationScreen({super.key});
  @override
  State<PayrollConfigurationScreen> createState() =>
      _PayrollConfigurationScreenState();
}

class _PayrollConfigurationScreenState
    extends State<PayrollConfigurationScreen> {
  late final ApiClient _api;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, dynamic> _settings = {};
  List<dynamic> _bpjs = [];
  List<dynamic> _tax = [];

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get('/admin/payroll/config');
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);
      if (mounted) {
        setState(() {
          _settings = Map<String, dynamic>.from(data['settings'] as Map? ?? {});
          _bpjs = data['bpjs_rates'] as List? ?? [];
          _tax = data['pph21_ter_rates'] as List? ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat konfigurasi: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _api.put('/admin/payroll/config', data: {'settings': _settings});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konfigurasi payroll disimpan.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _int(String key, int fallback) =>
      int.tryParse('${_settings[key]}') ?? fallback;
  void _set(String key, String value) =>
      setState(() => _settings[key] = int.tryParse(value) ?? _settings[key]);

  @override
  Widget build(BuildContext context) => BrandPageBackground(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const AppBrandTitle(section: 'Konfigurasi Payroll'),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.onSurface)),
        floatingActionButton: _loading
            ? null
            : FloatingActionButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.save)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(padding: EdgeInsets.all(16.w), children: [
                      const Text('Periode dan pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      InfoCard(
                          child: Column(children: [
                        _NumberField(
                            label: 'Mulai periode kehadiran',
                            value: _int('attendance_period_start', 21),
                            onChanged: (v) =>
                                _set('attendance_period_start', v)),
                        _NumberField(
                            label: 'Akhir periode kehadiran',
                            value: _int('attendance_period_end', 20),
                            onChanged: (v) => _set('attendance_period_end', v)),
                        _NumberField(
                            label: 'Tanggal pembayaran',
                            value: _int('payment_day', 25),
                            onChanged: (v) => _set('payment_day', v)),
                      ])),
                      SizedBox(height: 20.h),
                      const Text('Tarif BPJS tersimpan',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      if (_bpjs.isEmpty)
                        const InfoCard(
                            child: Text('Belum ada tarif BPJS di backend.')),
                      ..._bpjs.map((raw) {
                        final item = Map<String, dynamic>.from(raw as Map);
                        return InfoCard(
                            child: ListTile(
                                title: Text('${item['program']}'),
                                subtitle: Text(
                                    'Pemberi kerja: ${item['employer_rate']} • Karyawan: ${item['employee_rate']}')));
                      }),
                      SizedBox(height: 20.h),
                      const Text('Tarif PPh 21 TER tersimpan',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      if (_tax.isEmpty)
                        const InfoCard(
                            child:
                                Text('Belum ada tarif PPh 21 TER di backend.')),
                      ..._tax.take(20).map((raw) {
                        final item = Map<String, dynamic>.from(raw as Map);
                        return ListTile(
                            title: Text('Kategori ${item['category']}'),
                            subtitle: Text(
                                '${item['income_range_start']} - ${item['income_range_end'] ?? 'tanpa batas'} • ${item['effective_rate']}'));
                      }),
                    ])),
      ));
}

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<String> onChanged;
  const _NumberField(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged);
}
