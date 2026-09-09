import 'package:flutter/material.dart';
import '../../../../../core/api/api_client.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}
class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _api = ApiClient(); final _portal = TextEditingController(); final _hero = TextEditingController();
  final _departments = TextEditingController(), _positions = TextEditingController(), _banks = TextEditingController();
  bool _loading = true, _saving = false; List<Map<String, dynamic>> _menus = [];
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _portal.dispose(); _hero.dispose(); _departments.dispose(); _positions.dispose(); _banks.dispose(); super.dispose(); }
  Future<void> _load() async { setState(() => _loading = true); try { final response = await _api.get('/app-config'); final data = Map<String, dynamic>.from(response.data['data'] as Map); final branding = Map<String, dynamic>.from(data['branding'] as Map? ?? {}); final dropdowns = Map<String, dynamic>.from(data['dropdowns'] as Map? ?? {}); _portal.text = branding['portal_name']?.toString() ?? ''; _hero.text = branding['hero_image_url']?.toString() ?? ''; _departments.text = (dropdowns['departments'] as List? ?? []).join(', '); _positions.text = (dropdowns['positions'] as List? ?? []).join(', '); _banks.text = (dropdowns['banks'] as List? ?? []).join(', '); _menus = (data['employee_menu'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(); } finally { if (mounted) setState(() => _loading = false); } }
  List<String> _list(TextEditingController c) => c.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
  Future<void> _save() async { setState(() => _saving = true); try { await _api.put('/admin/app-config', data: {'branding': {'portal_name': _portal.text.trim(), 'hero_image_url': _hero.text.trim().isEmpty ? null : _hero.text.trim()}, 'employee_menu': _menus, 'dropdowns': {'departments': _list(_departments), 'positions': _list(_positions), 'banks': _list(_banks)}}); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfigurasi aplikasi tersimpan.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } finally { if (mounted) setState(() => _saving = false); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Konfigurasi aplikasi')), body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(20), children: [
    Text('Branding', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 14),
    TextField(controller: _portal, decoration: const InputDecoration(labelText: 'Nama portal')), const SizedBox(height: 12),
    TextField(controller: _hero, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'URL gambar hero', helperText: 'Kosongkan untuk memakai gambar bawaan')), const SizedBox(height: 28),
    Text('Menu karyawan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8),
    ..._menus.asMap().entries.map((entry) => Card(child: SwitchListTile(value: entry.value['enabled'] == true, title: Text(entry.value['label']?.toString() ?? entry.value['key'].toString()), subtitle: Text(entry.value['key'].toString()), onChanged: (value) => setState(() => _menus[entry.key]['enabled'] = value)))),
    const SizedBox(height: 24), Text('Isi dropdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Pisahkan setiap pilihan dengan koma.'), const SizedBox(height: 14),
    TextField(controller: _departments, maxLines: 3, decoration: const InputDecoration(labelText: 'Departemen / divisi')), const SizedBox(height: 12),
    TextField(controller: _positions, maxLines: 3, decoration: const InputDecoration(labelText: 'Jabatan')), const SizedBox(height: 12),
    TextField(controller: _banks, maxLines: 2, decoration: const InputDecoration(labelText: 'Bank')),
    const SizedBox(height: 20), FilledButton(onPressed: _saving ? null : _save, child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Simpan konfigurasi')),
  ]));
}
