import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/models/company_models.dart';
import '../../../../core/theme/app_colors.dart';
class CompanyEventDetailScreen extends StatelessWidget {
  final CalendarEventModel event;

  const CompanyEventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    
    // Determine event color based on type
    Color typeColor = AppColors.primary;
    if (event.type == 'holiday') {
      typeColor = AppColors.errorCrimson;
    } else if (event.type == 'meeting') {
      typeColor = AppColors.warningAmber;
    }

    // Combine date string
    String dateRange = dateFormat.format(event.startDate);
    if (event.endDate != null && event.endDate!.difference(event.startDate).inDays > 0) {
      dateRange += ' - ${dateFormat.format(event.endDate!)}';
    }

    // Combine time string
    String timeRange = 'Sepanjang Hari';
    if (event.startTime != null) {
      timeRange = event.startTime!.substring(0, 5);
      if (event.endTime != null) {
        timeRange += ' - ${event.endTime!.substring(0, 5)}';
      }
    }

    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Detail Event'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: typeColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                (event.type ?? 'Event').toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Title
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.onSurface, fontSize: 28),
            ),
            const SizedBox(height: 32),
            
            // Date & Time Info Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, Icons.calendar_today_rounded, 'Tanggal', dateRange),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.outlineVariant),
                  ),
                  _buildInfoRow(context, Icons.access_time_rounded, 'Waktu', timeRange),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            if (event.description != null && event.description!.isNotEmpty) ...[
              Text(
                'Deskripsi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                event.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () => _exportToCalendar(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.edit_calendar_rounded),
              label: const Text(
                'Ekspor ke Kalender (Alarm)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportToCalendar(BuildContext context) async {
    try {
      final startDate = DateFormat('yyyyMMdd').format(event.startDate);
      final endDate = event.endDate != null ? DateFormat('yyyyMMdd').format(event.endDate!.add(const Duration(days: 1))) : DateFormat('yyyyMMdd').format(event.startDate.add(const Duration(days: 1)));
      
      final icsContent = '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Wonten Teka//ID
BEGIN:VEVENT
UID:${DateTime.now().millisecondsSinceEpoch}@wontenteka.com
DTSTAMP:${DateFormat("yyyyMMdd'T'HHmmss'Z'").format(DateTime.now().toUtc())}
DTSTART;VALUE=DATE:$startDate
DTEND;VALUE=DATE:$endDate
SUMMARY:${event.title}
DESCRIPTION:${event.description ?? ''}
END:VEVENT
END:VCALENDAR''';

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/event.ics');
      await file.writeAsString(icsContent);

      final xFile = XFile(file.path, mimeType: 'text/calendar');
      await Share.shareXFiles([xFile], subject: 'Simpan ke Kalender: ${event.title}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengekspor kalender.')),
        );
      }
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
