import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../schedule/bloc/task_cubit.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key});
  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _frequency = 'Setiap Hari';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  final _frequencies = ['Setiap Hari', 'Hari Kerja', 'Akhir Pekan', 'Kustom'];

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final formattedTime = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}:00';
      context.read<TaskCubit>().createTask(
        title: _nameController.text,
        recurrenceRule: _frequency,
        reminderTime: formattedTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Tambah Habit', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskActionSuccess) {
            context.pop();
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TaskLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w), 
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, 
                  children: [
                    _label('NAMA HABIT'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController, 
                      decoration: _deco('e.g. Olahraga Pagi'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama habit wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    SizedBox(height: 24.h),

                    _label('FREKUENSI'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: _frequency,
                      items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: isLoading ? null : (v) { if (v != null) setState(() => _frequency = v); }, 
                      decoration: _deco('Pilih frekuensi'),
                    ),
                    SizedBox(height: 24.h),

                    _label('WAKTU PENGINGAT'),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: isLoading ? null : () async {
                        final t = await showTimePicker(context: context, initialTime: _reminderTime);
                        if (t != null) setState(() => _reminderTime = t);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
                        child: Row(children: [
                          Icon(Icons.alarm, color: AppColors.onSurfaceVariant, size: 20.w),
                          SizedBox(width: 12.w),
                          Text(_reminderTime.format(context), style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
                        ]),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    SizedBox(
                      height: 52.h, 
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer, 
                          foregroundColor: AppColors.onPrimary, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: isLoading 
                            ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
                            : Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp)),
                      )
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surfaceContainerLow,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryContainer)));
}

