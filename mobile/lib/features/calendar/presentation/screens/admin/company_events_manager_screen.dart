import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/models/company_models.dart'; // To access service locator for ApiClient

class CompanyEventsManagerScreen extends StatefulWidget {
  const CompanyEventsManagerScreen({super.key});

  @override
  State<CompanyEventsManagerScreen> createState() =>
      _CompanyEventsManagerScreenState();
}

class _CompanyEventsManagerScreenState
    extends State<CompanyEventsManagerScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<CalendarEventModel> _events = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.get('/admin/events');
      final data = response.data['data'] as List;
      setState(() {
        _events = data.map((e) => CalendarEventModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat event: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEvent(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Event?'),
        content:
            const Text('Event ini akan dihapus dari kalender semua karyawan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.errorCrimson)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.delete('/admin/events/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Event berhasil dihapus'),
            backgroundColor: AppColors.successEmerald));
        _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal menghapus event'),
            backgroundColor: AppColors.errorCrimson));
      }
    }
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
          title: Text('Kelola Event Perusahaan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/admin/events/edit');
            if (result == true) {
              _loadEvents();
            }
          },
          backgroundColor: AppColors.primaryContainer,
          icon: const Icon(Icons.add, color: AppColors.onPrimary),
          label: const Text('Buat Event',
              style: TextStyle(color: AppColors.onPrimary))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.errorCrimson)))
              : _events.isEmpty
                  ? const Center(child: Text('Belum ada event'))
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final event = _events[i];
                        final isHoliday = event.type == 'holiday';
                        return InfoCard(
                            borderLeftColor: isHoliday
                                ? AppColors.successEmerald
                                : AppColors.primary,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(event.title,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.sp))),
                                        Row(children: [
                                          IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 20),
                                              onPressed: () async {
                                                final result = await context
                                                    .push('/admin/events/edit',
                                                        extra: event);
                                                if (result == true) {
                                                  _loadEvents();
                                                }
                                              }),
                                          IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 20,
                                                  color:
                                                      AppColors.errorCrimson),
                                              onPressed: () =>
                                                  _deleteEvent(event.id)),
                                        ]),
                                      ]),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                        color: isHoliday
                                            ? AppColors.successEmerald
                                                .withValues(alpha: 0.1)
                                            : AppColors.primaryContainer
                                                .withValues(alpha: 0.3),
                                        borderRadius:
                                            BorderRadius.circular(4.r)),
                                    child: Text(
                                        isHoliday
                                            ? 'Libur Nasional'
                                            : 'Event / Agenda',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: isHoliday
                                                ? AppColors.successEmerald
                                                : AppColors.primary)),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(children: [
                                    Icon(Icons.calendar_today,
                                        size: 14.w,
                                        color: AppColors.onSurfaceVariant),
                                    SizedBox(width: 8.w),
                                    Text(
                                        DateFormat('dd MMM yyyy')
                                                .format(event.startDate) +
                                            (event.endDate != null &&
                                                    event.endDate !=
                                                        event.startDate
                                                ? ' - ${DateFormat('dd MMM yyyy').format(event.endDate!)}'
                                                : ''),
                                        style: TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 12.sp))
                                  ]),
                                  if (event.description != null &&
                                      event.description!.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.notes,
                                              size: 14.w,
                                              color:
                                                  AppColors.onSurfaceVariant),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                              child: Text(event.description!,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .onSurfaceVariant,
                                                      fontSize: 12.sp))),
                                        ]),
                                  ],
                                ]));
                      }),
    );
  }
}

