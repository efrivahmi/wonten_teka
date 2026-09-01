import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/models/company_models.dart';

class EventEditAdminScreen extends StatefulWidget {
  final CalendarEventModel? event;

  const EventEditAdminScreen({super.key, this.event});

  @override
  State<EventEditAdminScreen> createState() => _EventEditAdminScreenState();
}

class _EventEditAdminScreenState extends State<EventEditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ApiClient _api;

  late TextEditingController _titleController;
  late TextEditingController _descController;

  DateTime? _startDate;
  DateTime? _endDate;
  String _eventType = 'event';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController =
        TextEditingController(text: widget.event?.description ?? '');
    _eventType = widget.event?.type ?? 'event';
    if (_eventType != 'holiday' && _eventType != 'event') {
      _eventType = 'event'; // default to event if meeting/deadline
    }
    _startDate = widget.event?.startDate;
    _endDate = widget.event?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tanggal mulai harus dipilih'),
          backgroundColor: AppColors.errorCrimson));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text,
        'description': _descController.text,
        'type': _eventType,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
        'end_date': _endDate != null
            ? DateFormat('yyyy-MM-dd').format(_endDate!)
            : DateFormat('yyyy-MM-dd').format(_startDate!),
      };

      if (widget.event == null) {
        await _api.post('/admin/events', data: data);
      } else {
        await _api.put('/admin/events/${widget.event!.id}', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.event == null
                ? 'Event berhasil dibuat'
                : 'Event berhasil diperbarui'),
            backgroundColor: AppColors.successEmerald));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gagal menyimpan event'),
            backgroundColor: AppColors.errorCrimson));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text(isEditing ? 'Edit Event' : 'Buat Event',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipe Event',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: _eventType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'event', child: Text('Event / Agenda')),
                        DropdownMenuItem(
                            value: 'holiday', child: Text('Libur Nasional')),
                      ],
                      onChanged: (v) => setState(() => _eventType = v!),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Event',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Mulai',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none),
                              ),
                              child: Text(_startDate == null
                                  ? 'Pilih'
                                  : DateFormat('dd MMM yyyy')
                                      .format(_startDate!)),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Selesai',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none),
                              ),
                              child: Text(_endDate == null
                                  ? 'Opsional'
                                  : DateFormat('dd MMM yyyy')
                                      .format(_endDate!)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: const Text('Simpan',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

