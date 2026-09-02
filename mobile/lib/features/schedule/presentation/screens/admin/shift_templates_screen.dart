import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';

class ShiftTemplatesScreen extends StatefulWidget {
  const ShiftTemplatesScreen({super.key});

  @override
  State<ShiftTemplatesScreen> createState() => _ShiftTemplatesScreenState();
}

class _ShiftTemplatesScreenState extends State<ShiftTemplatesScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<dynamic> _templates = [];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/admin/shifts');
      if (mounted) {
        setState(() {
          _templates = response.data['data'] as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteTemplate(int id) async {
    try {
      await _api.delete('/admin/shifts/$id');
      _loadTemplates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  Color _getColor(int index) {
    const colors = [
      AppColors.successEmerald,
      AppColors.warningAmber,
      AppColors.infoCerulean,
      AppColors.primary
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text('Template Shift',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final refresh = await context.push('/admin/shifts/form');
            if (refresh == true) _loadTemplates();
          },
          backgroundColor: AppColors.primaryContainer,
          icon: const Icon(Icons.add, color: AppColors.onPrimary),
          label: const Text('Template Baru',
              style: TextStyle(color: AppColors.onPrimary))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? const Center(child: Text('Belum ada template shift'))
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _templates.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final t = _templates[index];
                    return _TemplateCard(
                      title: t['name'],
                      time:
                          '${t['start_time'].toString().substring(0, 5)} - ${t['end_time'].toString().substring(0, 5)}',
                      color: _getColor(index),
                      isDefault: t['is_default'] == true,
                      onEdit: () async {
                        final refresh =
                            await context.push('/admin/shifts/form', extra: t);
                        if (refresh == true) _loadTemplates();
                      },
                      onDelete: () {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                    title: const Text('Hapus Template?'),
                                    content: const Text(
                                        'Tugas shift (assignments) yang sudah dibuat dengan template ini tidak akan terhapus.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Batal')),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteTemplate(t['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.errorCrimson),
                                          child: const Text('Hapus',
                                              style: TextStyle(
                                                  color: Colors.white)))
                                    ]));
                      },
                    );
                  }),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title, time;
  final Color color;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateCard(
      {required this.title,
      required this.time,
      required this.color,
      required this.isDefault,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Text(title,
                    style: TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp)),
                if (isDefault) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4.r)),
                    child: Text('Default',
                        style: TextStyle(
                            color: AppColors.onPrimary, fontSize: 10.sp)),
                  )
                ]
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 14.w, color: AppColors.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text(time,
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
              ],
            ),
          ]),
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus',
                            style: TextStyle(color: AppColors.errorCrimson))),
                  ]),
            ],
          ),
        ),
      ],
    ),
  ),
);
}
