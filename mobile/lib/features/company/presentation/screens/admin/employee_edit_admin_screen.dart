import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/api/api_client.dart';

class EmployeeEditAdminScreen extends StatefulWidget {
  final Map<String, dynamic> employee;
  const EmployeeEditAdminScreen({super.key, required this.employee});

  @override
  State<EmployeeEditAdminScreen> createState() =>
      _EmployeeEditAdminScreenState();
}

class _EmployeeEditAdminScreenState extends State<EmployeeEditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController(); // optional for edit
  late TextEditingController _phoneController;
  late TextEditingController _employeeNumberController;

  late String _selectedDepartment;
  late String _selectedPosition;
  late String _selectedRole;
  bool _isActive = true;
  bool _isSubmitting = false;

  final _departments = [
    'Engineering',
    'Human Resources',
    'Marketing',
    'Sales',
    'Finance',
    'Management',
    'Operations'
  ];
  final _positions = [
    'Staff',
    'Senior Staff',
    'Lead',
    'Manager',
    'Director',
    'VP',
    'CEO',
    'CTO'
  ];
  final _roles = [
    {'value': 'employee', 'label': 'Karyawan'},
    {'value': 'supervisor', 'label': 'Supervisor / Manager'},
    {'value': 'hr_admin', 'label': 'HR Admin'},
    {'value': 'finance_admin', 'label': 'Finance Admin'},
    {'value': 'company_admin', 'label': 'Company Admin'},
  ];

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _nameController =
        TextEditingController(text: emp['full_name'] ?? emp['name'] ?? '');
    _emailController = TextEditingController(
        text: emp['email'] ?? emp['user']?['email'] ?? '');
    _phoneController = TextEditingController(text: emp['phone'] ?? '');
    _employeeNumberController =
        TextEditingController(text: emp['employee_number'] ?? '');

    _selectedDepartment = emp['department'] ?? 'Engineering';
    if (!_departments.contains(_selectedDepartment))
      _selectedDepartment = _departments.first;

    _selectedPosition = emp['position'] ?? 'Staff';
    if (!_positions.contains(_selectedPosition))
      _selectedPosition = _positions.first;

    _selectedRole = 'employee';

    _isActive = emp['is_active'] == true || emp['is_active'] == 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _employeeNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final api = context.read<ApiClient>();
      final empId = widget.employee['id'];

      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'employee_number': _employeeNumberController.text.trim(),
        'department': _selectedDepartment,
        'position': _selectedPosition,
        'role': _selectedRole,
        'is_active': _isActive,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      await api.put('/admin/employees/$empId', data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Karyawan ${_nameController.text} berhasil diperbarui!'),
            backgroundColor: AppColors.successEmerald,
          ),
        );
        // Pop and pass back true to signify refresh needed
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui karyawan: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          'Edit Karyawan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Section
              const _SectionLabel(label: 'Informasi Akun'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _passwordController,
                label: 'Password (Biarkan kosong jika tidak diubah)',
                icon: Icons.lock,
                obscureText: true,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6)
                    return 'Minimal 6 karakter';
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Employee Info
              const _SectionLabel(label: 'Informasi Karyawan'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _employeeNumberController,
                label: 'Nomor Karyawan (NIP)',
                icon: Icons.badge,
                validator: (v) =>
                    v == null || v.isEmpty ? 'NIP wajib diisi' : null,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _phoneController,
                label: 'No. Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: 'Department',
                icon: Icons.business,
                value: _selectedDepartment,
                items: _departments,
                onChanged: (v) => setState(() => _selectedDepartment = v!),
              ),
              SizedBox(height: 12.h),
              _buildDropdown(
                label: 'Posisi',
                icon: Icons.work,
                value: _selectedPosition,
                items: _positions,
                onChanged: (v) => setState(() => _selectedPosition = v!),
              ),
              SizedBox(height: 12.h),
              SwitchListTile(
                title: const Text('Status Aktif'),
                subtitle: const Text('Karyawan dapat login jika aktif'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
              ),
              SizedBox(height: 24.h),

              // Role
              const _SectionLabel(label: 'Hak Akses'),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: _roles.map((role) {
                    return RadioListTile<String>(
                      value: role['value']!,
                      groupValue: _selectedRole,
                      onChanged: (v) => setState(() => _selectedRole = v!),
                      title: Text(
                        role['label']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      activeColor: AppColors.primary,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 32.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

