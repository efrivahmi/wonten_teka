import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/api/api_client.dart';

class BusinessTripFormScreen extends StatefulWidget {
  const BusinessTripFormScreen({super.key});
  @override State<BusinessTripFormScreen> createState() => _BusinessTripFormScreenState();
}
class _BusinessTripFormScreenState extends State<BusinessTripFormScreen> {
  final _key = GlobalKey<FormState>(); final _api = ApiClient();
  final _start = TextEditingController(), _end = TextEditingController(), _location = TextEditingController(), _description = TextEditingController(); bool _saving = false;
  @override void dispose() { _start.dispose(); _end.dispose(); _location.dispose(); _description.dispose(); super.dispose(); }
  Future<void> _pick(TextEditingController c, {DateTime? first}) async { final now = DateTime.now(); final d = await showDatePicker(context: context, initialDate: first ?? now, firstDate: first ?? now, lastDate: now.add(const Duration(days: 730))); if (d != null) c.text = d.toIso8601String().split('T').first; }
  Future<void> _submit() async { if (!_key.currentState!.validate()) return; setState(() => _saving = true); try { await _api.post('/attendance/business-trip', data: {'start_date': _start.text, 'end_date': _end.text, 'location': _location.text.trim(), 'description': _description.text.trim()}); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dinas luar berhasil diajukan.'))); context.pop(); } } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } finally { if (mounted) setState(() => _saving = false); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Pengajuan dinas luar')), body: Form(key: _key, child: ListView(padding: const EdgeInsets.all(20), children: [
    Text('Rencana perjalanan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Dinas luar yang disetujui akan dicatat sebagai kehadiran.'), const SizedBox(height: 24),
    Row(children: [Expanded(child: TextFormField(controller: _start, readOnly: true, onTap: () => _pick(_start), decoration: const InputDecoration(labelText: 'Mulai'), validator: _required)), const SizedBox(width: 12), Expanded(child: TextFormField(controller: _end, readOnly: true, onTap: () => _pick(_end, first: DateTime.tryParse(_start.text)), decoration: const InputDecoration(labelText: 'Selesai'), validator: _required))]), const SizedBox(height: 14),
    TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Lokasi tujuan', prefixIcon: Icon(Icons.location_on_outlined)), validator: _required), const SizedBox(height: 14),
    TextFormField(controller: _description, maxLines: 4, decoration: const InputDecoration(labelText: 'Keperluan dinas'), validator: _required), const SizedBox(height: 24),
    FilledButton(onPressed: _saving ? null : _submit, child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Kirim pengajuan')),
  ])));
  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}
