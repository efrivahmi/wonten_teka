import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyDirectoryScreen extends StatefulWidget {
  const CompanyDirectoryScreen({super.key});

  @override
  State<CompanyDirectoryScreen> createState() => _CompanyDirectoryScreenState();
}

class _CompanyDirectoryScreenState extends State<CompanyDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    try {
      final employees = await context.read<AuthRepository>().getEmployeeDirectory();
      if (!mounted) return;
      setState(() { _employees = employees; _filteredEmployees = employees; _loading = false; _error = null; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Direktori gagal dimuat.'; });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        return (employee['full_name']?.toString().toLowerCase().contains(query) ?? false) ||
               (employee['department']?.toString().toLowerCase().contains(query) ?? false) ||
               (employee['position']?.toString().toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Direktori Karyawan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau departemen...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final emp = _filteredEmployees[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InfoCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            (emp['full_name']?.toString().isNotEmpty ?? false) ? emp['full_name'].toString()[0] : '?',
                            style: TextStyle(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(emp['full_name']?.toString() ?? 'Karyawan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              Text('${emp['position'] ?? 'Belum ada jabatan'} • ${emp['department'] ?? 'Belum ada departemen'}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emp['phone']?.toString().isNotEmpty == true ? 'Nomor: ${emp['phone']}' : 'Nomor telepon belum tersedia.')));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

