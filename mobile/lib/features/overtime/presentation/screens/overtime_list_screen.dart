import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class OvertimeListScreen extends StatelessWidget {
  const OvertimeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Riwayat Lembur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/overtime/new'),
        backgroundColor: AppColors.primaryContainer,
        icon: const Icon(Icons.add, color: AppColors.onPrimaryContainer),
        label: Text(
          'Ajukan Lembur',
          style: TextStyle(
            color: AppColors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 3,
        itemBuilder: (context, index) {
          final statuses = ['Disetujui', 'Menunggu', 'Ditolak'];
          final colors = [AppColors.successEmerald, AppColors.warningAmber, AppColors.errorCrimson];
          
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () => context.push('/app/overtime/detail'),
              borderRadius: BorderRadius.circular(16.r),
              child: InfoCard(
                borderLeftColor: colors[index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lembur Proyek ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '12 Okt 2026 • 18:00 - 21:00',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        statuses[index],
                        style: TextStyle(
                          color: colors[index],
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
