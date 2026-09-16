import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/api/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_exceptions.dart';

class AttendanceAdjustmentFormScreen extends StatefulWidget {
  const AttendanceAdjustmentFormScreen({super.key});
  @override
  State<AttendanceAdjustmentFormScreen> createState() =>
      _AttendanceAdjustmentFormScreenState();
}

class _AttendanceAdjustmentFormScreenState
    extends State<AttendanceAdjustmentFormScreen> {
  final _key = GlobalKey<FormState>();
  ApiClient get _api => context.read<ApiClient>();
  final _date = TextEditingController(),
      _in = TextEditingController(),
      _out = TextEditingController(),
      _reason = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _date.dispose();
    _in.dispose();
    _out.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _datePicker() async {
    final d = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 1)),
        firstDate: DateTime.now().subtract(const Duration(days: 90)),
        lastDate: DateTime.now());
    if (d != null) _date.text = d.toIso8601String().split('T').first;
  }

  Future<void> _timePicker(TextEditingController c) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (t != null) {
      c.text =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.post('/attendance/adjustment', data: {
        'date': _date.text,
        'check_in': _in.text,
        'check_out': _out.text,
        'reason': _reason.text.trim()
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Koreksi kehadiran berhasil diajukan.')));
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Pengajuan lupa absensi')),
      body: Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text('Lupa absen',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'Tambahkan waktu masuk dan keluar yang seharusnya. Setelah dikirim, pengajuan tidak dapat diedit atau dihapus.'),
            const SizedBox(height: 24),
            TextFormField(
                controller: _date,
                readOnly: true,
                onTap: _datePicker,
                decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    suffixIcon: Icon(Icons.calendar_month)),
                validator: _required),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _in,
                      readOnly: true,
                      onTap: () => _timePicker(_in),
                      decoration: const InputDecoration(labelText: 'Jam masuk'),
                      validator: _required)),
              const SizedBox(width: 12),
              Expanded(
                  child: TextFormField(
                      controller: _out,
                      readOnly: true,
                      onTap: () => _timePicker(_out),
                      decoration:
                          const InputDecoration(labelText: 'Jam keluar'),
                      validator: _required))
            ]),
            const SizedBox(height: 14),
            TextFormField(
                controller: _reason,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Alasan'),
                validator: _required),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim pengajuan')),
          ])));
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}
