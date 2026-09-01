import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/company_models.dart';

class DashboardCalendar extends StatefulWidget {
  final List<int> workingDays;
  final List<CalendarEventModel> events;
  final Function(DateTime) onDateSelected;

  const DashboardCalendar({
    super.key,
    required this.workingDays,
    this.events = const [],
    required this.onDateSelected,
  });

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  DateTime _currentDate = DateTime.now();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(_currentDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _prevMonth,
                    color: AppColors.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    color: AppColors.primary,
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 12.h),
          _buildDaysOfWeek(),
          SizedBox(height: 12.h),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    
    // In Dart, weekday is 1 for Monday, 7 for Sunday.
    final firstWeekday = firstDayOfMonth.weekday;

    int totalCells = daysInMonth + firstWeekday - 1;
    int rows = (totalCells / 7).ceil();

    List<Widget> gridRows = [];

    for (int i = 0; i < rows; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < 7; j++) {
        final cellIndex = i * 7 + j;
        final day = cellIndex - firstWeekday + 2;
        
        if (day > 0 && day <= daysInMonth) {
          final date = DateTime(_currentDate.year, _currentDate.month, day);
          cells.add(Expanded(child: _buildDayCell(date)));
        } else {
          cells.add(Expanded(child: Container()));
        }
      }
      gridRows.add(Row(children: cells));
      if (i < rows - 1) gridRows.add(SizedBox(height: 8.h));
    }

    return Column(children: gridRows);
  }

  Widget _buildDayCell(DateTime date) {
    bool isSelected = _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;

    bool isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    bool isWorkingDay = widget.workingDays.contains(date.weekday);

    // Check if there are events
    bool hasEvent = widget.events.any((e) => 
      e.startDate.year == date.year &&
      e.startDate.month == date.month &&
      e.startDate.day == date.day
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        widget.onDateSelected(date);
      },
      child: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primaryContainer
                  : isWorkingDay
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.onPrimaryContainer
                          : isWorkingDay
                              ? AppColors.onSurface
                              : Colors.grey,
                ),
              ),
              if (hasEvent)
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
