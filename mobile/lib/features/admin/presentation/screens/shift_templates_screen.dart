import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ShiftTemplatesScreen extends StatelessWidget {
  const ShiftTemplatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Template Shift', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, backgroundColor: AppColors.primaryContainer, icon: const Icon(Icons.add, color: AppColors.onPrimary), label: Text('Template Baru', style: TextStyle(color: AppColors.onPrimary))),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        _TemplateCard(title: 'Shift Pagi', time: '08:00 - 17:00', color: AppColors.successEmerald), SizedBox(height: 12.h),
        _TemplateCard(title: 'Shift Siang', time: '13:00 - 22:00', color: AppColors.warningAmber), SizedBox(height: 12.h),
        _TemplateCard(title: 'Shift Malam', time: '22:00 - 06:00', color: AppColors.infoCerulean),
      ]),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title, time; final Color color;
  const _TemplateCard({required this.title, required this.time, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border(left: BorderSide(color: color, width: 6.w))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16.sp)), SizedBox(height: 4.h),
        Text(time, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
      ]),
      IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
    ]),
  );
}
