import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';

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
  List<Map<String, dynamic>> _components = [];
  List<Map<String, dynamic>> _bpjs = [];
  List<Map<String, dynamic>> _ter = [];
  List<Map<String, dynamic>> _brackets = [];
  List<Map<String, dynamic>> _ptkp = [];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _load();
  }

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get('/admin/payroll/config');
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);
      if (!mounted) return;
      setState(() {
        _settings = Map<String, dynamic>.from(data['settings'] as Map? ?? {});
        _components = _maps(data['components']);
        _bpjs = _maps(data['bpjs_rates']);
        _ter = _maps(data['pph21_ter_rates']);
        _brackets = _maps(data['pph21_progressive_brackets']);
        _ptkp = _maps(data['ptkp_thresholds']);
        _loading = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = _message(e);
          _loading = false;
        });
    }
  }

  List<Map<String, dynamic>> _maps(dynamic value) =>
      (value as List? ?? const [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();

  String _message(Object error) {
    final text = error.toString();
    final match = RegExp(r'\[(\d{3})\]\s*(.*)').firstMatch(text);
    return match?.group(2)?.trim().isNotEmpty == true
        ? match!.group(2)!.trim()
        : 'Permintaan pengaturan payroll gagal. Periksa koneksi dan hak akses admin.';
  }

  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  int _integer(String key, int fallback) =>
      int.tryParse('${_settings[key]}') ?? fallback;

  void _setSetting(String key, dynamic value) =>
      setState(() => _settings[key] = value);

  void _editRow(
      List<Map<String, dynamic>> rows, int index, String key, dynamic value) {
    setState(() => rows[index][key] = value);
  }

  Future<void> _saveSettings() => _runSave(
        () => _api.put('/admin/payroll/config', data: {'settings': _settings}),
        success: 'Kebijakan payroll berhasil disimpan.',
      );

  Future<void> _saveComponents(Map<String, dynamic> row) async {
    final id = row['id'];
    final payload = <String, dynamic>{
      'name': row['name'],
      'code':
          row['code']?.toString().trim().isEmpty == true ? null : row['code'],
      'type': row['type'] ?? 'earning',
      'is_taxable': row['is_taxable'] ?? true,
      'default_amount': _number(row['default_amount']),
      'is_active': row['is_active'] ?? true,
      'sort_order': int.tryParse('${row['sort_order']}') ?? 0,
    };
    await _runSave(
      () => id == null
          ? _api.post('/admin/payroll/config/components', data: payload)
          : _api.put('/admin/payroll/config/components/$id', data: payload),
      success: 'Komponen gaji berhasil disimpan.',
    );
  }

  Future<void> _deleteComponent(Map<String, dynamic> row) async {
    final okay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus komponen?'),
        content: Text(
            'Komponen “${row['name']}” akan dihapus dari konfigurasi payroll.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (okay != true) return;
    await _runSave(
        () => _api.delete('/admin/payroll/config/components/${row['id']}'),
        success: 'Komponen dihapus.');
  }

  Future<void> _saveBpjs() => _runSave(
        () => _api.put('/admin/payroll/config/bpjs-rates', data: {
          'rates': _bpjs
              .map((row) => {
                    if (row['id'] != null) 'id': row['id'],
                    'program': row['program'],
                    'employer_rate': _number(row['employer_rate']),
                    'employee_rate': _number(row['employee_rate']),
                    'salary_cap': row['salary_cap'] == null ||
                            '${row['salary_cap']}'.isEmpty
                        ? null
                        : _number(row['salary_cap']),
                    'jkk_risk_class':
                        row['program'] == 'jkk' ? row['jkk_risk_class'] : null,
                    'effective_from': row['effective_from'],
                    'effective_to':
                        row['effective_to'] == '' ? null : row['effective_to'],
                    'notes': row['notes'],
                  })
              .toList(),
        }),
        success: 'Tarif BPJS berhasil disimpan.',
      );

  Future<void> _deleteRule(String kind, Map<String, dynamic> row) async {
    final id = row['id'];
    final okay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus aturan?'),
        content: const Text(
            'Aturan ini tidak akan dipakai pada payroll berikutnya. Slip yang sudah diterbitkan tidak diubah.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (okay != true) return;
    if (id == null) {
      setState(() {
        if (kind == 'bpjs') _bpjs.remove(row);
        if (kind == 'ter') _ter.remove(row);
        if (kind == 'bracket') _brackets.remove(row);
        if (kind == 'ptkp') _ptkp.remove(row);
      });
      return;
    }
    final url = switch (kind) {
      'bpjs' => '/admin/payroll/config/bpjs-rates/$id',
      'ter' => '/admin/payroll/config/ter-rates/$id',
      _ => '/admin/payroll/config/annual-tax-rates/$kind/$id',
    };
    await _runSave(() => _api.delete(url), success: 'Aturan dihapus.');
  }

  Future<void> _saveTer() => _runSave(
        () => _api.put('/admin/payroll/config/ter-rates', data: {
          'rates': _ter
              .map((row) => {
                    if (row['id'] != null) 'id': row['id'],
                    'category': row['category'],
                    'income_range_start': _number(row['income_range_start']),
                    'income_range_end': row['income_range_end'] == null ||
                            '${row['income_range_end']}'.isEmpty
                        ? null
                        : _number(row['income_range_end']),
                    'effective_rate': _number(row['effective_rate']),
                    'effective_from': row['effective_from'],
                    'effective_to':
                        row['effective_to'] == '' ? null : row['effective_to'],
                  })
              .toList(),
        }),
        success: 'Tarif PPh 21 TER berhasil disimpan.',
      );

  Future<void> _saveAnnualTax() => _runSave(
        () => _api.put('/admin/payroll/config/annual-tax-rates', data: {
          'brackets': _brackets
              .map((row) => {
                    if (row['id'] != null) 'id': row['id'],
                    'bracket_start': _number(row['bracket_start']),
                    'bracket_end': row['bracket_end'] == null ||
                            '${row['bracket_end']}'.isEmpty
                        ? null
                        : _number(row['bracket_end']),
                    'rate': _number(row['rate']),
                    'effective_from': row['effective_from'],
                    'effective_to':
                        row['effective_to'] == '' ? null : row['effective_to'],
                  })
              .toList(),
          'ptkp': _ptkp
              .map((row) => {
                    if (row['id'] != null) 'id': row['id'],
                    'status': row['status'],
                    'annual_threshold': _number(row['annual_threshold']),
                    'effective_from': row['effective_from'],
                    'effective_to':
                        row['effective_to'] == '' ? null : row['effective_to'],
                  })
              .toList(),
        }),
        success: 'Tarif progresif dan PTKP berhasil disimpan.',
      );

  Future<void> _runSave(Future<dynamic> Function() request,
      {required String success}) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await request();
      await _load();
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addBpjs() => setState(() => _bpjs.add({
        'program': 'kesehatan',
        'employer_rate': 0,
        'employee_rate': 0,
        'salary_cap': null,
        'jkk_risk_class': null,
        'effective_from': _today,
        'effective_to': null,
        'notes': '',
      }));

  void _addTer() => setState(() => _ter.add({
        'category': 'A',
        'income_range_start': 0,
        'income_range_end': null,
        'effective_rate': 0,
        'effective_from': _today,
        'effective_to': null,
      }));

  void _addBracket() => setState(() => _brackets.add({
        'bracket_start': 0,
        'bracket_end': null,
        'rate': 0,
        'effective_from': _today,
        'effective_to': null,
      }));

  void _addPtkp() => setState(() => _ptkp.add({
        'status': 'TK/0',
        'annual_threshold': 54000000,
        'effective_from': _today,
        'effective_to': null,
      }));

  @override
  Widget build(BuildContext context) => BrandPageBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const AppBrandTitle(section: 'Konfigurasi Payroll'),
            centerTitle: true,
            actions: [
              IconButton(
                  tooltip: 'Muat ulang',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh_rounded))
            ],
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : _error != null && _settings.isEmpty
                  ? _ErrorState(message: _error!, onRetry: _load)
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
                        children: [
                          _HeroCard(),
                          if (_error != null) ...[
                            SizedBox(height: 12.h),
                            _ErrorBanner(message: _error!)
                          ],
                          SizedBox(height: 14.h),
                          _SectionHeader(
                              title: 'Siklus & kebijakan',
                              subtitle:
                                  'Atur periode rekap dan kebijakan otomatis. Cara hitung otomatis atau jumlah bersih manual dipilih setiap kali membuat payroll.'),
                          SizedBox(height: 8.h),
                          _SettingsCard(
                              settings: _settings,
                              integer: _integer,
                              setValue: _setSetting),
                          SizedBox(height: 9.h),
                          _SaveButton(
                              label: 'Simpan kebijakan',
                              busy: _saving,
                              onPressed: _saveSettings),
                          SizedBox(height: 20.h),
                          _SectionHeader(
                              title: 'Komponen gaji',
                              subtitle:
                                  'Gaji pokok BASE per karyawan, tunjangan, dan potongan rutin.'),
                          SizedBox(height: 8.h),
                          FilledButton.tonalIcon(
                            onPressed: _saving
                                ? null
                                : () async {
                                    final result =
                                        await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (_) => const _ComponentEditor(),
                                    );
                                    if (result != null)
                                      await _saveComponents(result);
                                  },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Tambah komponen'),
                          ),
                          SizedBox(height: 8.h),
                          if (_components.isEmpty)
                            const _EmptyCard(
                                message:
                                    'Belum ada komponen. Tambahkan komponen BASE sebelum menjalankan payroll.'),
                          ..._components.map((row) => _ComponentCard(
                                row: row,
                                busy: _saving,
                                onSave: () => _saveComponents(row),
                                onDelete: () => _deleteComponent(row),
                                onChanged: (key, value) =>
                                    setState(() => row[key] = value),
                              )),
                          SizedBox(height: 20.h),
                          _SectionHeader(
                              title: 'BPJS Kesehatan & Ketenagakerjaan',
                              subtitle:
                                  'Tarif desimal, contoh 0,02 = 2%. Tanggal efektif menjaga hasil payroll lama tetap.'),
                          SizedBox(height: 8.h),
                          FilledButton.tonalIcon(
                              onPressed: _saving ? null : _addBpjs,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Tambah tarif BPJS')),
                          SizedBox(height: 8.h),
                          if (_bpjs.isEmpty)
                            const _EmptyCard(
                                message:
                                    'Tarif belum diatur. Aktifkan BPJS setelah tarif dan kelas risiko JKK dikonfirmasi.'),
                          ..._bpjs.asMap().entries.map((entry) => _BpjsRateCard(
                              row: entry.value,
                              onDelete: () => _deleteRule('bpjs', entry.value),
                              onChanged: (key, value) =>
                                  _editRow(_bpjs, entry.key, key, value))),
                          if (_bpjs.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _SaveButton(
                                label: 'Simpan tarif BPJS',
                                busy: _saving,
                                onPressed: _saveBpjs)
                          ],
                          SizedBox(height: 20.h),
                          _SectionHeader(
                              title: 'PPh 21 TER bulanan',
                              subtitle:
                                  'Masukkan semua rentang kategori A, B, dan C. Contoh 0,005 = 0,5%.'),
                          SizedBox(height: 8.h),
                          FilledButton.tonalIcon(
                              onPressed: _saving ? null : _addTer,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Tambah rentang TER')),
                          SizedBox(height: 8.h),
                          if (_ter.isEmpty)
                            const _EmptyCard(
                                message:
                                    'Tabel TER belum diatur. Pajak tetap nonaktif sampai data resmi dilengkapi.'),
                          ..._ter.asMap().entries.map((entry) => _TerRateCard(
                              row: entry.value,
                              onDelete: () => _deleteRule('ter', entry.value),
                              onChanged: (key, value) =>
                                  _editRow(_ter, entry.key, key, value))),
                          if (_ter.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _SaveButton(
                                label: 'Simpan tarif TER',
                                busy: _saving,
                                onPressed: _saveTer)
                          ],
                          SizedBox(height: 20.h),
                          _SectionHeader(
                              title: 'Pajak tahunan & PTKP',
                              subtitle:
                                  'Dipakai untuk rekonsiliasi payroll Desember.'),
                          SizedBox(height: 8.h),
                          _AnnualTaxSection(
                            brackets: _brackets,
                            ptkp: _ptkp,
                            saving: _saving,
                            onAddBracket: _addBracket,
                            onAddPtkp: _addPtkp,
                            onBracketChanged: (index, key, value) =>
                                _editRow(_brackets, index, key, value),
                            onPtkpChanged: (index, key, value) =>
                                _editRow(_ptkp, index, key, value),
                            onDeleteBracket: (index) =>
                                _deleteRule('bracket', _brackets[index]),
                            onDeletePtkp: (index) =>
                                _deleteRule('ptkp', _ptkp[index]),
                            onSave: _saveAnnualTax,
                          ),
                          SizedBox(height: 12.h),
                          const _WarningCard(
                              message:
                                  'Periksa tarif PPh 21, BPJS, batas upah, dan tanggal efektif bersama staf pajak/HR sebelum kebijakan dipakai untuk penggajian resmi.'),
                        ],
                      ),
                    ),
        ),
      );
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF087A4B), Color(0xFF16A56A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .17),
                blurRadius: 18,
                offset: const Offset(0, 6))
          ]),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Atur sekali, hitung konsisten',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 5.h),
          Text(
              'Kebijakan ini dibaca bersama oleh aplikasi web dan mobile melalui REST API.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .86), fontSize: 11.sp))
        ])),
        Icon(Icons.tune_rounded, size: 35.w, color: Colors.white)
      ]));
}

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeader({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800)),
        SizedBox(height: 3.h),
        Text(subtitle,
            style:
                TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp))
      ]);
}

