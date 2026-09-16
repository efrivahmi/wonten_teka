import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/models/company_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../company/bloc/company_cubit.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final AnnouncementModel announcement;
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pengumuman')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(announcement.priority.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 12.h),
                  Text(announcement.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(
                      announcement.createdAt == null
                          ? '-'
                          : DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                              .format(announcement.createdAt!.toLocal()),
                      style:
                          const TextStyle(color: AppColors.onSurfaceVariant)),
                ])),
            SizedBox(height: 16.h),
            InfoCard(
                child: Text(announcement.body,
                    style: TextStyle(fontSize: 14.sp, height: 1.6))),
            if (announcement.attachmentUrl != null && announcement.attachmentUrl!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(announcement.attachmentUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal membuka tautan lampiran')));
                        }
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Buka Lampiran'),
                  )),
            ],
            if (!announcement.isAcknowledged) ...[
              SizedBox(height: 24.h),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await context
                          .read<CompanyCubit>()
                          .acknowledgeAnnouncement(announcement.id);
                      if (context.mounted) context.pop();
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tandai Sudah Dibaca'),
                  )),
            ],
          ]),
        ),
      );
}
