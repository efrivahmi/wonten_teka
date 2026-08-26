import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../company/bloc/company_cubit.dart';

class CompanyCalendarScreen extends StatefulWidget {
  const CompanyCalendarScreen({super.key});

  @override
  State<CompanyCalendarScreen> createState() => _CompanyCalendarScreenState();
}

class _CompanyCalendarScreenState extends State<CompanyCalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CompanyCubit>()
          .loadAll(month: _currentMonth.month, year: _currentMonth.year);
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
    _loadData();
  }

  Color _getEventColor(String type) {
    final lower = type.toLowerCase();
    if (lower == 'holiday') return AppColors.successEmerald;
    if (lower == 'meeting') return AppColors.infoCerulean;
    if (lower == 'deadline') return AppColors.errorCrimson;
    return AppColors.warningAmber;
  }

  int _daysInMonth(int month, int year) {
    if (month == 12) return DateTime(year + 1, 1, 0).day;
    return DateTime(year, month + 1, 0).day;
  }

  int _firstDayOfWeek(int month, int year) {
    return DateTime(year, month, 1).weekday; // 1 = Monday, 7 = Sunday
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text('Kalender',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
            centerTitle: true),
        body:
            BlocBuilder<CompanyCubit, CompanyState>(builder: (context, state) {
          final isLoaded = state is CompanyLoaded;
          final events = isLoaded ? state.calendarEvents : [];
          final logs = isLoaded ? state.attendanceLogs : [];
          final workingDays = isLoaded ? state.workingDays : [1, 2, 3, 4, 5];

          final monthStr =
              DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth);
          final days = _daysInMonth(_currentMonth.month, _currentMonth.year);
          final firstDay =
              _firstDayOfWeek(_currentMonth.month, _currentMonth.year);
          final totalCells = firstDay - 1 + days;
          final rows = (totalCells / 7).ceil();
          final today = DateTime.now();

          return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Header
                    InfoCard(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                          IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _changeMonth(-1)),
                          Text(monthStr,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _changeMonth(1)),
                        ])),
                    SizedBox(height: 16.h),

                    if (state is CompanyLoading)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator()))
                    else if (state is CompanyError)
                      Center(
                          child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(state.message,
                                  style:
                                      const TextStyle(color: AppColors.error))))
                    else ...[
                      // Mini Calendar Grid
                      InfoCard(
                          child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              'Sen',
                              'Sel',
                              'Rab',
                              'Kam',
                              'Jum',
                              'Sab',
                              'Min'
                            ]
                                .map((d) => SizedBox(
                                    width: 36.w,
                                    child: Center(
                                        child: Text(d,
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                                fontWeight: FontWeight.w600)))))
                                .toList()),
                        SizedBox(height: 8.h),
                        ...List.generate(
                            rows,
                            (week) => Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: List.generate(7, (dayIdx) {
                                    final cellIndex = week * 7 + dayIdx;
                                    final date = cellIndex - (firstDay - 1) + 1;
                                    final weekday = dayIdx + 1; // 1 to 7

                                    if (date < 1 || date > days) {
                                      return SizedBox(width: 36.w);
                                    }

                                    final currentDate = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month,
                                        date);
                                    final isToday =
                                        currentDate.year == today.year &&
                                            currentDate.month == today.month &&
                                            currentDate.day == today.day;
                                    final isFuture =
                                        currentDate.isAfter(today) && !isToday;

                                    // Check events for this date
                                    final dayEvents = events
                                        .where((e) =>
                                            e.startDate.year ==
                                                currentDate.year &&
                                            e.startDate.month ==
                                                currentDate.month &&
                                            e.startDate.day == currentDate.day)
                                        .toList();

                                    final hasEvent = dayEvents.isNotEmpty;
                                    final isHoliday = dayEvents
                                        .any((e) => e.type == 'holiday');

                                    // Check working day
                                    final isWorkingDay =
                                        workingDays.contains(weekday) &&
                                            !isHoliday;

                                    // Check attendance log
                                    final dayLogStr = DateFormat('yyyy-MM-dd')
                                        .format(currentDate);
                                    final hasLog = logs.any((log) =>
                                        (log['check_in_at'] as String)
                                            .startsWith(dayLogStr));

                                    Color dotColor = Colors.transparent;
                                    if (!isFuture && isWorkingDay) {
                                      if (hasLog) {
                                        dotColor =
                                            AppColors.successEmerald; // Hadir
                                      } else if (!isToday) {
                                        dotColor =
                                            AppColors.errorCrimson; // Alpha
                                      }
                                    } else if (isHoliday) {
                                      dotColor =
                                          AppColors.infoCerulean; // Libur
                                    }

                                    return Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isToday
                                                ? AppColors.primaryContainer
                                                : (isHoliday
                                                    ? AppColors.infoCerulean
                                                        .withValues(alpha: 0.1)
                                                    : Colors.transparent),
                                            border: isToday
                                                ? null
                                                : Border.all(
                                                    color: isWorkingDay &&
                                                            !hasLog &&
                                                            !isFuture &&
                                                            !isToday
                                                        ? AppColors.errorCrimson
                                                            .withValues(
                                                                alpha: 0.3)
                                                        : Colors.transparent)),
                                        child: Stack(
                                          children: [
                                            Center(
                                                child: Text('$date',
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: isToday
                                                            ? AppColors
                                                                .onPrimary
                                                            : (isHoliday
                                                                ? AppColors
                                                                    .infoCerulean
                                                                : (isWorkingDay
                                                                    ? AppColors
                                                                        .onSurface
                                                                    : AppColors
                                                                        .outline)),
                                                        fontWeight: isToday ||
                                                                isHoliday
                                                            ? FontWeight.bold
                                                            : FontWeight
                                                                .normal))),
                                            if (dotColor !=
                                                    Colors.transparent ||
                                                hasEvent)
                                              Positioned(
                                                bottom: 4.h,
                                                left: 0,
                                                right: 0,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (dotColor !=
                                                        Colors.transparent)
                                                      Container(
                                                          width: 4.w,
                                                          height: 4.w,
                                                          margin: EdgeInsets
                                                              .only(
                                                                  right: hasEvent
                                                                      ? 2.w
                                                                      : 0),
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color:
                                                                      dotColor)),
                                                    if (hasEvent)
                                                      Container(
                                                          width: 4.w,
                                                          height: 4.w,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: isToday
                                                                  ? AppColors
                                                                      .onPrimary
                                                                  : AppColors
                                                                      .primary)),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ));
                                  }),
                                ))),
                        SizedBox(height: 8.h),
                        // Legend
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegend(AppColors.successEmerald, 'Hadir'),
                              SizedBox(width: 12.w),
                              _buildLegend(AppColors.errorCrimson, 'Alpha'),
                              SizedBox(width: 12.w),
                              _buildLegend(AppColors.infoCerulean, 'Libur'),
                              SizedBox(width: 12.w),
                              _buildLegend(AppColors.primary, 'Event'),
                            ])
                      ])),
                      SizedBox(height: 24.h),

                      Text('Event Bulan Ini',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 12.h),

                      if (events.isEmpty)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('Belum ada event di bulan ini')))
                      else
                        ...events.map((e) {
                          final color = _getEventColor(e.type ?? 'meeting');
                          return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: InfoCard(
                                borderLeftColor: color,
                                onTap:
                                    () {}, // context.push('/app/calendar/event', extra: e)
                                child: Row(children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(e.title,
                                            style: TextStyle(
                                                color: AppColors.onSurface,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.sp)),
                                        SizedBox(height: 4.h),
                                        Row(children: [
                                          Icon(Icons.calendar_today,
                                              size: 12.w,
                                              color:
                                                  AppColors.onSurfaceVariant),
                                          SizedBox(width: 4.w),
                                          Text(
                                              DateFormat('dd MMM yyyy')
                                                  .format(e.startDate),
                                              style: TextStyle(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                  fontSize: 12.sp)),
                                        ]),
                                      ])),
                                  Icon(Icons.chevron_right,
                                      color: AppColors.outline, size: 20.w),
                                ]),
                              ));
                        }),
                    ]
                  ]));
        }));
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        SizedBox(width: 4.w),
        Text(text,
            style:
                TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