class _SettingsCard extends StatelessWidget {
  final Map<String, dynamic> settings;
  final int Function(String, int) integer;
  final void Function(String, dynamic) setValue;
  const _SettingsCard(
      {required this.settings, required this.integer, required this.setValue});
  @override
  Widget build(BuildContext context) => _CardSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: _SmallNumber(
                  label: 'Mulai rekap (tgl)',
                  value: integer('attendance_period_start', 21),
                  onChanged: (v) => setValue('attendance_period_start', v))),
          SizedBox(width: 10.w),
          Expanded(
              child: _SmallNumber(
                  label: 'Akhir rekap (tgl)',
                  value: integer('attendance_period_end', 20),
                  onChanged: (v) => setValue('attendance_period_end', v)))
        ]),
        SizedBox(height: 8.h),
        _SmallNumber(
            label: 'Tanggal pembayaran (1–31)',
            value: integer('payment_day', 25),
            onChanged: (v) => setValue('payment_day', v)),
        Divider(height: 22.h),
        _SwitchRow(
            title: 'Potongan alpha',
            subtitle: 'Hitung hari berstatus absent pada periode rekap.',
            value: settings['attendance_deduction_enabled'] == true,
            onChanged: (v) => setValue('attendance_deduction_enabled', v)),
        if (settings['attendance_deduction_enabled'] == true) ...[
          SizedBox(height: 4.h),
          _NumberTextField(
              label: 'Potongan per hari (Rp)',
              value: settings['attendance_deduction_per_day'],
              onChanged: (v) =>
                  setValue('attendance_deduction_per_day', _asNumber(v))),
        ],
        Divider(height: 22.h),
        ...[
          (
            'bpjs_kesehatan_enabled',
            'BPJS Kesehatan',
            'Iuran kesehatan pekerja dan perusahaan.'
          ),
          (
            'bpjs_jht_enabled',
            'BPJS JHT',
            'Jaminan Hari Tua pekerja dan perusahaan.'
          ),
          (
            'bpjs_jp_enabled',
            'BPJS JP',
            'Jaminan Pensiun pekerja dan perusahaan.'
          ),
          ('bpjs_jkk_enabled', 'BPJS JKK', 'Iuran JKK dibayar perusahaan.'),
          ('bpjs_jkm_enabled', 'BPJS JKM', 'Iuran JKM dibayar perusahaan.'),
        ].map((program) => _SwitchRow(
              title: program.$2,
              subtitle: program.$3,
              value: settings[program.$1] == true,
              onChanged: (v) => setValue(program.$1, v),
            )),
        if (settings['bpjs_jkk_enabled'] == true)
          DropdownButtonFormField<String>(
              initialValue: '${settings['jkk_risk_class'] ?? 'I'}',
              decoration: const InputDecoration(labelText: 'Kelas risiko JKK'),
              items: ['I', 'II', 'III', 'IV', 'V']
                  .map((v) =>
                      DropdownMenuItem(value: v, child: Text('Kelas $v')))
                  .toList(),
              onChanged: (v) {
                if (v != null) setValue('jkk_risk_class', v);
              }),
        Container(
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.warningAmber.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'Aktifkan hanya program yang berlaku bagi instansi dan karyawan. Nonaktifkan komponen tidak relevan setelah memastikan kewajiban yang berlaku; tarif wajib mengikuti ketentuan terbaru.',
            style:
                TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant),
          ),
        ),
        Divider(height: 22.h),
        _SwitchRow(
            title: 'Potong PPh 21',
            subtitle: 'TER bulanan dan rekonsiliasi tahunan pada Desember.',
            value: settings['pph21_enabled'] == true,
            onChanged: (v) => setValue('pph21_enabled', v)),
        if (settings['pph21_enabled'] == true) ...[
          SizedBox(height: 5.h),
          Row(children: [
            Expanded(
                child: _NumberTextField(
                    label: 'Biaya jabatan (desimal)',
                    value: settings['job_expense_rate'],
                    onChanged: (v) =>
                        setValue('job_expense_rate', _asNumber(v)))),
            SizedBox(width: 10.w),
            Expanded(
                child: _NumberTextField(
                    label: 'Maks/bulan (Rp)',
                    value: settings['job_expense_monthly_cap'],
                    onChanged: (v) =>
                        setValue('job_expense_monthly_cap', _asNumber(v))))
          ]),
        ],
      ]));
}

