import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/repositories/auth_repository.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _nameCtrl.text = state.user.employee?.fullName ?? state.user.name;
      _emailCtrl.text = state.user.email;
      _phoneCtrl.text = state.user.employee?.phone ?? '';
      _addressCtrl.text = state.user.employee?.address ?? '';
    }
  }

  Future<void> _save() async {
    if (_saving || _nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthRepository>().updateProfile({
        'full_name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthCheckSession());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!')));
      context.pop();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil gagal diperbarui. Periksa data dan koneksi.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          child: _saving ? const CircularProgressIndicator() : Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp)))),
      ]))),
    );
  }

  Widget _label(String t) => Text(t, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surfaceContainerLow,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryContainer)));
}

