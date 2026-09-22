import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';

class AdminContentCrudScreen extends StatefulWidget {
  const AdminContentCrudScreen({super.key});
  @override
  State<AdminContentCrudScreen> createState() => _AdminContentCrudScreenState();
}

class _AdminContentCrudScreenState extends State<AdminContentCrudScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  List<Map<String, dynamic>> tasks = [], announcements = [], employees = [];
  bool loading = true;
  ApiClient get api => context.read<ApiClient>();
  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 2, vsync: this);
    load();
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> rows(dynamic raw) {
    final v = raw is Map && raw['data'] is List ? raw['data'] : raw;
    return (v as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final r = await Future.wait([
        api.get('/admin/tasks'),
        api.get('/admin/announcements'),
        api.get('/admin/employees')
      ]);
      tasks = rows(r[0].data);
      announcements = rows(r[1].data);
      employees = rows(r[2].data);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> editTask([Map<String, dynamic>? item]) async {
    final title = TextEditingController(text: item?['title']);
    int? employee = item?['employee_id'];
    bool habit = item?['is_habit'] == true;
    final ok = await showDialog<bool>(
        context: context,
        builder: (d) => StatefulBuilder(
            builder: (c, setLocal) => AlertDialog(
                    title: Text(
                        item == null ? 'Tambah Task/Habit' : 'Edit Task/Habit'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButtonFormField<int>(
                          initialValue: employee,
                          decoration:
                              const InputDecoration(labelText: 'Karyawan'),
                          items: employees
                              .map((e) => DropdownMenuItem(
                                  value: e['id'] as int,
                                  child: Text(e['full_name'].toString())))
                              .toList(),
                          onChanged: (v) => employee = v),
                      TextField(
                          controller: title,
                          decoration:
                              const InputDecoration(labelText: 'Judul')),
                      SwitchListTile(
                          value: habit,
                          title: const Text('Habit'),
                          onChanged: (v) => setLocal(() => habit = v))
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(d),
                          child: const Text('Batal')),
                      FilledButton(
                          onPressed: () async {
                            if (employee == null || title.text.trim().isEmpty) {
                              return;
                            }
                            final data = {
                              'employee_id': employee,
                              'title': title.text.trim(),
                              'is_habit': habit,
                              'task_date': habit
                                  ? null
                                  : DateTime.now()
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                              'recurrence_rule': habit ? 'daily' : null,
                              'is_active': true
                            };
                            if (item == null) {
                              await api.post('/admin/tasks', data: data);
                            } else {
                              await api.put('/admin/tasks/${item['id']}',
                                  data: data);
                            }
                            if (d.mounted) Navigator.pop(d, true);
                          },
                          child: const Text('Simpan'))
                    ])));
    title.dispose();
    if (ok == true) await load();
  }

  Future<void> editAnnouncement([Map<String, dynamic>? item]) async {
    final title = TextEditingController(text: item?['title']);
    final body = TextEditingController(text: item?['body']);
    final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
                title: Text(
                    item == null ? 'Tambah Pengumuman' : 'Edit Pengumuman'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Judul')),
                  TextField(
                      controller: body,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Isi'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(d),
                      child: const Text('Batal')),
                  FilledButton(
                      onPressed: () async {
                        final data = {
                          'title': title.text.trim(),
                          'content': body.text.trim(),
                          'priority': item?['priority'] ?? 'normal',
                          'target_type': item?['target_type'] ?? 'company',
                          'target_value': item?['target_value']
                        };
                        if (item == null) {
                          await api.post('/admin/announcements', data: data);
                        } else {
                          await api.put('/admin/announcements/${item['id']}',
                              data: data);
                        }
                        if (d.mounted) Navigator.pop(d, true);
                      },
                      child: const Text('Simpan'))
                ]));
    title.dispose();
    body.dispose();
    if (ok == true) await load();
  }

  Future<void> remove(String path) async {
    await api.delete(path);
    await load();
  }

  Widget list(List<Map<String, dynamic>> data, bool isTask) => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (c, i) {
        final x = data[i];
        return Card(
            child: ListTile(
                title: Text(x['title']?.toString() ?? '-'),
                subtitle: Text(isTask
                    ? '${x['employee']?['full_name'] ?? '-'} • ${x['is_habit'] == true ? 'Habit' : 'Daily Task'}'
                    : x['body']?.toString() ?? ''),
                trailing: Wrap(children: [
                  IconButton(
                      onPressed: () =>
                          isTask ? editTask(x) : editAnnouncement(x),
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () => remove(isTask
                          ? '/admin/tasks/${x['id']}'
                          : '/admin/announcements/${x['id']}'),
                      icon: const Icon(Icons.delete, color: Colors.red))
                ])));
      });
  @override
  Widget build(BuildContext context) => BrandPageBackground(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              title: const Text('Kelola Konten Karyawan'),
              bottom: TabBar(controller: tabs, tabs: const [
                Tab(text: 'Task & Habit'),
                Tab(text: 'Pengumuman')
              ])),
          floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  tabs.index == 0 ? editTask() : editAnnouncement(),
              child: const Icon(Icons.add)),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: tabs,
                  children: [list(tasks, true), list(announcements, false)])));
}