dynamic _asNumber(String value) => num.tryParse(value) ?? 0;

class _SwitchRow extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow(
      {required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      title: Text(title,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 10.sp)),
      value: value,
      onChanged: onChanged);
}

class _SmallNumber extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _SmallNumber(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: (text) {
        final n = int.tryParse(text);
        if (n != null) onChanged(n);
      });
}

class _NumberTextField extends StatelessWidget {
  final String label;
  final dynamic value;
  final ValueChanged<String> onChanged;
  const _NumberTextField(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: onChanged);
}

class _ComponentCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final bool busy;
  final VoidCallback onSave, onDelete;
  final void Function(String key, dynamic value) onChanged;
  const _ComponentCard(
      {required this.row,
      required this.busy,
      required this.onSave,
      required this.onDelete,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final isBase = '${row['code']}'.toLowerCase() == 'base';
    return _CardSurface(
        margin: EdgeInsets.only(bottom: 8.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('${row['name'] ?? 'Komponen'}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13.sp))),
            _Tag(
                label: isBase
                    ? 'GAJI POKOK'
                    : (row['type'] == 'earning' ? 'PENGHASILAN' : 'POTONGAN'))
          ]),
          if (isBase)
            Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                    'Nominal gaji pokok diisi pada profil tiap karyawan.',
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 10.sp))),
          SizedBox(height: 10.h),
          _NumberTextField(
              label: 'Nominal default (Rp)',
              value: row['default_amount'],
              onChanged: (v) => onChanged('default_amount', v)),
          SizedBox(height: 5.h),
          _SwitchRow(
              title: 'Aktif digunakan',
              subtitle: 'Nonaktifkan jika komponen sementara tidak berlaku.',
              value: row['is_active'] == true,
              onChanged: (v) => onChanged('is_active', v)),
          _SwitchRow(
              title: 'Termasuk objek pajak',
              subtitle: 'Tentukan berdasarkan perlakuan pajak komponen ini.',
              value: row['is_taxable'] == true,
              onChanged: (v) => onChanged('is_taxable', v)),
          Wrap(spacing: 8, children: [
            FilledButton.tonalIcon(
                onPressed: busy ? null : onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan')),
            if (!isBase)
              TextButton.icon(
                  onPressed: busy ? null : onDelete,
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  label: const Text('Hapus'))
          ]),
        ]));
  }
}

