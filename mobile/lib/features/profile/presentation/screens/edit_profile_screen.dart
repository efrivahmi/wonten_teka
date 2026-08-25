import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Budi Santoso');
  final _emailCtrl = TextEditingController(text: 'budi@company.com');
  final _phoneCtrl = TextEditingController(text: '+62 812-3456-7890');
  final _addressCtrl = TextEditingController(text: 'Jl. Sudirman No. 52, Jakarta');

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _addressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Edit Profil', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(24.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Avatar
        Center(child: Stack(children: [
          CircleAvatar(radius: 48.r, backgroundColor: AppColors.surfaceContainerHigh, child: Icon(Icons.person, size: 48.w, color: AppColors.onSurfaceVariant)),
          Positioned(bottom: 0, right: 0, child: Container(
            padding: EdgeInsets.all(6.w), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryContainer),
            child: Icon(Icons.camera_alt, color: AppColors.onPrimary, size: 16.w))),
        ])),
        SizedBox(height: 32.h),
        _label('NAMA LENGKAP'), SizedBox(height: 8.h), TextFormField(controller: _nameCtrl, decoration: _deco('Nama lengkap')),
        SizedBox(height: 24.h),
        _label('EMAIL'), SizedBox(height: 8.h), TextFormField(controller: _emailCtrl, decoration: _deco('Email')),
        SizedBox(height: 24.h),
        _label('TELEPON'), SizedBox(height: 8.h), TextFormField(controller: _phoneCtrl, decoration: _deco('Nomor telepon')),
        SizedBox(height: 24.h),
        _label('ALAMAT'), SizedBox(height: 8.h), TextFormField(controller: _addressCtrl, maxLines: 2, decoration: _deco('Alamat')),
        SizedBox(height: 32.h),
        SizedBox(height: 52.h, child: ElevatedButton(
          onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!'))); context.pop(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          child: Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp)))),
      ]))),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surfaceContainerLow,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryContainer)));
}
