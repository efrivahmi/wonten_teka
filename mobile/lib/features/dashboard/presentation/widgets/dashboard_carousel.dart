import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../../../../core/theme/app_colors.dart';

class DashboardCarousel extends StatefulWidget {
  const DashboardCarousel({super.key});

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Selamat Datang di Wonten Teka',
      'desc': 'Sistem presensi cerdas, cepat, dan aman.',
      'icon': Icons.stars,
      'color': AppColors.primary,
      'gradient': [AppColors.primary, const Color(0xFF6A1B9A)],
    },
    {
      'title': 'Check-in Wajah',
      'desc': 'Gunakan fitur face recognition untuk absensi instan di lokasi Anda.',
      'icon': Icons.face,
      'color': AppColors.infoCerulean,
      'gradient': [AppColors.infoCerulean, const Color(0xFF0277BD)],
    },
    {
      'title': 'Pantau Kehadiran',
      'desc': 'Lihat riwayat dan grafik persentase kehadiran dengan mudah.',
      'icon': Icons.analytics,
      'color': AppColors.warningAmber,
      'gradient': [AppColors.warningAmber, const Color(0xFFF57F17)],
    },
    {
      'title': 'Pengajuan Instan',
      'desc': 'Ajukan cuti, lembur, dan klaim pengeluaran langsung dari HP.',
      'icon': Icons.assignment,
      'color': AppColors.successEmerald,
      'gradient': [AppColors.successEmerald, const Color(0xFF2E7D32)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _items.length) {
          nextPage = 0;
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
        } else {
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 140.h,
                      width: Curves.easeOut.transform(value) * MediaQuery.of(context).size.width,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: LinearGradient(
                      colors: item['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (item['color'] as Color).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20.w,
                        bottom: -20.h,
                        child: Icon(
                          item['icon'] as IconData,
                          size: 100.w,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(item['icon'] as IconData, color: Colors.white, size: 24.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 6.h,
              width: _currentPage == index ? 24.w : 6.w,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
