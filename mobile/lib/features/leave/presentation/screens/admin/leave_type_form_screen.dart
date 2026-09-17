import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/leave_models.dart';
import '../../../bloc/leave_cubit.dart';

class LeaveTypeFormScreen extends StatefulWidget {
  final LeaveTypeModel? leaveType;
  const LeaveTypeFormScreen({super.key, this.leaveType});

  @override
  State<LeaveTypeFormScreen> createState() => _LeaveTypeFormScreenState();
}

class _LeaveTypeFormScreenState extends State<LeaveTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _daysController;
  bool _isPaid = true;
  bool _isActive = true;
  bool _requiresAttachment = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.leaveType?.name ?? '');
    _codeController = TextEditingController(text: widget.leaveType?.code ?? '');
    _daysController = TextEditingController(
        text: widget.leaveType?.quotaPerMonth?.toString() ?? '');

    if (widget.leaveType != null) {
      _isPaid = widget.leaveType!.isPaid;
      _isActive = widget.leaveType!.isActive;
      _requiresAttachment = widget.leaveType!.requiresAttachment;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'code': _codeController.text,
        'quota_per_month': int.tryParse(_daysController.text),
        'is_paid': _isPaid,
        'is_active': _isActive,
        'requires_attachment': _requiresAttachment,
      };

      try {
        if (widget.leaveType == null) {
          await context.read<LeaveCubit>().createLeaveType(data);
        } else {
          await context
              .read<LeaveCubit>()
              .updateLeaveType(widget.leaveType!.id, data);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Berhasil disimpan'),
              backgroundColor: AppColors.successEmerald));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal: $e'),
              backgroundColor: AppColors.errorCrimson));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Wonten Teka'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nama Tipe Cuti', border: OutlineInputBorder()),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                    labelText: 'Kode Cuti (Contoh: CUTI_THN)',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(
                    labelText: 'Kuota cuti per bulan',
                    helperText:
                        'Kuota dihitung ulang otomatis setiap awal bulan.',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final days = int.tryParse(val ?? '');
                  if (days == null) {
                    return 'Masukkan jumlah hari';
                  }
                  if (days < 0 || days > 31) {
                    return 'Jumlah hari harus 0 sampai 31';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: const Text('Cuti Dibayar (Paid Leave)'),
                value: _isPaid,
                onChanged: (val) => setState(() => _isPaid = val),
              ),
              SwitchListTile(
                title: const Text('Wajib Melampirkan Bukti (Attachment)'),
                value: _requiresAttachment,
                onChanged: (val) => setState(() => _requiresAttachment = val),
              ),
              SwitchListTile(
                title: const Text('Aktif'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      
                      foregroundColor: Colors.white),
                  child: const Text('Simpan Tipe Cuti'),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
