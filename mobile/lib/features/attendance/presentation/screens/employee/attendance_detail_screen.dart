import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/attendance_log_model.dart';
import '../../widgets/info_card.dart';
import '../../../../../core/api/api_client.dart'; // To get baseUrl or just hardcode

class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceLogModel log;
  const AttendanceDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    // Determine map location based on check_in_gps
    LatLng? checkInLocation;
    if (log.checkInGps != null && log.checkInGps!['latitude'] != null) {
      checkInLocation = LatLng(
        double.parse(log.checkInGps!['latitude'].toString()),
        double.parse(log.checkInGps!['longitude'].toString())
      );
    }

    String address = 'Lokasi GPS Tersimpan';
    if (log.flags != null && log.flags!['address'] != null) {
      address = log.flags!['address'];
    }

    // Backend base URL for images
    const String baseUrl = 'http://www.great-symbols-begin-freely.st.a.dcdg.xyz/storage/';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => context.pop()),
        title: Text('Detail Absensi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Status
            InfoCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE, d MMM yyyy', 'id_ID').format(log.checkInAt),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(log.flags?['shift_name'] ?? 'Shift Regular',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                      ]),
                  _buildStatusBadge(log.status),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Check-in / Check-out Times
            Row(children: [
              Expanded(
                  child: InfoCard(
                borderLeftColor: AppColors.successEmerald,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHECK-IN',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      SizedBox(height: 4.h),
                      Text(DateFormat('HH:mm').format(log.checkInAt),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold)),
                    ]),
              )),
              SizedBox(width: 12.w),
              Expanded(
                  child: InfoCard(
                borderLeftColor: AppColors.infoCerulean,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHECK-OUT',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      SizedBox(height: 4.h),
                      Text(log.checkOutAt != null ? DateFormat('HH:mm').format(log.checkOutAt!) : '--:--',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold)),
                    ]),
              )),
            ]),
            SizedBox(height: 16.h),

            // Working Hours
            InfoCard(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL JAM KERJA',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                          SizedBox(height: 4.h),
                          Text(_formatDuration(log.workDuration),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: AppColors.successEmerald,
                                      fontWeight: FontWeight.bold)),
                        ]),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                          color: AppColors.successEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Text('Normal',
                          style: TextStyle(
                              color: AppColors.successEmerald,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp)),
                    ),
                  ]),
            ),
            SizedBox(height: 24.h),

            // Real Flutter Map location
            Text('Lokasi Check-in',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: checkInLocation != null 
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: checkInLocation,
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none, // Make map static for detail view
                        )
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.wonten_teka',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: checkInLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 32.w, color: AppColors.onSurfaceVariant),
                          SizedBox(height: 8.h),
                          Text('Data lokasi tidak tersedia', style: TextStyle(color: AppColors.onSurfaceVariant))
                        ],
                      )
                    ),
              ),
            ),
            
            // Address Label
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8.r)),
                child: Row(children: [
                  Icon(Icons.location_on,
                      color: AppColors.primaryContainer, size: 16.w),
                  SizedBox(width: 8.w),
                  Expanded(
                      child: Text(
                          address,
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.onSurface))),
                ]),
              ),
            ),

            SizedBox(height: 24.h),

            // Face Verification
            Text('Foto & Verifikasi Wajah',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    child: Column(
                      children: [
                        Text('Masuk', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        if (log.checkInPhotoUrl != null && log.checkInPhotoUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              "\\", 
                              height: 120.h, 
                              width: double.infinity, 
                              fit: BoxFit.cover, 
                              errorBuilder: (_,__,___) => Container(
                                height: 120.h,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            )
                          )
                        else
                          Container(
                            height: 120.h,
                            color: Colors.grey[100],
                            child: Center(child: Icon(Icons.face, color: AppColors.onSurfaceVariant, size: 48.w)),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InfoCard(
                    child: Column(
                      children: [
                        Text('Keluar', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        if (log.checkOutPhotoUrl != null && log.checkOutPhotoUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              "\\", 
                              height: 120.h, 
                              width: double.infinity, 
                              fit: BoxFit.cover, 
                              errorBuilder: (_,__,___) => Container(
                                height: 120.h,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            )
                          )
                        else
                          Container(
                            height: 120.h,
                            color: Colors.grey[100],
                            child: Center(child: Icon(Icons.face, color: AppColors.onSurfaceVariant, size: 48.w)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Dispute Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/app/attendance/dispute'),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Ajukan Dispute'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warningAmber,
                  side: const BorderSide(color: AppColors.warningAmber),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '\j \m';
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'on_time':
      case 'present':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: AppColors.successEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r)),
          child: Text('Tepat Waktu',
              style: TextStyle(
                  color: AppColors.successEmerald,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp)),
        );
      case 'late':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: AppColors.errorCrimson.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r)),
          child: Text('Terlambat',
              style: TextStyle(
                  color: AppColors.errorCrimson,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp)),
        );
      case 'flagged':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r)),
          child: Text('Ditinjau',
              style: TextStyle(
                  color: AppColors.warningAmber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
