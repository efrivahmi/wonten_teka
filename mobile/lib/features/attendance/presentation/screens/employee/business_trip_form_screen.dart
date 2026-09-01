import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class BusinessTripFormScreen extends StatelessWidget {
  const BusinessTripFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => context.pop()),
                      Expanded(child: Text('Pengajuan Dinas Luar', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(color: AppColors.infoCerulean.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.infoCerulean, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(child: Text('Dinas luar akan dihitung sebagai kehadiran normal (tidak memotong kuota cuti tahunan).', style: TextStyle(fontSize: 12.sp, color: Colors.black87))),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mulai', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8.h),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Tanggal Mulai',
                                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                                        filled: true, fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Selesai', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8.h),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Tanggal Selesai',
                                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                                        filled: true, fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          
                          Text('Lokasi Tujuan', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Contoh: Kantor Cabang Jakarta',
                              prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                              filled: true, fillColor: Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Text('Keperluan Dinas', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          TextFormField(
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Jelaskan keperluan dinas luar secara detail',
                              filled: true, fillColor: Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: () => context.pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                elevation: 0,
                              ),
                              child: Text('Kirim Pengajuan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
