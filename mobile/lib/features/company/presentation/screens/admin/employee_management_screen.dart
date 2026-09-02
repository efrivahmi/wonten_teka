import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/api/api_client.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final api = context.read<ApiClient>();
      final response = await api.get('/admin/employees');
      final data = response.data;

      if (data is Map && data['data'] is List) {
        setState(() {
          _employees = List<Map<String, dynamic>>.from(data['data']);
          _filteredEmployees = _employees;
          _isLoading = false;
        });
      } else {
        setState(() {
          _employees = [];
          _filteredEmployees = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _employees = [];
        _filteredEmployees = [];
      });
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((emp) {
          final name = (emp['full_name'] ?? '').toString().toLowerCase();
          final dept = (emp['department'] ?? '').toString().toLowerCase();
          final pos = (emp['position'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              dept.contains(query.toLowerCase()) ||
              pos.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Karyawan', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              ListTile(
                title: const Text('Semua'),
                onTap: () {
                  setState(() => _filteredEmployees = _employees);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Aktif'),
                onTap: () {
                  setState(() => _filteredEmployees = _employees.where((e) => e['is_active'] == true || e['is_active'] == 1).toList());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Nonaktif'),
                onTap: () {
                  setState(() => _filteredEmployees = _employees.where((e) => e['is_active'] == false || e['is_active'] == 0).toList());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/app/admin/employees/new');
          if (!mounted) return;
          _loadEmployees();
        },
        backgroundColor: AppColors.errorCrimson,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.errorCrimson.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.r), bottomRight: Radius.circular(32.r)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
                      Expanded(child: Text('Daftar Karyawan', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: TextEditingController(text: _searchQuery),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau NIK...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.primary),
                          onPressed: _showFilterDialog,
                        ),
                      ),
                      onChanged: (value) {
                        _filterEmployees(value);
                      },
                    ),
                  ),
                ),
                
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          itemCount: 5,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (_, __) => Container(height: 80.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r))),
                        );
                      } else {
                        final employees = _filteredEmployees;
                        if (employees.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(24.w),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
                                  child: Icon(Icons.group_off, size: 64.w, color: AppColors.errorCrimson),
                                ),
                                SizedBox(height: 24.h),
                                Text('Tidak ada karyawan', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _loadEmployees,
                          color: AppColors.errorCrimson,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            itemCount: employees.length,
                            separatorBuilder: (_, __) => SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final item = employees[index];
                              return GestureDetector(
                                onTap: () => context.push('/app/admin/employees/${item['id']}'),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50.w,
                                        height: 50.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          shape: BoxShape.circle,
                                          image: item['photo_url'] != null
                                              ? DecorationImage(image: NetworkImage(item['photo_url']), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: item['photo_url'] == null
                                            ? Icon(Icons.person, color: AppColors.primary, size: 24.w)
                                            : null,
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['full_name'] ?? 'No Name',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              item['position']?.toString() ?? 'No Position',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: (item['is_active'] == true) ? AppColors.successEmerald.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          (item['is_active'] == true) ? 'Aktif' : 'Non-aktif',
                                          style: TextStyle(color: (item['is_active'] == true) ? AppColors.successEmerald : AppColors.error, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