class _ComponentEditor extends StatefulWidget {
  const _ComponentEditor();
  @override
  State<_ComponentEditor> createState() => _ComponentEditorState();
}

class _ComponentEditorState extends State<_ComponentEditor> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _amount = TextEditingController(text: '0');
  String _type = 'earning';
  bool _taxable = true;
  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Tambah komponen'),
        content: Form(
            key: _form,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Isi nama komponen'
                      : null),
              TextField(
                  controller: _code,
                  decoration: const InputDecoration(
                      labelText: 'Kode (gunakan BASE untuk gaji pokok)')),
              DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                  items: const [
                    DropdownMenuItem(
                        value: 'earning', child: Text('Penghasilan')),
                    DropdownMenuItem(
                        value: 'deduction', child: Text('Potongan'))
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'earning')),
              TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Nominal default (Rp)')),
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Objek pajak'),
                  value: _taxable,
                  onChanged: (v) => setState(() => _taxable = v)),
            ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                Navigator.pop(context, {
                  'name': _name.text.trim(),
                  'code': _code.text.trim(),
                  'type': _type,
                  'is_taxable': _taxable,
                  'default_amount': num.tryParse(_amount.text) ?? 0,
                  'is_active': true,
                  'sort_order': 0
                });
              },
              child: const Text('Tambah'))
        ],
      );
}

