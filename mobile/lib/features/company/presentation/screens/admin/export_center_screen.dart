import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class ExportCenterScreen extends StatelessWidget {
  const ExportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Export Center'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ExportItem(
                    title: 'Laporan Kehadiran',
                    icon: Icons.calendar_month,
                    color: AppColors.primaryContainer),
                _ExportItem(
                    title: 'Laporan Payroll',
                    icon: Icons.payments,
                    color: AppColors.successEmerald),
                _ExportItem(
                    title: 'Laporan Cuti & Klaim',
                    icon: Icons.assignment,
                    color: AppColors.warningAmber),
                _ExportItem(
                    title: 'Data Master Karyawan',
                    icon: Icons.people,
                    color: AppColors.infoCerulean),
              ])),
    ));
  }
}

class _ExportItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _ExportItem(
      {required this.title, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InfoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(width: 12.w),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        ]),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(
              child: DropdownButtonFormField<String>(
                  initialValue: 'Bulan Ini',
                  items: ['Bulan Ini', 'Bulan Lalu', 'Tahun Ini']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (_) {},
                  decoration: const InputDecoration(
                      isDense: true, border: OutlineInputBorder()))),
          SizedBox(width: 12.w),
          Expanded(
              child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('File sedang diunduh...')));
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary))),
        ]),
      ])));
}

