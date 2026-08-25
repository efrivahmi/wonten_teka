import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';

class ShiftAssignmentGridScreen extends StatefulWidget {
  const ShiftAssignmentGridScreen({super.key});

  @override
  State<ShiftAssignmentGridScreen> createState() =>
      _ShiftAssignmentGridScreenState();
}

class _ShiftAssignmentGridScreenState extends State<ShiftAssignmentGridScreen> {
  late final ApiClient _api;

  bool _isLoading = true;
  String _startDateStr = '';
  String _endDateStr = '';
  List<dynamic> _employees = [];
  List<dynamic> _assignments = [];
  List<dynamic> _templates = [];

  DateTime _currentWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadGrid();
  }

  Future<void> _loadGrid() async {
    setState(() => _isLoading = true);

    final endOfWeek = _currentWeekStart.add(const Duration(days: 6));
    final startFormat = DateFormat('yyyy-MM-dd').format(_currentWeekStart);
    final endFormat = DateFormat('yyyy-MM-dd').format(endOfWeek);

    try {
      final response = await _api.get(
          '/admin/shift-assignments?start_date=$startFormat&end_date=$endFormat');
      if (mounted) {
        setState(() {
          _startDateStr = response.data['start_date'];
          _endDateStr = response.data['end_date'];
          _employees = response.data['employees'] as List;
          _assignments = response.data['assignments'] as List;
          _templates = response.data['templates'] as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _changeWeek(int offsetDays) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: offsetDays));
    });
    _loadGrid();
  }

  dynamic _getAssignmentFor(int employeeId, String dateStr) {
    return _assignments.firstWhere(
      (a) =>
          a['employee_id'] == employeeId &&
          (a['date'] as String).startsWith(dateStr),
      orElse: () => null,
    );
  }

  void _showAssignSheet(int employeeId, String dateStr) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
        builder: (ctx) {
          return SafeArea(
              child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih Shift',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                if (_templates.isEmpty)
                  const Text(
                      'Belum ada template shift. Buat di menu Template Shift terlebih dahulu.')
                else
                  ..._templates.map((t) => ListTile(
                        title: Text(t['name']),
                        subtitle: Text(
                            '${t['start_time'].toString().substring(0, 5)} - ${t['end_time'].toString().substring(0, 5)}'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _assignShift(employeeId, dateStr, t['id']);
                        },
                      )),
              ],
            ),
          ));
        });
  }

  Future<void> _assignShift(
      int employeeId, String dateStr, int templateId) async {
    try {
      await _api.post('/admin/shift-assignments', data: {
        'employee_id': employeeId,
        'date': dateStr,
        'shift_template_id': templateId,
      });
      _loadGrid(); // Refresh grid
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal assign shift: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final endOfWeek = _currentWeekStart.add(const Duration(days: 6));
    final displayRange =
        '${DateFormat('dd MMM').format(_currentWeekStart)} - ${DateFormat('dd MMM yyyy').format(endOfWeek)}';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text('Assign Shift',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: Column(children: [
        Container(
            color: AppColors.surface,
            padding: EdgeInsets.all(16.w),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeWeek(-7)),
                  Text(displayRange,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeWeek(7)),
                ])),
        Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                    ? const Center(child: Text('Belum ada karyawan aktif'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                            child: DataTable(
                          columnSpacing: 16.w,
                          columns: [
                            const DataColumn(
                                label: Text('Karyawan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            ...List.generate(7, (j) {
                              final date =
                                  _currentWeekStart.add(Duration(days: j));
                              return DataColumn(
                                  label: Text(
                                      DateFormat('E', 'id_ID').format(date)));
                            }),
                          ],
                          rows: _employees.map((emp) {
                            return DataRow(cells: [
                              DataCell(SizedBox(
                                width: 100.w,
                                child: Text(emp['full_name'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              )),
                              ...List.generate(7, (j) {
                                final date =
                                    _currentWeekStart.add(Duration(days: j));
                                final dateStr =
                                    DateFormat('yyyy-MM-dd').format(date);

                                final assignment =
                                    _getAssignmentFor(emp['id'], dateStr);

                                String text = '-';
                                Color color = AppColors.surfaceContainerHigh;
                                Color textColor = AppColors.onSurfaceVariant;

                                if (assignment != null) {
                                  final t = assignment['shift_template'];
                                  text = t != null
                                      ? t['name']
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?';
                                  color = AppColors.primaryContainer;
                                  textColor = AppColors.onPrimary;
                                }

                                return DataCell(InkWell(
                                    onTap: () =>
                                        _showAssignSheet(emp['id'], dateStr),
                                    child: Container(
                                      width: 40.w,
                                      height: 40.w,
                                      margin: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(4.r)),
                                      child: Center(
                                          child: Text(text,
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    )));
                              }),
                            ]);
                          }).toList(),
                        )))),
      ]),
    );
  }
}

