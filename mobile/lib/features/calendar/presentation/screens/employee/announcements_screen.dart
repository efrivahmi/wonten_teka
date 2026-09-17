import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../company/bloc/company_cubit.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) => BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Pengumuman'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
        body:
            BlocBuilder<CompanyCubit, CompanyState>(builder: (context, state) {
          if (state is CompanyLoading || state is CompanyInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CompanyError) {
            return Center(child: Text(state.message));
          }
          final items = (state as CompanyLoaded).announcements;
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada pengumuman.'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<CompanyCubit>().loadAll(),
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = items[index];
                final color = item.isUrgent
                    ? AppColors.errorCrimson
                    : AppColors.infoCerulean;
                return InfoCard(
                  borderLeftColor: color,
                  onTap: () =>
                      context.push('/app/announcements/detail', extra: item),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.campaign, color: color),
                        SizedBox(width: 12.w),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(item.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 5.h),
                              Text(item.body,
                                  maxLines: 3, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Text(
                                      item.createdAt == null
                                          ? '-'
                                          : DateFormat('dd MMM yyyy', 'id_ID')
                                              .format(item.createdAt!),
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: AppColors.onSurfaceVariant)),
                                  if (item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty) ...[
                                    SizedBox(width: 8.w),
                                    Icon(Icons.attach_file, size: 14.sp, color: AppColors.onSurfaceVariant),
                                  ],
                                ],
                              ),
                            ])),
                        if (!item.isAcknowledged)
                          const Icon(Icons.circle,
                              size: 9, color: AppColors.primary),
                      ]),
                );
              },
            ),
          );
        }),
      ));
}
