import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'Bagaimana cara melakukan check-in?', 'a': 'Buka aplikasi, tekan tombol "Absensi Sekarang" di dashboard, arahkan kamera ke wajah Anda.'},
      {'q': 'Apa yang harus dilakukan jika GPS tidak terdeteksi?', 'a': 'Pastikan GPS aktif dan izin lokasi sudah diberikan. Coba di area terbuka.'},
      {'q': 'Bagaimana cara mengajukan cuti?', 'a': 'Buka tab Approval > tekan "Ajukan Cuti" > isi formulir > kirim.'},
      {'q': 'Kapan slip gaji tersedia?', 'a': 'Slip gaji tersedia setiap tanggal 25 setiap bulan.'},
    ];
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Bantuan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Contact Card
        InfoCard(child: Row(children: [
          Container(width: 48.w, height: 48.w, decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.headset_mic, color: AppColors.primary, size: 24.w)),
          SizedBox(width: 16.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hubungi HRD', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
            Text('hr@wontenteka.com', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
          ])),
          Icon(Icons.chevron_right, color: AppColors.outline, size: 20.w),
        ])),
        SizedBox(height: 24.h),

        Text('FAQ', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        ...faqs.map((f) => Padding(padding: EdgeInsets.only(bottom: 12.h), child: InfoCard(child: ExpansionTile(
          tilePadding: EdgeInsets.zero, childrenPadding: EdgeInsets.only(top: 8.h),
          title: Text(f['q']!, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
          iconColor: AppColors.primary, collapsedIconColor: AppColors.onSurfaceVariant,
          children: [Text(f['a']!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp, height: 1.5))],
        )))),
      ])),
    );
  }
}
