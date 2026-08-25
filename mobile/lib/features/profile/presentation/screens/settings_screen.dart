import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Pengaturan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(children: [
        _Section(title: 'Akun', items: [
          _SettingItem(icon: Icons.lock, title: 'Ubah Password', onTap: () {}),
          _SettingItem(icon: Icons.fingerprint, title: 'Biometrik Login', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: AppColors.primaryContainer)),
          const _SettingItem(icon: Icons.language, title: 'Bahasa', subtitle: 'Indonesia'),
        ]),
        SizedBox(height: 16.h),
        _Section(title: 'Notifikasi', items: [
          _SettingItem(icon: Icons.notifications, title: 'Push Notification', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: AppColors.primaryContainer)),
          _SettingItem(icon: Icons.alarm, title: 'Pengingat Check-in', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: AppColors.primaryContainer)),
          _SettingItem(icon: Icons.campaign, title: 'Pengumuman', trailing: Switch(value: true, onChanged: (_) {}, activeThumbColor: AppColors.primaryContainer)),
        ]),
        SizedBox(height: 16.h),
        _Section(title: 'Tentang', items: [
          const _SettingItem(icon: Icons.info, title: 'Versi Aplikasi', subtitle: '1.0.0'),
          _SettingItem(icon: Icons.description, title: 'Kebijakan Privasi', onTap: () {}),
          _SettingItem(icon: Icons.gavel, title: 'Syarat & Ketentuan', onTap: () {}),
        ]),
      ])),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> items;
  const _Section({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.only(left: 4.w, bottom: 8.h), child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
    InfoCard(child: Column(children: items.expand((w) => [w, if (w != items.last) Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3))]).toList())),
  ]);
}

class _SettingItem extends StatelessWidget {
  final IconData icon; final String title; final String? subtitle; final Widget? trailing; final VoidCallback? onTap;
  const _SettingItem({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(padding: EdgeInsets.symmetric(vertical: 12.h), child: Row(children: [
    Icon(icon, color: AppColors.onSurfaceVariant, size: 20.w), SizedBox(width: 16.w),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
      if (subtitle != null) Text(subtitle!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
    ])),
    trailing ?? Icon(Icons.chevron_right, color: AppColors.outline, size: 20.w),
  ])));
}
