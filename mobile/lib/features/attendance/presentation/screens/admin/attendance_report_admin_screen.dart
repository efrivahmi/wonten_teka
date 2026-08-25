import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class AttendanceReportAdminScreen extends StatelessWidget {
  const AttendanceReportAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text('Laporan Kehadiran',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('Juli 2025',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Icon(Icons.date_range),
                ])),
            SizedBox(height: 16.h),
            Text('Ringkasan',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(children: [
              Expanded(
                  child: InfoCard(
                      child: Column(children: [
                Text('95%',
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successEmerald)),
                Text('Kehadiran',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.onSurfaceVariant))
              ]))),
              SizedBox(width: 8.w),
              Expanded(
                  child: InfoCard(
                      child: Column(children: [
                Text('3%',
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningAmber)),
                Text('Terlambat',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.onSurfaceVariant))
              ]))),
              SizedBox(width: 8.w),
              Expanded(
                  child: InfoCard(
                      child: Column(children: [
                Text('2%',
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorCrimson)),
                Text('Absen',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.onSurfaceVariant))
              ]))),
            ]),
            SizedBox(height: 24.h),
            Text('Detail Karyawan',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Hadir')),
                    DataColumn(label: Text('Terlambat')),
                    DataColumn(label: Text('Cuti'))
                  ],
                  rows: List.generate(
                      10,
                      (i) => DataRow(cells: [
                            DataCell(Text('Karyawan ${i + 1}')),
                            const DataCell(Text('20')),
                            DataCell(Text('${i % 3}')),
                            DataCell(Text('${i % 2}')),
                          ])),
                )),
          ])),
    );
  }
}

