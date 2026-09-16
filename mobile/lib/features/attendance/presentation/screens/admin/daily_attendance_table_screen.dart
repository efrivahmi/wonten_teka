import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/attendance_log_model.dart';

class DailyAttendanceTableScreen extends StatefulWidget {
  const DailyAttendanceTableScreen({super.key});

  @override
  State<DailyAttendanceTableScreen> createState() =>
      _DailyAttendanceTableScreenState();
}

class _DailyAttendanceTableScreenState
    extends State<DailyAttendanceTableScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<AttendanceLogModel> _logs = [];
  List<String> _departments = [];
  String? _department;
  final TextEditingController _searchController = TextEditingController();
  String _periodMode = 'month';
  DateTime _month = DateTime.now();
  DateTimeRange? _dateRange;
  final Set<int> _selectedEmployees = {};
  bool _draftReady = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadDepartments();
    _loadData();
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await _api.get('/employee/options');
      if (mounted) {
        setState(() => _departments =
            (response.data['departments'] as List? ?? [])
                .map((e) => e.toString())
                .toList());
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, dynamic>{'per_page': 500};
      if (_department != null) params['department'] = _department;
      if (_searchController.text.trim().isNotEmpty) {
        params['search'] = _searchController.text.trim();
      }
      if (_selectedEmployees.isNotEmpty) {
        params['employee_ids'] = _selectedEmployees.join(',');
      }
      if (_periodMode == 'month') {
        params['month'] = _month.month;
        params['year'] = _month.year;
      } else if (_dateRange != null) {
        params['date_from'] = DateFormat('yyyy-MM-dd').format(_dateRange!.start);
        params['date_to'] = DateFormat('yyyy-MM-dd').format(_dateRange!.end);
      }
      final response = await _api.get('/admin/attendance', queryParameters: params);
      if (mounted) {
        final List<dynamic> rawData = response.data['data'];
        setState(() {
          _logs = rawData.map((json) {
            return AttendanceLogModel.fromJson(json as Map<String, dynamic>);
          }).toList();
          _isLoading = false;
          _draftReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error fetching data')));
      }
    }
  }

  Future<void> _pickPeriod() async {
    if (_periodMode == 'month') {
      final picked = await showDatePicker(
          context: context,
          initialDate: _month,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          helpText: 'Pilih tanggal dalam bulan rekap');
      if (picked != null) setState(() { _month = picked; _draftReady = false; });
    } else {
      final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: _dateRange);
      if (picked != null) setState(() { _dateRange = picked; _draftReady = false; });
    }
  }

  Future<void> _exportDraft() async {
    final selected = _selectedEmployees.isEmpty
        ? _logs
        : _logs.where((log) => _selectedEmployees.contains(log.employeeId)).toList();
    final lines = <String>['Karyawan,Tanggal,Masuk,Keluar,Status'];
    for (final log in selected) {
      String cell(Object? value) => '"${(value ?? '').toString().replaceAll('"', '""')}"';
      lines.add([log.employeeName ?? 'Karyawan #${log.employeeId}', DateFormat('dd/MM/yyyy').format(log.checkInAt), log.status == 'absent' ? '' : DateFormat('HH:mm').format(log.checkInAt), log.checkOutAt == null ? '' : DateFormat('HH:mm').format(log.checkOutAt!), log.status].map(cell).join(','));
    }
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Draft CSV ${selected.length} catatan disalin. Tempelkan ke Excel/Sheets untuk menyimpan file.')));
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tabel Absensi Harian',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(190),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(children: [TextField(controller: _searchController, onChanged: (_) => setState(() => _draftReady = false), decoration: const InputDecoration(labelText: 'Cari nama, nomor, atau email', prefixIcon: Icon(Icons.search), filled: true)), const SizedBox(height: 8), Row(children: [Expanded(child: DropdownButtonFormField<String>(
              initialValue: _department,
              decoration: const InputDecoration(
                  labelText: 'Filter departemen', filled: true),
              items: [
                const DropdownMenuItem<String>(
                    value: null, child: Text('Semua departemen')),
                ..._departments.map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)))
              ],
              onChanged: (value) {
                _department = value;
                _loadData();
              },
            )), const SizedBox(width: 8), Expanded(child: DropdownButtonFormField<String>(initialValue: _periodMode, decoration: const InputDecoration(labelText: 'Periode', filled: true), items: const [DropdownMenuItem(value: 'month', child: Text('Per bulan')), DropdownMenuItem(value: 'range', child: Text('Rentang tanggal'))], onChanged: (value) => setState(() { _periodMode = value ?? 'month'; _draftReady = false; })))]), const SizedBox(height: 8), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _pickPeriod, icon: const Icon(Icons.date_range), label: Text(_periodMode == 'month' ? DateFormat('MMMM yyyy', 'id_ID').format(_month) : (_dateRange == null ? 'Pilih rentang' : '${DateFormat('dd/MM/yy').format(_dateRange!.start)}–${DateFormat('dd/MM/yy').format(_dateRange!.end)}')))), const SizedBox(width: 8), FilledButton.icon(onPressed: _periodMode == 'range' && _dateRange == null ? null : _loadData, icon: const Icon(Icons.preview), label: const Text('Draft'))]),
            ]),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('Belum ada data absensi.'))
              : Column(children: [Padding(padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0), child: Row(children: [Expanded(child: Text('${_logs.length} catatan dalam draft', style: const TextStyle(fontWeight: FontWeight.bold))), FilledButton.icon(onPressed: _draftReady ? _exportDraft : null, icon: const Icon(Icons.download), label: const Text('Export draft'))])), Expanded(child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                          AppColors.primary.withValues(alpha: 0.1)),
                      columns: const [DataColumn(label: Text('Pilih')),
                        DataColumn(label: Text('Nama Karyawan')),
                        DataColumn(label: Text('Masuk')),
                        DataColumn(label: Text('Keluar')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Catatan/Pelanggaran')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: _logs.map((log) {
                        final empName = log.employeeName ?? 'Unknown';
                        final checkInStr =
                            DateFormat('HH:mm').format(log.checkInAt);
                        final checkOutStr = log.checkOutAt != null
                            ? DateFormat('HH:mm').format(log.checkOutAt!)
                            : '--:--';

                        return DataRow(
                          cells: [
                            DataCell(Checkbox(value: _selectedEmployees.contains(log.employeeId), onChanged: (_) => setState(() { if (!_selectedEmployees.add(log.employeeId)) _selectedEmployees.remove(log.employeeId); _draftReady = false; }))),
                            DataCell(Text(empName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text(checkInStr)),
                            DataCell(Text(checkOutStr)),
                            DataCell(_buildStatusChip(log.status)),
                            DataCell(_buildViolations(log)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye,
                                    color: AppColors.primary, size: 20),
                                onPressed: () {
                                  context.push('/app/attendance/detail',
                                      extra: log);
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ))]),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'on_time':
      case 'present':
        color = AppColors.successEmerald;
        label = 'Tepat Waktu';
        break;
      case 'late':
        color = AppColors.warningAmber;
        label = 'Terlambat';
        break;
      case 'absent':
        color = AppColors.errorCrimson;
        label = 'Alpha / Tidak Masuk';
        break;
      case 'flagged':
        color = AppColors.warningAmber;
        label = 'Ditinjau';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildViolations(AttendanceLogModel log) {
    List<String> violations = [];
    if (log.flags != null) {
      if (log.flags!['is_mock_location'] == true) {
        violations.add('Lokasi Palsu (Fake GPS)');
      }
      if (log.flags!['low_face_match_score'] == true) {
        violations.add('Wajah Tidak Cocok (<80%)');
      }
      if (log.flags!['early_leave'] == true) {
        violations.add('Pulang Lebih Awal');
      }
    }

    if (violations.isEmpty) {
      return const Text('-');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: violations
          .map((v) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning,
                      color: AppColors.errorCrimson, size: 14),
                  SizedBox(width: 4.w),
                  Text(v,
                      style: TextStyle(
                          color: AppColors.errorCrimson, fontSize: 11.sp)),
                ],
              ))
          .toList(),
    );
  }
}
