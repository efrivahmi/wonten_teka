import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/api/api_client.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<dynamic> _logs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.get('/admin/audit-logs');
      final data = response.data['data'] as List;
      setState(() {
        _logs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat log audit: $e';
        _isLoading = false;
      });
    }
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mnt lalu';
    return 'Baru saja';
  }

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
          title: Text('Audit Logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.errorCrimson)))
              : _logs.isEmpty
                  ? const Center(child: Text('Belum ada log audit.'))
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final log = _logs[i];
                        final actorName = log['actor'] != null ? log['actor']['name'] : 'System';
                        final action = log['action'] ?? 'Unknown Action';
                        final createdAt = DateTime.parse(log['created_at']);
                        return InfoCard(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Admin - $actorName',
                                        style: TextStyle(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp)),
                                    Text(_timeAgo(createdAt),
                                        style: TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 10.sp)),
                                  ]),
                              SizedBox(height: 8.h),
                              Text(action,
                                  style: TextStyle(
                                      color: AppColors.onSurface, fontSize: 14.sp)),
                            ]));
                      }),
    );
  }
}

