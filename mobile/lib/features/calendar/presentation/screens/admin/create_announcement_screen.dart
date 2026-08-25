import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/api/api_client.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final Map<String, String> _priorityMap = {
    'Rendah': 'low',
    'Normal': 'normal',
    'Tinggi': 'high',
    'Penting': 'urgent'
  };

  final Map<String, String> _targetMap = {
    'Semua Karyawan': 'company',
    'Departemen': 'department',
  };

  String _selectedPriority = 'Normal';
  String _selectedTarget = 'Semua Karyawan';
  String? _selectedDepartment;

  final List<String> _departments = [
    'Engineering',
    'Human Resources',
    'Marketing',
    'Sales',
    'Finance',
    'Management',
    'Operations'
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTarget == 'Departemen' && _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih departemen target'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final api = context.read<ApiClient>();

      final data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'priority': _priorityMap[_selectedPriority],
        'target_type': _targetMap[_selectedTarget],
      };

      if (_selectedTarget == 'Departemen') {
        data['target_id'] = _selectedDepartment;
      }

      await api.post('/admin/announcements', data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengumuman berhasil dipublikasikan!'),
            backgroundColor: AppColors.successEmerald,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mempublikasikan pengumuman: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          title: Text('Buat Pengumuman',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('JUDUL'),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _titleController,
                        decoration: _deco('Judul pengumuman'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                      ),
                      SizedBox(height: 24.h),
                      _label('PRIORITAS'),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                          initialValue: _selectedPriority,
                          items: _priorityMap.keys
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedPriority = v!),
                          decoration: _deco('')),
                      SizedBox(height: 24.h),
                      _label('TARGET AUDIENS'),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                          initialValue: _selectedTarget,
                          items: _targetMap.keys
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedTarget = v!;
                              if (_selectedTarget != 'Departemen') {
                                _selectedDepartment = null;
                              }
                            });
                          },
                          decoration: _deco('')),
                      if (_selectedTarget == 'Departemen') ...[
                        SizedBox(height: 16.h),
                        _label('PILIH DEPARTEMEN'),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField<String>(
                            initialValue: _selectedDepartment,
                            hint: const Text('Pilih Departemen'),
                            items: _departments
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedDepartment = v),
                            decoration: _deco('')),
                      ],
                      SizedBox(height: 24.h),
                      _label('ISI PENGUMUMAN'),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: _deco('Ketik isi pengumuman...'),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Isi pengumuman wajib diisi'
                            : null,
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r))),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text('Publikasi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: AppColors.onPrimaryContainer)),
                          )),
                    ]),
              ))),
    );
  }

  Widget _label(String t) => Text(t,
      style: TextStyle(
          color: AppColors.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2));

  InputDecoration _deco(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.outlineVariant)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)));
}