class _BpjsRateCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final VoidCallback onDelete;
  final void Function(String key, dynamic value) onChanged;
  const _BpjsRateCard(
      {required this.row, required this.onChanged, required this.onDelete});
  @override
  Widget build(BuildContext context) => _CardSurface(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<String>(
            value: '${row['program'] ?? 'kesehatan'}',
            decoration: const InputDecoration(labelText: 'Program BPJS'),
            items: const [
              DropdownMenuItem(
                  value: 'kesehatan', child: Text('BPJS Kesehatan')),
              DropdownMenuItem(value: 'jht', child: Text('JHT')),
              DropdownMenuItem(value: 'jp', child: Text('JP')),
              DropdownMenuItem(value: 'jkk', child: Text('JKK')),
              DropdownMenuItem(value: 'jkm', child: Text('JKM'))
            ],
            onChanged: (v) {
              if (v != null) onChanged('program', v);
            }),
        SizedBox(height: 7.h),
        Row(children: [
          Expanded(
              child: _NumberTextField(
                  label: 'Bagian perusahaan',
                  value: row['employer_rate'],
                  onChanged: (v) => onChanged('employer_rate', v))),
          SizedBox(width: 8.w),
          Expanded(
              child: _NumberTextField(
                  label: 'Bagian karyawan',
                  value: row['employee_rate'],
                  onChanged: (v) => onChanged('employee_rate', v)))
        ]),
        SizedBox(height: 7.h),
        _NumberTextField(
            label: 'Batas upah (kosong = tanpa batas)',
            value: row['salary_cap'],
            onChanged: (v) => onChanged('salary_cap', v.isEmpty ? null : v)),
        if (row['program'] == 'jkk') ...[
          SizedBox(height: 7.h),
          DropdownButtonFormField<String>(
              value: row['jkk_risk_class']?.toString(),
              decoration: const InputDecoration(labelText: 'Kelas risiko JKK'),
              items: ['I', 'II', 'III', 'IV', 'V']
                  .map((v) =>
                      DropdownMenuItem(value: v, child: Text('Kelas $v')))
                  .toList(),
              onChanged: (v) => onChanged('jkk_risk_class', v)),
        ],
        SizedBox(height: 7.h),
        Row(children: [
          Expanded(
              child: _DateTextField(
                  label: 'Berlaku mulai',
                  value: row['effective_from'],
                  onChanged: (v) => onChanged('effective_from', v))),
          SizedBox(width: 8.w),
          Expanded(
              child: _DateTextField(
                  label: 'Berlaku sampai',
                  value: row['effective_to'],
                  nullable: true,
                  onChanged: (v) => onChanged('effective_to', v)))
        ]),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                label: const Text('Hapus aturan'))),
      ]));
}

