import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/info_card.dart';

class ExportCenterScreen extends StatefulWidget {
  const ExportCenterScreen({super.key});
  @override
  State<ExportCenterScreen> createState() => _ExportCenterScreenState();
}

class _ExportCenterScreenState extends State<ExportCenterScreen> {
  late final ApiClient _api;
  String? _busy;
  @override
  void initState() {
    super.initState();
    _api = ApiClient();
  }

  Future<void> _export(String title, String endpoint, List<String> columns,
      List<String> Function(Map<String, dynamic>) row) async {
    setState(() => _busy = title);
    try {
      final response =
          await _api.get(endpoint, queryParameters: {'per_page': 500});
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final raw = body['data'];
      final rows = raw is Map
          ? (raw['data'] as List? ?? const [])
          : (raw as List? ?? const []);
      final lines = <String>[columns.map(_csv).join(',')];
      for (final value in rows) {
        lines.add(
            row(Map<String, dynamic>.from(value as Map)).map(_csv).join(','));
      }
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/${title.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString('${lines.join('\n')}\n');
      await Share.shareXFiles([XFile(file.path)], text: title);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export gagal: $e')));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';
  Widget _item(
          String title,
          IconData icon,
          Color color,
          String endpoint,
          List<String> columns,
          List<String> Function(Map<String, dynamic>) row) =>
      Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: InfoCard(
            child: ListTile(
                leading: Icon(icon, color: color),
                title: Text(title),
                subtitle: const Text('Data diambil langsung dari API'),
                trailing: _busy == title
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator())
                    : const Icon(Icons.download),
                onTap: _busy == null
                    ? () => _export(title, endpoint, columns, row)
                    : null)),
      );

  @override
  Widget build(BuildContext context) => BrandPageBackground(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const AppBrandTitle(section: 'Export Center'),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.onSurface)),
        body: ListView(padding: EdgeInsets.all(16.w), children: [
          _item(
              'Laporan Kehadiran',
              Icons.calendar_month,
              AppColors.primaryContainer,
              '/admin/attendance',
              ['employee', 'date', 'status', 'check_in', 'check_out'],
              (r) => [
                    '${r['employee']?['name'] ?? r['employee_name'] ?? ''}',
                    '${r['date'] ?? ''}',
                    '${r['status'] ?? ''}',
                    '${r['check_in'] ?? ''}',
                    '${r['check_out'] ?? ''}'
                  ]),
          _item(
              'Laporan Payroll',
              Icons.payments,
              AppColors.successEmerald,
              '/admin/payroll/runs',
              ['period', 'status', 'total'],
              (r) => [
                    '${r['period_month'] ?? ''}/${r['period_year'] ?? ''}',
                    '${r['status'] ?? ''}',
                    '${r['total_amount'] ?? r['total'] ?? ''}'
                  ]),
          _item(
              'Laporan Cuti & Klaim',
              Icons.assignment,
              AppColors.warningAmber,
              '/approvals/pending',
              ['type', 'requester', 'status', 'created_at'],
              (r) => [
                    '${r['request_type'] ?? r['requestType'] ?? ''}',
                    '${r['requester']?['name'] ?? r['employee']?['name'] ?? ''}',
                    '${r['status'] ?? ''}',
                    '${r['created_at'] ?? ''}'
                  ]),
          _item(
              'Data Master Karyawan',
              Icons.people,
              AppColors.infoCerulean,
              '/admin/employees',
              ['name', 'email', 'department', 'status'],
              (r) => [
                    '${r['name'] ?? ''}',
                    '${r['email'] ?? ''}',
                    '${r['department']?['name'] ?? r['department_name'] ?? ''}',
                    '${r['status'] ?? ''}'
                  ]),
        ]),
      ));
}
