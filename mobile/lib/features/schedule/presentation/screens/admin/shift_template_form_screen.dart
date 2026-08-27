import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';

class ShiftTemplateFormScreen extends StatefulWidget {
  final Map<String, dynamic>? template;
  const ShiftTemplateFormScreen({super.key, this.template});

  @override
  State<ShiftTemplateFormScreen> createState() =>
      _ShiftTemplateFormScreenState();
}

class _ShiftTemplateFormScreenState extends State<ShiftTemplateFormScreen> {
  late final ApiClient _api;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _gracePeriodController;

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isDefault = false;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _nameController =
        TextEditingController(text: widget.template?['name'] ?? '');
    _gracePeriodController = TextEditingController(
        text: widget.template?['grace_period_minutes']?.toString() ?? '15');

    if (widget.template != null) {
      final startParts = widget.template!['start_time'].toString().split(':');
      final endParts = widget.template!['end_time'].toString().split(':');
      _startTime = TimeOfDay(
          hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      _endTime = TimeOfDay(
          hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
      _isDefault = widget.template!['is_default'] == true;
      _isActive = widget.template!['is_active'] == true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gracePeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text,
      'start_time': _formatTime(_startTime),
      'end_time': _formatTime(_endTime),
      'grace_period_minutes': int.tryParse(_gracePeriodController.text) ?? 0,
      'is_default': _isDefault,
      'is_active': _isActive,
    };

    try {
      if (widget.template == null) {
        await _api.post('/admin/shifts', data: data);
      } else {
        await _api.put('/admin/shifts/${widget.template!['id']}', data: data);
      }

      if (mounted) {
        context.pop(true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;

    return Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: () => context.pop()),
            title: Text(isEditing ? 'Edit Template' : 'Template Baru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.bold))),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    InfoCard(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Nama Shift (contoh: Shift Pagi)',
                              border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                                child: InkWell(
                              onTap: () => _selectTime(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                    labelText: 'Jam Masuk',
                                    border: OutlineInputBorder()),
                                child: Text(_formatTime(_startTime)),
                              ),
                            )),
                            SizedBox(width: 16.w),
                            Expanded(
                                child: InkWell(
                              onTap: () => _selectTime(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                    labelText: 'Jam Keluar',
                                    border: OutlineInputBorder()),
                                child: Text(_formatTime(_endTime)),
                              ),
                            )),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _gracePeriodController,
                          decoration: const InputDecoration(
                              labelText: 'Toleransi Keterlambatan (menit)',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        SizedBox(height: 16.h),
                        SwitchListTile(
                          title: const Text('Jadikan Default'),
                          subtitle:
                              const Text('Tandai sebagai shift utama karyawan'),
                          value: _isDefault,
                          onChanged: (v) => setState(() => _isDefault = v),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    )),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Simpan Template'),
                      ),
                    )
                  ],
                ))));
  }
}

