import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/models/attendance_log_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/error_state_widget.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../company/bloc/company_cubit.dart';
import '../../../bloc/attendance_history_cubit.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    await Future.wait([
      context
          .read<AttendanceHistoryCubit>()
          .loadHistory(isRefresh: true, month: month.month, year: month.year),
      context
          .read<CompanyCubit>()
          .loadAll(month: month.month, year: month.year),
    ]);
  }

  void move(int value) {
    setState(() {
      month = DateTime(month.year, month.month + value);
      selected = DateTime(month.year, month.month, 1);
    });
    load();
  }

  bool same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  List<AttendanceLogModel> onDay(
          List<AttendanceLogModel> logs, DateTime date) =>
      logs.where((e) => same(e.checkInAt, date)).toList();
  Color dayColor(
      List<AttendanceLogModel> logs, DateTime date, List<int> workDays) {
    if (logs.isNotEmpty) {
      if (logs.every((e) => e.status == 'absent')) {
        return AppColors.errorCrimson;
      }
      if (logs.any((e) => e.status == 'late' || e.status == 'absent')) {
        return AppColors.warningAmber;
      }
      return AppColors.successEmerald;
    }
    if (DateUtils.dateOnly(date).isBefore(DateUtils.dateOnly(DateTime.now())) &&
        workDays.contains(date.weekday)) {
      return AppColors.errorCrimson;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: const AppBrandTitle(section: 'Riwayat absensi'),
            scrolledUnderElevation: 0),
        body: BrandPageBackground(child:
            BlocBuilder<AttendanceHistoryCubit, AttendanceHistoryState>(
                builder: (_, state) {
          if (state is AttendanceHistoryError) {
            return ErrorStateWidget(message: state.message, onRetry: load);
          }
          final loading = state is AttendanceHistoryInitial ||
              state is AttendanceHistoryLoading;
          final logs = state is AttendanceHistoryLoaded
              ? state.logs
              : <AttendanceLogModel>[];
          final company = context.watch<CompanyCubit>().state;
          final workDays = company is CompanyLoaded
              ? company.workingDays
              : <int>[1, 2, 3, 4, 5, 6];
          return RefreshIndicator(
              onRefresh: load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 36.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      SizedBox(height: 14.h),
                      if (loading)
                        const Padding(
                            padding: EdgeInsets.all(64),
                            child: Center(child: CircularProgressIndicator()))
                      else ...[
                        _calendar(logs, workDays),
                        SizedBox(height: 14.h),
                        const _LegendRow(),
                        SizedBox(height: 24.h),
                        _details(logs, workDays),
                      ],
                    ]),
              ));
        })),
      );

  Widget _header() => BrandPanel(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(children: [
        IconButton(
            onPressed: () => move(-1),
            color: Colors.white,
            icon: const Icon(Icons.chevron_left_rounded)),
        Expanded(
            child: Column(children: [
          const Text('REKAP BULANAN',
              style: TextStyle(
                  color: Color(0xFFB7F56A),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4)),
          Text(DateFormat('MMMM yyyy', 'id_ID').format(month),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800))
        ])),
        IconButton(
            onPressed: () => move(1),
            color: Colors.white,
            icon: const Icon(Icons.chevron_right_rounded)),
      ]));

  Widget _calendar(List<AttendanceLogModel> logs, List<int> workDays) {
    final first = DateTime(month.year, month.month, 1),
        days = DateTime(month.year, month.month + 1, 0).day;
    final count = (((first.weekday - 1 + days) / 7).ceil() * 7);
    return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: .05),
                  blurRadius: 24,
                  offset: const Offset(0, 10))
            ]),
        child: Column(children: [
          Row(
              children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                  .map((e) => Expanded(
                      child: Center(
                          child: Text(e,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurfaceVariant)))))
                  .toList()),
          SizedBox(height: 10.h),
          GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, childAspectRatio: .88),
              itemBuilder: (_, i) {
                final day = i - (first.weekday - 2);
                if (day < 1 || day > days) return const SizedBox.shrink();
                final date = DateTime(month.year, month.month, day),
                    items = onDay(logs, date),
                    color = dayColor(items, date, workDays),
                    active = same(date, selected),
                    today = same(date, DateTime.now());
                final doubleShift = items.any((e) => e.hasDoubleShift),
                    overtime = items.any((e) => e.overtime.isNotEmpty);
                return InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => setState(() => selected = date),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : color == Colors.transparent
                                    ? (today
                                        ? AppColors.secondaryContainer
                                        : Colors.transparent)
                                    : color.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : color.withValues(alpha: .35))),
                        child: Stack(children: [
                          Center(
                              child: Text('$day',
                                  style: TextStyle(
                                      fontWeight: active || today
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: active
                                          ? Colors.white
                                          : color == Colors.transparent
                                              ? AppColors.onSurface
                                              : color))),
                          if (doubleShift || overtime)
                            Positioned(
                                bottom: 5,
                                left: 0,
                                right: 0,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (doubleShift)
                                        _dot(Colors.deepPurple, active),
                                      if (overtime)
                                        _dot(Colors.deepOrange, active)
                                    ]))
                        ])));
              }),
        ]));
  }

  Widget _dot(Color color, bool active) => Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
          color: active ? Colors.white : color, shape: BoxShape.circle));

  Widget _details(List<AttendanceLogModel> logs, List<int> workDays) {
    final items = onDay(logs, selected),
        missed = DateUtils.dateOnly(selected)
                .isBefore(DateUtils.dateOnly(DateTime.now())) &&
            workDays.contains(selected.weekday);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Detail ${DateFormat('EEEE, d MMMM', 'id_ID').format(selected)}',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
      SizedBox(height: 12.h),
      if (items.isEmpty)
        InfoCard(
            child: Row(children: [
          Icon(missed ? Icons.cancel_rounded : Icons.event_available_rounded,
              color:
                  missed ? AppColors.errorCrimson : AppColors.onSurfaceVariant),
          SizedBox(width: 12.w),
          Expanded(
              child: Text(
                  missed
                      ? 'Tidak hadir / Alpha'
                      : 'Belum ada catatan absensi pada tanggal ini.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: missed
                          ? AppColors.errorCrimson
                          : AppColors.onSurfaceVariant)))
        ]))
      else
        ...items.map((log) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: InkWell(
                onTap: () => context.push('/app/attendance/detail', extra: log),
                borderRadius: BorderRadius.circular(20.r),
                child: InfoCard(
                    child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(log.flags?['shift_name']?.toString() ?? 'Absensi',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 6.h),
                        Text(
                            log.status == 'absent'
                                ? 'Tidak ada check-in'
                                : '${DateFormat('HH:mm').format(log.checkInAt)} – ${log.checkOutAt == null ? '--:--' : DateFormat('HH:mm').format(log.checkOutAt!)}',
                            style: const TextStyle(
                                color: AppColors.onSurfaceVariant))
                      ])),
                  log.status == 'absent'
                      ? StatusBadge.absent()
                      : log.status == 'late'
                          ? StatusBadge.late()
                          : StatusBadge.onTime()
                ]))))),
    ]);
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();
  @override
  Widget build(BuildContext context) =>
      const Wrap(spacing: 8, runSpacing: 8, children: [
        _Tag('Hadir', AppColors.successEmerald),
        _Tag('Terlambat', AppColors.warningAmber),
        _Tag('Tidak hadir', AppColors.errorCrimson),
        _Tag('Shift ganda', Colors.deepPurple),
        _Tag('Lembur', Colors.deepOrange)
      ]);
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700))
      ]));
}
