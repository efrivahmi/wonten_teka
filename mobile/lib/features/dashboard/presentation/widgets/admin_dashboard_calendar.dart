import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/services/holiday_service.dart';
import '../../../../../core/theme/app_colors.dart';

class AdminDashboardCalendar extends StatefulWidget {
  const AdminDashboardCalendar({super.key});

  @override
  State<AdminDashboardCalendar> createState() => _AdminDashboardCalendarState();
}

class _AdminDashboardCalendarState extends State<AdminDashboardCalendar> {
  DateTime _currentMonth = DateTime.now();
  final DateTime _today = DateTime.now();

  final HolidayService _holidayService = HolidayService.instance;

  /// Menyimpan set hari libur untuk bulan yang sedang ditampilkan.
  Set<DateTime> _holidays = {};
  bool _isLoadingHolidays = false;

  @override
  void initState() {
    super.initState();
    _loadHolidays(_currentMonth.year);
  }

  Future<void> _loadHolidays(int year) async {
    if (!mounted) return;
    setState(() => _isLoadingHolidays = true);

    final holidays = await _holidayService.fetchHolidays(year);

    if (!mounted) return;
    setState(() {
      _holidays = holidays;
      _isLoadingHolidays = false;
    });
  }

  bool _isHoliday(DateTime date) {
    return _holidayService.isHoliday(date, _holidays);
  }

  void _goToPreviousMonth() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    setState(() => _currentMonth = newMonth);
    // Muat hari libur jika berpindah tahun
    if (newMonth.year != _currentMonth.year) {
      _loadHolidays(newMonth.year);
    }
  }

  void _goToNextMonth() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    // Muat hari libur jika berpindah tahun
    final needsLoad = newMonth.year != _currentMonth.year;
    setState(() => _currentMonth = newMonth);
    if (needsLoad) {
      _loadHolidays(newMonth.year);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  if (_isLoadingHolidays) ...[
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Days of Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].map((day) {
              final isSunday = day == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: isSunday ? AppColors.errorCrimson : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
          
          // Calendar Grid
          _buildCalendarGrid(),
          SizedBox(height: 16.h),
          
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    final int totalCells = (daysInMonth + firstWeekday - 1 > 35) ? 42 : 35;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final int dayOffset = index - (firstWeekday - 1);
        
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }
        
        final DateTime date = DateTime(_currentMonth.year, _currentMonth.month, dayOffset + 1);
        final bool isToday = date.year == _today.year && date.month == _today.month && date.day == _today.day;
        final bool isSunday = date.weekday == DateTime.sunday;
        final bool isHoliday = _isHoliday(date);

        return Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: isToday ? Border.all(color: AppColors.primary, width: 1) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: (isSunday || isHoliday) ? AppColors.errorCrimson : AppColors.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              if (!isSunday && !isHoliday && date.isBefore(_today))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(AppColors.successEmerald), // Hadir
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(AppColors.successEmerald, 'Hadir'),
        _legendItem(AppColors.errorCrimson, 'Alpha/Libur'),
        _legendItem(AppColors.warningAmber, 'Cuti/Sakit'),
        _legendItem(AppColors.infoCerulean, 'Lembur'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
