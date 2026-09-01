import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/repositories/device_admin_repository.dart';

class DeviceApprovalAdminScreen extends StatefulWidget {
  const DeviceApprovalAdminScreen({super.key});

  @override
  State<DeviceApprovalAdminScreen> createState() =>
      _DeviceApprovalAdminScreenState();
}

class _DeviceApprovalAdminScreenState extends State<DeviceApprovalAdminScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingDevices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<DeviceAdminRepository>();
      final devices = await repo.getPendingDevices();
      if (mounted) {
        setState(() {
          _pendingDevices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading devices: $e')),
        );
      }
    }
  }

  Future<void> _reviewDevice(int deviceId, String action) async {
    try {
      final repo = context.read<DeviceAdminRepository>();
      await repo.reviewDevice(deviceId, action);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'approve'
                ? 'Perangkat disetujui'
                : 'Perangkat ditolak'),
            backgroundColor: action == 'approve'
                ? AppColors.successEmerald
                : AppColors.errorCrimson,
          ),
        );
        _loadDevices(); // Reload list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
          'Persetujuan Perangkat',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingDevices.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDevices,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _pendingDevices.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final device = _pendingDevices[index];
                      return _buildDeviceCard(device);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64.w, color: AppColors.outline),
          SizedBox(height: 16.h),
          Text(
            'Tidak ada pengajuan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Semua perangkat karyawan telah di-review',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final employee = device['employee'] ?? {};
    final name = '${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}'
        .trim();
    final deviceName = device['device_name'] ?? 'Unknown Device';
    final deviceModel = device['device_model'] ?? '-';
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown Employee',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      employee['email'] ?? '',
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android,
                    color: AppColors.primary, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deviceName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Model: $deviceModel',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reviewDevice(device['id'], 'reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorCrimson,
                    side: const BorderSide(color: AppColors.errorCrimson),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _reviewDevice(device['id'], 'approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successEmerald,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Setujui'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

