import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/admin_pagination_bar.dart';

class AdminBiometricScreen extends StatefulWidget {
  const AdminBiometricScreen({super.key});

  @override
  State<AdminBiometricScreen> createState() => _AdminBiometricScreenState();
}

class _AdminBiometricScreenState extends State<AdminBiometricScreen> {
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;
  int _currentPage = 1, _lastPage = 1, _totalItems = 0;

  ApiClient get _api => context.read<ApiClient>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get('/admin/biometrics',
          queryParameters: {'page': page, 'per_page': 25});
      final outer = Map<String, dynamic>.from(response.data as Map);
      final pageData = Map<String, dynamic>.from(
          outer['data'] is Map ? outer['data'] : outer);
      final raw = pageData['data'];
      if (!mounted) return;
      setState(() {
        _items = (raw as List? ?? const [])
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        _currentPage = pageData['current_page'] as int? ?? page;
        _lastPage = pageData['last_page'] as int? ?? 1;
        _totalItems = pageData['total'] as int? ?? _items.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Data biometrik belum dapat dimuat.';
        });
      }
    }
  }

  Future<void> _reset(Map<String, dynamic> item) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data wajah?'),
        content: Text(
          '${item['full_name'] ?? 'Karyawan'} harus melakukan pendaftaran wajah ulang.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (approved != true) return;
    await _api.delete('/admin/biometrics/${item['id']}/reset');
    await _load();
  }

  @override
  Widget build(BuildContext context) => BrandPageBackground(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Biometrik Wajah'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(children: [
                      const SizedBox(height: 120),
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.errorCrimson),
                      const SizedBox(height: 12),
                      Center(child: Text(_error!)),
                      Center(
                          child: TextButton(
                              onPressed: _load,
                              child: const Text('Coba lagi'))),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return AdminPaginationBar(
                              currentPage: _currentPage,
                              lastPage: _lastPage,
                              total: _totalItems,
                              onPageChanged: (page) => _load(page: page));
                        }
                        final item = _items[index - 1];
                        final enrolled = item['face_enrolled'] == true;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: enrolled
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceContainerHigh,
                              child: Icon(enrolled
                                  ? Icons.face
                                  : Icons.face_retouching_off),
                            ),
                            title: Text(item['full_name']?.toString() ?? '-'),
                            subtitle: Text(
                              '${item['employee_number'] ?? 'Tanpa nomor'} • Mobile ${item['mobile_pose_count'] ?? 0} pose • Web ${item['web_pose_count'] ?? 0} pose',
                            ),
                            trailing: IconButton(
                              tooltip: 'Reset data wajah',
                              onPressed: enrolled ? () => _reset(item) : null,
                              icon: const Icon(Icons.restart_alt,
                                  color: AppColors.errorCrimson),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ));
}
