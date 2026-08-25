import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key});
  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _nameController = TextEditingController();
  String _frequency = 'Setiap Hari';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  final _frequencies = ['Setiap Hari', 'Hari Kerja', 'Akhir Pekan', 'Kustom'];

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Tambah Habit', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(24.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _label('NAMA HABIT'),
        SizedBox(height: 8.h),
        TextFormField(controller: _nameController, decoration: _deco('e.g. Olahraga Pagi')),
        SizedBox(height: 24.h),

        _label('FREKUENSI'),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(initialValue: _frequency,
          items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (v) { if (v != null) setState(() => _frequency = v); }, decoration: _deco('Pilih frekuensi')),
        SizedBox(height: 24.h),

        _label('WAKTU PENGINGAT'),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () async {
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
        SizedBox(height: 24.h),

        _label('IKON'),
        SizedBox(height: 8.h),
        Wrap(spacing: 12.w, runSpacing: 12.h, children: [
          Icons.fitness_center, Icons.menu_book, Icons.self_improvement, Icons.water_drop,
          Icons.directions_run, Icons.music_note, Icons.code, Icons.brush,
        ].map((icon) => Container(
          width: 48.w, height: 48.w,
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
          child: Icon(icon, color: AppColors.onSurfaceVariant, size: 24.w),
        )).toList()),
        SizedBox(height: 32.h),

        SizedBox(height: 52.h, child: ElevatedButton(
          onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit berhasil ditambahkan!'))); context.pop(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          child: Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp)),
        )),
      ]))),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surfaceContainerLow,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryContainer)));
}
