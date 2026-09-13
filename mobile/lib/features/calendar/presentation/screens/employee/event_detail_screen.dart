import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/company_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../tasks/notification_service.dart';

class EventDetailScreen extends StatelessWidget {
  final CalendarEventModel event;
  const EventDetailScreen({super.key, required this.event});

  DateTime? get eventDateTime {
    if (event.startTime == null) return null;
    final time = event.startTime!.split(':');
    return DateTime(event.startDate.year, event.startDate.month, event.startDate.day, int.parse(time[0]), int.parse(time[1]));
  }

  Future<void> enableReminder(BuildContext context) async {
    final startsAt = eventDateTime;
    if (startsAt == null) return;
    await NotificationService().scheduleAlarm(id: 900000 + event.id, title: 'Acara dimulai 30 menit lagi', body: event.title, scheduledDate: startsAt.subtract(const Duration(minutes: 30)));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengingat 30 menit sebelum acara telah diaktifkan.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surfaceContainerLow,
    appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: context.pop), title: const Text('Detail Acara')),
    body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text((event.type ?? 'event').toUpperCase(), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11.sp)),
        SizedBox(height: 10.h), Text(event.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), SizedBox(height: 16.h),
        row(Icons.calendar_today, DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(event.startDate)),
        if (event.startTime != null) row(Icons.schedule, '${event.startTime!.substring(0, 5)}${event.endTime != null ? ' - ${event.endTime!.substring(0, 5)}' : ''} WIB'),
      ])), SizedBox(height: 16.h),
      InfoCard(child: Text(event.description?.trim().isNotEmpty == true ? event.description! : 'Tidak ada detail tambahan.', style: TextStyle(fontSize: 14.sp, height: 1.5))),
      if (eventDateTime != null) Padding(padding: EdgeInsets.only(top: 18.h), child: ElevatedButton.icon(onPressed: () => enableReminder(context), icon: const Icon(Icons.alarm_add), label: const Text('Aktifkan pengingat 30 menit sebelumnya'))),
    ])),
  );

  Widget row(IconData icon, String text) => Padding(padding: EdgeInsets.only(bottom: 9.h), child: Row(children: [Icon(icon, size: 17.w, color: AppColors.onSurfaceVariant), SizedBox(width: 9.w), Expanded(child: Text(text))]));
}
