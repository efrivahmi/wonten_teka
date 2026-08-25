import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class CompanyDirectoryScreen extends StatefulWidget {
  const CompanyDirectoryScreen({super.key});

  @override
  State<CompanyDirectoryScreen> createState() => _CompanyDirectoryScreenState();
}

class _CompanyDirectoryScreenState extends State<CompanyDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _employees = [
    {'name': 'Ahmad Budi', 'department': 'Software Engineering', 'role': 'Senior Developer', 'phone': '081234567890'},
    {'name': 'Siti Aminah', 'department': 'Human Resources', 'role': 'HR Manager', 'phone': '081234567891'},
    {'name': 'Joko Susanto', 'department': 'Infrastructure', 'role': 'DevOps Engineer', 'phone': '081234567892'},
    {'name': 'Rina Wati', 'department': 'Finance', 'role': 'Accountant', 'phone': '081234567893'},
    {'name': 'Bambang Pamungkas', 'department': 'Software Engineering', 'role': 'Mobile Developer', 'phone': '081234567894'},
  ];

  List<Map<String, String>> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = _employees;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        return employee['name']!.toLowerCase().contains(query) ||
               employee['department']!.toLowerCase().contains(query);
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
            child: ListView.builder(
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
                            emp['name']![0],
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
                              Text(emp['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              Text('${emp['role']} â€¢ ${emp['department']}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memanggil ${emp['phone']}...')));
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

