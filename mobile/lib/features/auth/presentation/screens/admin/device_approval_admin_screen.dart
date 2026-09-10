import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/repositories/device_admin_repository.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/error_state_widget.dart';
import '../../../../../core/widgets/info_card.dart';

class DeviceApprovalAdminScreen extends StatefulWidget {
  const DeviceApprovalAdminScreen({super.key});

  @override
  State<DeviceApprovalAdminScreen> createState() =>
      _DeviceApprovalAdminScreenState();
}

class _DeviceApprovalAdminScreenState extends State<DeviceApprovalAdminScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingDevices = [];
  List<Map<String, dynamic>> _activeDevices = [];
  String? _error;
  int? _reviewingDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<DeviceAdminRepository>();
      final pending = await repo.getPendingDevices();
      final active = await repo.getActiveDevices();
      if (mounted) {
        setState(() {
          _pendingDevices = pending;
          _activeDevices = active;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error =
              'Pengajuan belum dapat dimuat. Periksa koneksi lalu coba lagi.';
        });
      }
    }
  }

  Future<void> _reviewDevice(int deviceId, String action) async {
    if (_reviewingDeviceId != null) return;
    setState(() => _reviewingDeviceId = deviceId);
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
        await _loadDevices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keputusan belum tersimpan. Silakan coba kembali.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reviewingDeviceId = null);
    }
  }

  Future<void> _revokeDevice(int deviceId) async {
    if (_reviewingDeviceId != null) return;
    setState(() => _reviewingDeviceId = deviceId);
    try {
      final repo = context.read<DeviceAdminRepository>();
      await repo.revokeDevice(deviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses perangkat dicabut'),
            backgroundColor: AppColors.errorCrimson,
          ),
        );
        await _loadDevices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mencabut akses. Silakan coba kembali.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reviewingDeviceId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Kelola Perangkat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Aktif'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ErrorStateWidget(message: _error!, onRetry: _loadDevices)
                : TabBarView(
                    children: [
                      _buildList(_pendingDevices, isPending: true),
                      _buildList(_activeDevices, isPending: false),
                    ],
                  ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> devices, {required bool isPending}) {
    if (devices.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.verified_user_outlined,
        title: isPending ? 'Antrean kosong' : 'Tidak ada perangkat aktif',
        message: isPending
            ? 'Belum ada perangkat yang menunggu persetujuan.'
            : 'Belum ada perangkat yang diberikan akses.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: devices.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final device = devices[index];
          return _buildDeviceCard(device, isPending: isPending);
        },
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device, {required bool isPending}) {
    final employee = device['employee'] ?? {};
    final name = (employee['full_name'] ??
            '${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}')
        .toString()
        .trim();
    final deviceName = device['device_name'] ?? 'Unknown Device';
    final deviceModel = device['device_model'] ?? '-';
    final deviceOs = device['os_version'] ?? '-';
    
    // Format tanggal
    String dateStr = device['created_at'] ?? '';
    if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);

    return InfoCard(
      padding: EdgeInsets.all(16.w),
      semanticLabel: 'Pengajuan perangkat $name',
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
                    if ((employee['department'] ?? '').toString().isNotEmpty)
                      Text(
                        employee['department'].toString(),
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.onSurfaceVariant),
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
                Icon(Icons.phone_android, color: AppColors.primary, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deviceName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Model: $deviceModel • OS: $deviceOs',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.onSurfaceVariant)),
                      Text('Diajukan: $dateStr',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reviewingDeviceId == null
                        ? () => _reviewDevice(device['id'], 'reject')
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorCrimson,
                      side: const BorderSide(color: AppColors.errorCrimson),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: _reviewingDeviceId == null
                        ? () => _reviewDevice(device['id'], 'approve')
                        : null,
                    child: _reviewingDeviceId == device['id']
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Setujui'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reviewingDeviceId == null
                    ? () => _revokeDevice(device['id'])
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorCrimson,
                  side: const BorderSide(color: AppColors.errorCrimson),
                ),
                icon: const Icon(Icons.block, size: 18),
                label: _reviewingDeviceId == device['id']
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cabut Akses'),
              ),
            ),
        ],
      ),
    );
  }
}
