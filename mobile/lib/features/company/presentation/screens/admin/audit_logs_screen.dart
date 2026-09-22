import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/widgets/admin_pagination_bar.dart';

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
  int _currentPage = 1, _lastPage = 1, _totalLogs = 0;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadLogs();
  }

  Future<void> _loadLogs({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.get('/admin/audit-logs',
          queryParameters: {'page': page, 'per_page': 25});
      final pageData = Map<String, dynamic>.from(
          response.data['data'] is Map ? response.data['data'] : response.data);
      final data = pageData['data'] as List? ?? const [];
      setState(() {
        _logs = data;
        _currentPage = pageData['current_page'] as int? ?? page;
        _lastPage = pageData['last_page'] as int? ?? 1;
        _totalLogs = pageData['total'] as int? ?? data.length;
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
    return BrandPageBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const AppBrandTitle(section: 'Audit Logs'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
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
                      itemCount: _logs.length + 1,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        if (i == 0)
                          return AdminPaginationBar(
                              currentPage: _currentPage,
                              lastPage: _lastPage,
                              total: _totalLogs,
                              onPageChanged: (page) => _loadLogs(page: page));
                        final log = _logs[i - 1];
                        final actorName = log['actor'] != null
                            ? log['actor']['name']
                            : 'System';
                        final action = log['action'] ?? 'Unknown Action';
                        final createdAt = DateTime.parse(log['created_at']);
                        return InfoCard(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      color: AppColors.onSurface,
                                      fontSize: 14.sp)),
                            ]));
                      }),
    ));
  }
}
