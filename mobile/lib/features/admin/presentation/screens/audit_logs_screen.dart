import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Audit Logs', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: ListView.separated(padding: EdgeInsets.all(16.w), itemCount: 10, separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, i) => InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Admin - ${i % 2 == 0 ? "Budi" : "Sari"}', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12.sp)),
            Text('${i + 1} jam lalu', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10.sp)),
          ]),
          SizedBox(height: 8.h),
          Text(i % 2 == 0 ? 'Menambahkan template shift baru "Shift Malam"' : 'Mengubah status cuti Karyawan 3 menjadi Disetujui', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
        ]))),
    );
  }
}
