import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Pengaturan Sistem', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Section(title: 'Integrasi', children: [
          _SettingItem(title: 'Mesin Absensi Fisik (SDK)', trailing: const Icon(Icons.chevron_right)),
          _SettingItem(title: 'API Pihak Ketiga', trailing: const Icon(Icons.chevron_right)),
        ]),
        SizedBox(height: 16.h),
        _Section(title: 'Keamanan', children: [
          _SettingItem(title: 'Kebijakan Password', trailing: const Icon(Icons.chevron_right)),
          _SettingItem(title: '2FA Wajib untuk Admin', trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primaryContainer)),
          _SettingItem(title: 'Batas Toleransi Lokasi (Radius)', subtitle: '100 meter', trailing: const Icon(Icons.edit)),
        ]),
        SizedBox(height: 16.h),
        _Section(title: 'Lainnya', children: [
          _SettingItem(title: 'Backup Database Otomatis', trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primaryContainer)),
          _SettingItem(title: 'Zona Waktu Default', subtitle: 'WIB (Asia/Jakarta)', trailing: const Icon(Icons.chevron_right)),
        ]),
      ])),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)), SizedBox(height: 8.h),
    InfoCard(child: Column(children: children.expand((c) => [c, if (c != children.last) Divider(height: 1, color: AppColors.outlineVariant.withOpacity(0.3))]).toList())),
  ]);
}

class _SettingItem extends StatelessWidget {
  final String title; final String? subtitle; final Widget trailing;
  const _SettingItem({required this.title, this.subtitle, required this.trailing});
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.symmetric(vertical: 12.h), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
      if (subtitle != null) Text(subtitle!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
    ])),
    trailing,
  ]));
}
