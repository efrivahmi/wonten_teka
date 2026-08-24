import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class CreateAnnouncementScreen extends StatelessWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Buat Pengumuman', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(24.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _label('JUDUL'), SizedBox(height: 8.h), TextFormField(decoration: _deco('Judul pengumuman')),
        SizedBox(height: 24.h),
        _label('PRIORITAS'), SizedBox(height: 8.h),
        DropdownButtonFormField<String>(value: 'Normal', items: ['Rendah', 'Normal', 'Tinggi'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (_) {}, decoration: _deco('')),
        SizedBox(height: 24.h),
        _label('TARGET AUDIENS'), SizedBox(height: 8.h),
        DropdownButtonFormField<String>(value: 'Semua Karyawan', items: ['Semua Karyawan', 'Departemen Tertentu', 'Karyawan Tertentu'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (_) {}, decoration: _deco('')),
        SizedBox(height: 24.h),
        _label('ISI PENGUMUMAN'), SizedBox(height: 8.h),
        TextFormField(maxLines: 6, decoration: _deco('Ketik isi pengumuman...')),
        SizedBox(height: 32.h),
        SizedBox(height: 52.h, child: ElevatedButton(
          onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengumuman dipublikasi!'))); context.pop(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          child: Text('Publikasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp)),
        )),
      ]))),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surfaceContainerLow,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryContainer)));
}
