import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  List<Map<String, dynamic>> _employees = [];
  String? _department;
  final TextEditingController _searchController = TextEditingController();
  String _periodMode = 'month';
  DateTime _month = DateTime.now();
  DateTimeRange? _dateRange;
  final Set<int> _selectedEmployees = {};
  bool _draftReady = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalRecords = 0;

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
    _loadEmployees();
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

  Future<void> _loadEmployees() async {
    try {
      final response = await _api.get('/admin/employees');
      final data = response.data is Map ? response.data['data'] : null;
      if (mounted) {
        setState(() => _employees = (data as List? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList());
      }
    } catch (_) {
      // The attendance draft remains usable even if this optional filter fails.
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final params = <String, dynamic>{'page': _currentPage, 'per_page': 50};
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
        params['date_from'] =
            DateFormat('yyyy-MM-dd').format(_dateRange!.start);
        params['date_to'] = DateFormat('yyyy-MM-dd').format(_dateRange!.end);
      }
      final response =
          await _api.get('/admin/attendance', queryParameters: params);
      if (mounted) {
        final body = response.data;
        final raw = body is Map ? body['data'] : null;
        final List<dynamic> rawData = raw is List ? raw : const [];
        setState(() {
          _logs = rawData.map((json) {
            return AttendanceLogModel.fromJson(json as Map<String, dynamic>);
          }).toList();
          _isLoading = false;
          _draftReady = true;
          _currentPage = body is Map && body['current_page'] is int
              ? body['current_page'] as int
              : 1;
          _lastPage = body is Map && body['last_page'] is int
              ? body['last_page'] as int
              : 1;
          _totalRecords = body is Map && body['total'] is int
              ? body['total'] as int
              : rawData.length;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Tabel absensi belum dapat dimuat. Periksa koneksi lalu coba lagi.';
        });
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
      if (picked != null) {
        setState(() {
          _month = picked;
          _draftReady = false;
        });
      }
    } else {
      final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: _dateRange);
      if (picked != null) {
        setState(() {
          _dateRange = picked;
          _draftReady = false;
        });
      }
    }
  }

  Future<void> _exportDraft() async {
    final selected = _selectedEmployees.isEmpty
        ? _logs
        : _logs
            .where((log) => _selectedEmployees.contains(log.employeeId))
            .toList();
    final lines = <String>['Karyawan,Tanggal,Masuk,Keluar,Status'];
    for (final log in selected) {
      String cell(Object? value) =>
          '"${(value ?? '').toString().replaceAll('"', '""')}"';
      lines.add([
        log.employeeName ?? 'Karyawan #${log.employeeId}',
        DateFormat('dd/MM/yyyy').format(log.checkInAt),
        log.status == 'absent' ? '' : DateFormat('HH:mm').format(log.checkInAt),
        log.checkOutAt == null
            ? ''
            : DateFormat('HH:mm').format(log.checkOutAt!),
        log.status
      ].map(cell).join(','));
    }
    try {
      final directory = await getTemporaryDirectory();
      final period = _periodMode == 'month'
          ? DateFormat('yyyy-MM').format(_month)
          : '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)}_${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}';
      final file = File('${directory.path}/draft-rekap-absensi-$period.csv');
      await file.writeAsString('\uFEFF${lines.join('\n')}', flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Draft Rekap Absensi $period',
        text: 'Draft rekap absensi berisi ${selected.length} catatan.',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File CSV belum dapat dibuat. Silakan coba lagi.')));
    }
  }

  Future<void> _showEmployeePicker() async {
    final query = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, updateSheet) {
          final filtered = _employees.where((employee) {
            final haystack = '${employee['full_name'] ?? ''} '
                    '${employee['employee_number'] ?? ''} ${employee['email'] ?? employee['user']?['email'] ?? ''}'
                .toLowerCase();
            return haystack.contains(query.text.trim().toLowerCase());
          }).toList();
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * .82,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(children: [
                  const Expanded(
                      child: Text('Pilih karyawan',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedEmployees.clear();
                        _draftReady = false;
                      });
                      updateSheet(() {});
                    },
                    child: const Text('Semua'),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: query,
                  onChanged: (_) => updateSheet(() {}),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Cari nama, nomor, atau email',
                      filled: true),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Karyawan tidak ditemukan.'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final employee = filtered[index];
                          final id =
                              int.tryParse(employee['id'].toString()) ?? 0;
                          return CheckboxListTile(
                            value: _selectedEmployees.contains(id),
                            title: Text(employee['full_name']?.toString() ??
                                'Belum melengkapi profil'),
                            subtitle: Text(
                                employee['employee_number']?.toString() ??
                                    employee['email']?.toString() ??
                                    employee['user']?['email']?.toString() ??
                                    '-'),
                            onChanged: (_) {
                              setState(() {
                                if (!_selectedEmployees.add(id)) {
                                  _selectedEmployees.remove(id);
                                }
                                _draftReady = false;
                              });
                              updateSheet(() {});
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(
                            'Gunakan ${_selectedEmployees.isEmpty ? 'semua karyawan' : '${_selectedEmployees.length} karyawan'}'))),
              ),
            ]),
          );
        },
      ),
    );
    query.dispose();
  }

  Future<void> _deleteLog(AttendanceLogModel log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus log absensi?'),
        content: Text(
            'Log ${log.employeeName ?? 'karyawan'} akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.delete('/admin/attendance/${log.id}');
      await _loadData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log belum dapat dihapus.')));
      }
    }
  }

  Future<void> _editLog(AttendanceLogModel log) async {
    TimeOfDay checkIn = TimeOfDay.fromDateTime(log.checkInAt);
    TimeOfDay? checkOut =
        log.checkOutAt == null ? null : TimeOfDay.fromDateTime(log.checkOutAt!);
    String status = log.status;
    final saved = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(builder: (context, update) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit log absensi',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Perubahan manual akan langsung merevisi riwayat karyawan.'),
                const SizedBox(height: 16),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Jam masuk'),
                    trailing: Text(checkIn.format(context)),
                    onTap: () async {
                      final value = await showTimePicker(
                          context: context, initialTime: checkIn);
                      if (value != null) update(() => checkIn = value);
                    }),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Jam keluar'),
                    trailing: Text(checkOut?.format(context) ?? 'Belum ada'),
                    onTap: () async {
                      final value = await showTimePicker(
                          context: context, initialTime: checkOut ?? checkIn);
                      if (value != null) update(() => checkOut = value);
                    }),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration:
                      const InputDecoration(labelText: 'Status', filled: true),
                  items: const [
                    DropdownMenuItem(
                        value: 'on_time', child: Text('Tepat waktu')),
                    DropdownMenuItem(value: 'late', child: Text('Terlambat')),
                    DropdownMenuItem(
                        value: 'absent', child: Text('Alpha / Tidak masuk')),
                    DropdownMenuItem(
                        value: 'leave', child: Text('Cuti / Sakit')),
                  ],
                  onChanged: (value) => update(() => status = value ?? status),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: () => Navigator.pop(context, {
                              'checkIn': checkIn,
                              'checkOut': checkOut,
                              'status': status
                            }),
                        child: const Text('Simpan perubahan'))),
              ]),
        );
      }),
    );
    if (saved == null) return;
    DateTime combine(TimeOfDay time) => DateTime(log.checkInAt.year,
        log.checkInAt.month, log.checkInAt.day, time.hour, time.minute);
    try {
      await _api.put('/admin/attendance/${log.id}', data: {
        'check_in_at': combine(saved['checkIn'] as TimeOfDay).toIso8601String(),
        'check_out_at': saved['checkOut'] == null
            ? null
            : combine(saved['checkOut'] as TimeOfDay).toIso8601String(),
        'status': saved['status'],
      });
      await _loadData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Perubahan log belum dapat disimpan.')));
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
          preferredSize: const Size.fromHeight(242),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(children: [
              TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() => _draftReady = false),
                  decoration: const InputDecoration(
                      labelText: 'Cari nama, nomor, atau email',
                      prefixIcon: Icon(Icons.search),
                      filled: true)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showEmployeePicker,
                  icon: const Icon(Icons.groups_outlined),
                  label: Text(_selectedEmployees.isEmpty
                      ? 'Semua karyawan'
                      : '${_selectedEmployees.length} karyawan dipilih'),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: DropdownButtonFormField<String>(
                  initialValue: _department,
                  decoration: const InputDecoration(
                      labelText: 'Filter departemen', filled: true),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Semua departemen')),
                    ..._departments.map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                  ],
                  onChanged: (value) {
                    _department = value;
                    _loadData();
                  },
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: DropdownButtonFormField<String>(
                        initialValue: _periodMode,
                        decoration: const InputDecoration(
                            labelText: 'Periode', filled: true),
                        items: const [
                          DropdownMenuItem(
                              value: 'month', child: Text('Per bulan')),
                          DropdownMenuItem(
                              value: 'range', child: Text('Rentang tanggal'))
                        ],
                        onChanged: (value) => setState(() {
                              _periodMode = value ?? 'month';
                              _draftReady = false;
                            })))
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: _pickPeriod,
                        icon: const Icon(Icons.date_range),
                        label: Text(_periodMode == 'month'
                            ? DateFormat('MMMM yyyy', 'id_ID').format(_month)
                            : (_dateRange == null
                                ? 'Pilih rentang'
                                : '${DateFormat('dd/MM/yy').format(_dateRange!.start)}–${DateFormat('dd/MM/yy').format(_dateRange!.end)}')))),
                const SizedBox(width: 8),
                FilledButton.icon(
                    onPressed: _periodMode == 'range' && _dateRange == null
                        ? null
                        : _loadData,
                    icon: const Icon(Icons.preview),
                    label: const Text('Draft'))
              ]),
            ]),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorCrimson, size: 44),
                      SizedBox(height: 12.h),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      SizedBox(height: 12.h),
                      FilledButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi')),
                    ]),
                  ),
                )
              : _logs.isEmpty
                  ? const Center(child: Text('Belum ada data absensi.'))
                  : Column(children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                          child: Row(children: [
                            Expanded(
                                child: Text(
                                    'Halaman $_currentPage/$_lastPage • $_totalRecords catatan',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            FilledButton.icon(
                                onPressed: _draftReady ? _exportDraft : null,
                                icon: const Icon(Icons.download),
                                label: const Text('Export draft'))
                          ])),
                      if (_lastPage > 1)
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Halaman sebelumnya',
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() => _currentPage--);
                                        _loadData();
                                      }
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              Text('$_currentPage / $_lastPage'),
                              IconButton(
                                tooltip: 'Halaman berikutnya',
                                onPressed: _currentPage < _lastPage
                                    ? () {
                                        setState(() => _currentPage++);
                                        _loadData();
                                      }
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                          child: MediaQuery.sizeOf(context).width < 700
                              ? _buildMobileLogList()
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                          AppColors.primary
                                              .withValues(alpha: 0.1)),
                                      columns: const [
                                        DataColumn(label: Text('Pilih')),
                                        DataColumn(
                                            label: Text('Nama Karyawan')),
                                        DataColumn(label: Text('Masuk')),
                                        DataColumn(label: Text('Keluar')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(
                                            label: Text('Catatan/Pelanggaran')),
                                        DataColumn(label: Text('Aksi')),
                                      ],
                                      rows: _logs.map((log) {
                                        final empName =
                                            log.employeeName ?? 'Unknown';
                                        final checkInStr =
                                            log.status == 'absent'
                                                ? '--:--'
                                                : DateFormat('HH:mm')
                                                    .format(log.checkInAt);
                                        final checkOutStr =
                                            log.checkOutAt != null
                                                ? DateFormat('HH:mm')
                                                    .format(log.checkOutAt!)
                                                : '--:--';

                                        return DataRow(
                                          cells: [
                                            DataCell(Checkbox(
                                                value: _selectedEmployees
                                                    .contains(log.employeeId),
                                                onChanged: (_) => setState(() {
                                                      if (!_selectedEmployees
                                                          .add(
                                                              log.employeeId)) {
                                                        _selectedEmployees
                                                            .remove(
                                                                log.employeeId);
                                                      }
                                                      _draftReady = false;
                                                    }))),
                                            DataCell(Text(empName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                            DataCell(Text(checkInStr)),
                                            DataCell(Text(checkOutStr)),
                                            DataCell(
                                                _buildStatusChip(log.status)),
                                            DataCell(_buildViolations(log)),
                                            DataCell(PopupMenuButton<String>(
                                              tooltip: 'Kelola log',
                                              onSelected: (action) {
                                                if (action == 'detail') {
                                                  context.push(
                                                      '/admin/attendance/detail',
                                                      extra: log.id);
                                                }
                                                if (action == 'edit') {
                                                  _editLog(log);
                                                }
                                                if (action == 'delete') {
                                                  _deleteLog(log);
                                                }
                                              },
                                              itemBuilder: (_) => const [
                                                PopupMenuItem(
                                                    value: 'detail',
                                                    child: ListTile(
                                                        leading: Icon(Icons
                                                            .visibility_outlined),
                                                        title: Text(
                                                            'Lihat detail'))),
                                                PopupMenuItem(
                                                    value: 'edit',
                                                    child: ListTile(
                                                        leading: Icon(Icons
                                                            .edit_outlined),
                                                        title: Text(
                                                            'Edit manual'))),
                                                PopupMenuItem(
                                                    value: 'delete',
                                                    child: ListTile(
                                                        leading: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: AppColors
                                                                .errorCrimson),
                                                        title:
                                                            Text('Hapus log'))),
                                              ],
                                            )),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ))
                    ]),
    );
  }

  Widget _buildMobileLogList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _logs.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final log = _logs[index];
        final isAbsent = log.status == 'absent';
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Checkbox(
                  value: _selectedEmployees.contains(log.employeeId),
                  onChanged: (_) => setState(() {
                    if (!_selectedEmployees.add(log.employeeId)) {
                      _selectedEmployees.remove(log.employeeId);
                    }
                    _draftReady = false;
                  }),
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.employeeName ?? 'Karyawan #${log.employeeId}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                .format(log.checkInAt),
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12.sp)),
                      ]),
                ),
                _buildLogActions(log),
              ]),
              SizedBox(height: 8.h),
              Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                _buildStatusChip(log.status),
                _timeBadge(
                    Icons.login,
                    isAbsent
                        ? '--:--'
                        : DateFormat('HH:mm').format(log.checkInAt)),
                _timeBadge(
                    Icons.logout,
                    log.checkOutAt == null
                        ? '--:--'
                        : DateFormat('HH:mm').format(log.checkOutAt!)),
              ]),
              if (log.flags?.values.any((value) => value == true) == true) ...[
                SizedBox(height: 10.h),
                _buildViolations(log),
              ],
            ]),
          ),
        );
      },
    );
  }

  Widget _timeBadge(IconData icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15),
        SizedBox(width: 5.w),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600))
      ]),
    );
  }

  Widget _buildLogActions(AttendanceLogModel log) {
    return PopupMenuButton<String>(
      tooltip: 'Kelola log',
      onSelected: (action) {
        if (action == 'detail') {
          context.push('/admin/attendance/detail', extra: log.id);
        }
        if (action == 'edit') _editLog(log);
        if (action == 'delete') _deleteLog(log);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'detail', child: Text('Lihat detail')),
        PopupMenuItem(value: 'edit', child: Text('Edit manual')),
        PopupMenuItem(value: 'delete', child: Text('Hapus log')),
      ],
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
