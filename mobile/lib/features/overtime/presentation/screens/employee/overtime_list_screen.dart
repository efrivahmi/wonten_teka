import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';

class OvertimeListScreen extends StatefulWidget {
  const OvertimeListScreen({super.key});
  @override State<OvertimeListScreen> createState() => _OvertimeListScreenState();
}

class _OvertimeListScreenState extends State<OvertimeListScreen> {
  final _api = ApiClient();
  late Future<List<Map<String, dynamic>>> _future = _load();
  Future<List<Map<String, dynamic>>> _load() async {
    final response = await _api.get('/overtime/history');
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  void _refresh() => setState(() => _future = _load());

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pengajuan lembur')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async { await context.push('/app/overtime/new'); _refresh(); },
      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      icon: const Icon(Icons.add), label: const Text('Ajukan lembur'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: _future, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return _Message(icon: Icons.cloud_off, text: snapshot.error.toString(), action: _refresh);
      final items = snapshot.data ?? [];
      if (items.isEmpty) return _Message(icon: Icons.more_time, text: 'Belum ada pengajuan lembur.', action: _refresh);
      return RefreshIndicator(onRefresh: () async => _refresh(), child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) { final item = items[index]; return Card(child: ListTile(
          onTap: () => context.push('/app/overtime/detail', extra: item),
          leading: const CircleAvatar(backgroundColor: Color(0xFFE9FBCF), child: Icon(Icons.schedule, color: AppColors.primary)),
          title: Text(item['date']?.toString().split('T').first ?? '-'),
          subtitle: Text("${item['start_time'] ?? '-'} – ${item['end_time'] ?? '-'} • ${item['overtime_type'] ?? '-'}"),
          trailing: Text((item['status'] ?? 'pending').toString().toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        )); },
      ));
    }),
  );
}

class _Message extends StatelessWidget {
  final IconData icon; final String text; final VoidCallback action;
  const _Message({required this.icon, required this.text, required this.action});
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 52, color: AppColors.primary), const SizedBox(height: 12), Text(text, textAlign: TextAlign.center), const SizedBox(height: 16), OutlinedButton(onPressed: action, child: const Text('Muat ulang')),
  ])));
}