class _TerRateCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final VoidCallback onDelete;
  final void Function(String key, dynamic value) onChanged;
  const _TerRateCard(
      {required this.row, required this.onChanged, required this.onDelete});
  @override
  Widget build(BuildContext context) => _CardSurface(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(children: [
        DropdownButtonFormField<String>(
            value: '${row['category'] ?? 'A'}',
            decoration: const InputDecoration(labelText: 'Kategori TER'),
            items: ['A', 'B', 'C']
                .map((v) =>
                    DropdownMenuItem(value: v, child: Text('Kategori $v')))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged('category', v);
            }),
        SizedBox(height: 7.h),
        Row(children: [
          Expanded(
              child: _NumberTextField(
                  label: 'Bruto mulai (Rp)',
                  value: row['income_range_start'],
                  onChanged: (v) => onChanged('income_range_start', v))),
          SizedBox(width: 8.w),
          Expanded(
              child: _NumberTextField(
                  label: 'Bruto sampai (kosong = tanpa batas)',
                  value: row['income_range_end'],
                  onChanged: (v) =>
                      onChanged('income_range_end', v.isEmpty ? null : v)))
        ]),
        SizedBox(height: 7.h),
        _NumberTextField(
            label: 'Tarif desimal (0,005 = 0,5%)',
            value: row['effective_rate'],
            onChanged: (v) => onChanged('effective_rate', v)),
        SizedBox(height: 7.h),
        Row(children: [
          Expanded(
              child: _DateTextField(
                  label: 'Berlaku mulai',
                  value: row['effective_from'],
                  onChanged: (v) => onChanged('effective_from', v))),
          SizedBox(width: 8.w),
          Expanded(
              child: _DateTextField(
                  label: 'Berlaku sampai',
                  value: row['effective_to'],
                  nullable: true,
                  onChanged: (v) => onChanged('effective_to', v)))
        ]),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                label: const Text('Hapus rentang'))),
      ]));
}

