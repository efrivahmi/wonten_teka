import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../company/bloc/company_cubit.dart';

class CompanyCalendarScreen extends StatefulWidget {
  const CompanyCalendarScreen({Key? key}) : super(key: key);

  @override
  State<CompanyCalendarScreen> createState() => _CompanyCalendarScreenState();
}

class _CompanyCalendarScreenState extends State<CompanyCalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyCubit>().loadAll();
    });
  }

  Color _getEventColor(String type) {
    final lower = type.toLowerCase();
    if (lower == 'holiday') return AppColors.successEmerald;
    if (lower == 'meeting') return AppColors.infoCerulean;
    if (lower == 'deadline') return AppColors.errorCrimson;
    return AppColors.warningAmber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        title: Text('Kalender', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CompanyError) {
            return Center(child: Text(state.message, style: TextStyle(color: AppColors.error)));
          } else if (state is CompanyLoaded) {
            // Very simple calendar logic mock for UI purposes
            final currentMonth = 'Juli 2025';
            return SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Month Header
              InfoCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                Text(currentMonth, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
              ])),
              SizedBox(height: 16.h),

              // Mini Calendar Grid
              InfoCard(child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                  .map((d) => SizedBox(width: 36.w, child: Center(child: Text(d, style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600))))).toList()),
                SizedBox(height: 8.h),
                ...List.generate(5, (week) => Padding(padding: EdgeInsets.only(bottom: 4.h), child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (day) {
                    final date = week * 7 + day + 1 - 1; // offset for July 2025 starting on Tuesday
                    if (date < 1 || date > 31) return SizedBox(width: 36.w);
                    final isToday = date == 9;
                    
                    // Simple logic to map events to dates in the UI
                    // Real app would parse the actual DateTime from the events
                    final hasEvent = state.calendarEvents.isNotEmpty && date % 5 == 0; 

                    return Container(width: 36.w, height: 36.w, decoration: BoxDecoration(
                      shape: BoxShape.circle, color: isToday ? AppColors.primaryContainer : Colors.transparent),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('$date', style: TextStyle(fontSize: 12.sp, color: isToday ? AppColors.onPrimary : AppColors.onSurface, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                        if (hasEvent) Container(width: 4.w, height: 4.w, decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? AppColors.onPrimary : AppColors.primaryContainer)),
                      ]));
                  }),
                ))),
              ])),
              SizedBox(height: 24.h),

              Text('Event Mendatang', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 12.h),

              if (state.calendarEvents.isEmpty)
                const Center(child: Text('Belum ada event mendatang'))
              else
                ...state.calendarEvents.map((e) {
                  final color = _getEventColor(e.type ?? 'meeting');
                  return Padding(padding: EdgeInsets.only(bottom: 12.h), child: InfoCard(
                    borderLeftColor: color,
                    onTap: () => context.push('/app/calendar/event'),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.title, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        SizedBox(height: 4.h),
                        Row(children: [
                          Icon(Icons.calendar_today, size: 12.w, color: AppColors.onSurfaceVariant), SizedBox(width: 4.w),
                          Text(DateFormat('yyyy-MM-dd').format(e.startDate), style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)), // simplistic format
                          SizedBox(width: 12.w),
                          if (e.endDate != null) ...[
                            Icon(Icons.schedule, size: 12.w, color: AppColors.onSurfaceVariant), SizedBox(width: 4.w),
                            Text(DateFormat('HH:mm').format(e.startDate), style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)), // simplistic format
                          ]
                        ]),
                      ])),
                      Icon(Icons.chevron_right, color: AppColors.outline, size: 20.w),
                    ]),
                  ));
                }),
            ]));
          }
          return const SizedBox.shrink();
        }
      )
    );
  }
}
