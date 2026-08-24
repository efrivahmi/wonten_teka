import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class OrganizationSettingsScreen extends StatelessWidget {
  const OrganizationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Struktur Organisasi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: AppColors.primaryContainer, child: const Icon(Icons.add, color: AppColors.onPrimary)),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        _OrgItem(title: 'Direksi', subtitle: '3 Karyawan'),
        Padding(padding: EdgeInsets.only(left: 24.w), child: _OrgItem(title: 'IT Department', subtitle: '15 Karyawan')),
        Padding(padding: EdgeInsets.only(left: 48.w), child: _OrgItem(title: 'Software Engineering', subtitle: '10 Karyawan')),
        Padding(padding: EdgeInsets.only(left: 48.w), child: _OrgItem(title: 'Infrastructure', subtitle: '5 Karyawan')),
        Padding(padding: EdgeInsets.only(left: 24.w), child: _OrgItem(title: 'HR Department', subtitle: '8 Karyawan')),
        Padding(padding: EdgeInsets.only(left: 24.w), child: _OrgItem(title: 'Finance Department', subtitle: '6 Karyawan')),
      ]),
    );
  }
}

class _OrgItem extends StatelessWidget {
  final String title, subtitle;
  const _OrgItem({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.only(bottom: 8.h), child: InfoCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
      Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
    ]),
    Row(children: [
      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}),
      IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.errorCrimson), onPressed: () {}),
    ]),
  ])));
}