class _AnnualTaxSection extends StatelessWidget {
  final List<Map<String, dynamic>> brackets, ptkp;
  final bool saving;
  final VoidCallback onAddBracket, onAddPtkp, onSave;
  final ValueChanged<int> onDeleteBracket, onDeletePtkp;
  final void Function(int index, String key, dynamic value) onBracketChanged,
      onPtkpChanged;
  const _AnnualTaxSection(
      {required this.brackets,
      required this.ptkp,
      required this.saving,
      required this.onAddBracket,
      required this.onAddPtkp,
      required this.onSave,
      required this.onDeleteBracket,
      required this.onDeletePtkp,
      required this.onBracketChanged,
      required this.onPtkpChanged});
  @override
  Widget build(BuildContext context) => Column(children: [
        _CardSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
              child: Text('Lapisan tarif progresif',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            IconButton(
                onPressed: onAddBracket,
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary))
          ]),
          if (brackets.isEmpty) const Text('Belum ada lapisan tarif.'),
          ...brackets.asMap().entries.map((entry) => Column(children: [
                _NumberTextField(
                    label: 'Batas bawah (Rp)',
                    value: entry.value['bracket_start'],
                    onChanged: (v) =>
                        onBracketChanged(entry.key, 'bracket_start', v)),
                SizedBox(height: 6.h),
                Row(children: [
                  Expanded(
                      child: _NumberTextField(
                          label: 'Batas atas (kosong = tanpa batas)',
                          value: entry.value['bracket_end'],
                          onChanged: (v) => onBracketChanged(
                              entry.key, 'bracket_end', v.isEmpty ? null : v))),
                  SizedBox(width: 8.w),
                  Expanded(
                      child: _NumberTextField(
                          label: 'Tarif (0,05 = 5%)',
                          value: entry.value['rate'],
                          onChanged: (v) =>
                              onBracketChanged(entry.key, 'rate', v)))
                ]),
                SizedBox(height: 6.h),
                Row(children: [
                  Expanded(
                      child: _DateTextField(
                          label: 'Berlaku mulai',
                          value: entry.value['effective_from'],
                          onChanged: (v) => onBracketChanged(
                              entry.key, 'effective_from', v))),
                  SizedBox(width: 8.w),
                  Expanded(
                      child: _DateTextField(
                          label: 'Berlaku sampai',
                          value: entry.value['effective_to'],
                          nullable: true,
                          onChanged: (v) =>
                              onBracketChanged(entry.key, 'effective_to', v)))
                ]),
                Divider(height: 18.h),
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                        onPressed: () => onDeleteBracket(entry.key),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error),
                        label: const Text('Hapus lapisan'))),
              ])),
        ])),
        SizedBox(height: 8.h),
        _CardSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: Text('PTKP per status',
                    style: TextStyle(fontWeight: FontWeight.w800))),
            IconButton(
                onPressed: onAddPtkp,
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary))
          ]),
          if (ptkp.isEmpty) const Text('Belum ada nilai PTKP.'),
          ...ptkp.asMap().entries.map((entry) => Column(children: [
                TextFormField(
                    initialValue: '${entry.value['status'] ?? 'TK/0'}',
                    decoration: const InputDecoration(
                        labelText: 'Status PTKP', border: OutlineInputBorder()),
                    onChanged: (v) =>
                        onPtkpChanged(entry.key, 'status', v.toUpperCase())),
                SizedBox(height: 6.h),
                _NumberTextField(
                    label: 'Batas tahunan (Rp)',
                    value: entry.value['annual_threshold'],
                    onChanged: (v) =>
                        onPtkpChanged(entry.key, 'annual_threshold', v)),
                SizedBox(height: 6.h),
                Row(children: [
                  Expanded(
                      child: _DateTextField(
                          label: 'Berlaku mulai',
                          value: entry.value['effective_from'],
                          onChanged: (v) =>
                              onPtkpChanged(entry.key, 'effective_from', v))),
                  SizedBox(width: 8.w),
                  Expanded(
                      child: _DateTextField(
                          label: 'Berlaku sampai',
                          value: entry.value['effective_to'],
                          nullable: true,
                          onChanged: (v) =>
                              onPtkpChanged(entry.key, 'effective_to', v)))
                ]),
                Divider(height: 18.h),
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                        onPressed: () => onDeletePtkp(entry.key),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error),
                        label: const Text('Hapus status'))),
              ])),
        ])),
        SizedBox(height: 8.h),
        _SaveButton(
            label: 'Simpan tarif tahunan & PTKP',
            busy: saving,
            onPressed: onSave),
      ]);
}

