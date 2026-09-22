import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_exceptions.dart';
import '../../../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await context.read<ApiClient>().get('/notifications');
      final data = response.data as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => notifications =
          List<Map<String, dynamic>>.from(data['data'] as List? ?? const []));
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _readAll() async {
    await context.read<ApiClient>().post('/notifications/read-all');
    if (!mounted) return;
    setState(() {
      notifications = notifications
          .map((item) => {...item, 'read_at': DateTime.now().toIso8601String()})
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Notifikasi'),
          actions: [
            TextButton(
                onPressed: notifications.any((n) => n['read_at'] == null)
                    ? _readAll
                    : null,
                child: const Text('Baca semua'))
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? ListView(children: [
                      SizedBox(height: 220.h),
                      Center(child: Text(error!))
                    ])
                  : notifications.isEmpty
                      ? ListView(children: [
                          SizedBox(height: 220.h),
                          const Center(child: Text('Belum ada notifikasi.'))
                        ])
                      : ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (_, index) {
                            final item = notifications[index];
                            final unread = item['read_at'] == null;
                            return ListTile(
                              tileColor: unread
                                  ? AppColors.primary.withValues(alpha: .06)
                                  : AppColors.surface,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              leading: const Icon(Icons.notifications_none,
                                  color: AppColors.primary),
                              title: Text(
                                  item['title']?.toString() ?? 'Notifikasi',
                                  style: TextStyle(
                                      fontWeight: unread
                                          ? FontWeight.w800
                                          : FontWeight.w500)),
                              subtitle: Text(item['body']?.toString() ?? ''),
                            );
                          },
                        ),
        ),
      );
}
