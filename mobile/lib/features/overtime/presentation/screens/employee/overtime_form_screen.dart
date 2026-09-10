import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/api/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_exceptions.dart';

class OvertimeFormScreen extends StatefulWidget {
  const OvertimeFormScreen({super.key});
  @override
  State<OvertimeFormScreen> createState() => _OvertimeFormScreenState();
}

class _OvertimeFormScreenState extends State<OvertimeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  ApiClient get _api => context.read<ApiClient>();
  final _date = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _reason = TextEditingController();
  String _type = 'Hari Kerja';
  bool _saving = false;

  @override
  void dispose() {
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (value != null) _date.text = value.toIso8601String().split('T').first;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final value =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (value != null) {
      controller.text =
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.post('/overtime/request', data: {
        'date': _date.text,
        'start_time': _start.text,
        'end_time': _end.text,
        'overtime_type': _type,
        'reason': _reason.text.trim()
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Pengajuan lembur berhasil dikirim.')));
        context.pop();
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ajukan lembur')),
        body: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text('Detail pekerjaan',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                  'Lengkapi waktu dan pekerjaan yang memerlukan persetujuan.'),
              const SizedBox(height: 24),
              TextFormField(
                  controller: _date,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      suffixIcon: Icon(Icons.calendar_month)),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tanggal wajib dipilih' : null),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _start,
                        readOnly: true,
                        onTap: () => _pickTime(_start),
                        decoration: const InputDecoration(
                            labelText: 'Mulai',
                            suffixIcon: Icon(Icons.schedule)),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib' : null)),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _end,
                        readOnly: true,
                        onTap: () => _pickTime(_end),
                        decoration: const InputDecoration(
                            labelText: 'Selesai',
                            suffixIcon: Icon(Icons.schedule)),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib' : null))
              ]),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Jenis lembur'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Hari Kerja', child: Text('Hari Kerja')),
                    DropdownMenuItem(
                        value: 'Hari Libur', child: Text('Hari Libur'))
                  ],
                  onChanged: (v) => setState(() => _type = v!)),
              const SizedBox(height: 14),
              TextFormField(
                  controller: _reason,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Pekerjaan / alasan'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Pekerjaan wajib dijelaskan'
                      : null),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Kirim pengajuan')),
            ])),
      );
}