class _DateTextField extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool nullable;
  final ValueChanged<String?> onChanged;
  const _DateTextField(
      {required this.label,
      required this.value,
      required this.onChanged,
      this.nullable = false});
  @override
  Widget build(BuildContext context) {
    final text = value?.toString() ?? '';
    return TextFormField(
      initialValue: text.length >= 10 ? text.substring(0, 10) : text,
      decoration: InputDecoration(
          labelText: label,
          hintText: 'YYYY-MM-DD',
          border: const OutlineInputBorder(),
          suffixIcon: nullable
              ? IconButton(
                  tooltip: 'Hapus tanggal akhir',
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.clear_rounded))
              : const Icon(Icons.calendar_today_outlined)),
      onChanged: onChanged,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;
  const _SaveButton(
      {required this.label, required this.busy, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
          onPressed: busy ? null : onPressed,
          icon: busy
              ? SizedBox.square(
                  dimension: 16.w,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_rounded),
          label: Text(busy ? 'Menyimpan…' : label),
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r)))));
}

class _CardSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const _CardSurface({required this.child, this.margin});
  @override
  Widget build(BuildContext context) => Container(
      margin: margin,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .91),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: .035),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ]),
      child: child);
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(30.r)),
      child: Text(label,
          style: TextStyle(
              color: AppColors.primary,
              fontSize: 9.sp,
              fontWeight: FontWeight.w800)));
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});
  @override
  Widget build(BuildContext context) => _CardSurface(
          child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.primary),
        SizedBox(width: 10.w),
        Expanded(
            child: Text(message,
                style: TextStyle(
                    fontSize: 11.sp, color: AppColors.onSurfaceVariant)))
      ]));
}

class _WarningCard extends StatelessWidget {
  final String message;
  const _WarningCard({required this.message});
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
          color: AppColors.warningAmber.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14.r)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.warningAmber),
        SizedBox(width: 8.w),
        Expanded(
            child: Text(message,
                style: TextStyle(color: AppColors.onSurface, fontSize: 11.sp)))
      ]));
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12.r)),
      child: Text(message,
          style: TextStyle(color: AppColors.error, fontSize: 12.sp)));
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
