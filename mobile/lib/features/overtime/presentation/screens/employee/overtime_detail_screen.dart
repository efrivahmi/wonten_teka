import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import '../../../../../core/theme/app_colors.dart';

class OvertimeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> overtime;
  const OvertimeDetailScreen({super.key, required this.overtime});
  @override Widget build(BuildContext context) => BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
    appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Detail lembur'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text((overtime['status'] ?? 'pending').toString().toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        _row('Tanggal', overtime['date']?.toString().split('T').first ?? '-'),
        _row('Waktu', "${overtime['start_time'] ?? '-'} – ${overtime['end_time'] ?? '-'}"),
        _row('Jenis', overtime['overtime_type']?.toString() ?? '-'),
        _row('Pekerjaan', overtime['reason']?.toString() ?? '-'),
      ]))),
    ]),
  ));
  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]));
}
