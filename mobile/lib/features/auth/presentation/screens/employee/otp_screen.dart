import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _otpCode = ['', '', '', ''];
  int _currentIndex = 0;

  void _onKeypadTap(String value) {
    if (value == 'backspace') {
      if (_currentIndex > 0) {
        setState(() {
          _currentIndex--;
          _otpCode[_currentIndex] = '';
        });
      }
    } else {
      if (_currentIndex < 4) {
        setState(() {
          _otpCode[_currentIndex] = value;
          _currentIndex++;
        });
      }
    }
  }

  void _verifyOtp() {
    if (_otpCode.join('').length == 4) {
      context.go('/device-binding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Wonten Teka',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 32.w,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Title
                    Text(
                      'Verify it\'s you',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    Text(
                      'We\'ve sent a 4-digit code to\n+62 812-3456-7890',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 56.w,
                          height: 64.h,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: index == _currentIndex
                                  ? AppColors.primaryContainer
                                  : AppColors.outlineVariant,
                              width: index == _currentIndex ? 2 : 1,
                            ),
                            boxShadow: index == _currentIndex
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryContainer
                                          .withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _otpCode[index],
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 48.h),

                    // Timer & Resend
                    Text(
                      'Resend code in 00:42',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: null, // Disabled state
                      child: Text(
                        'Resend OTP',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Keypad
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 16.h,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        if (index == 9)
                          return const SizedBox.shrink(); // Empty bottom-left

                        if (index == 11) {
                          // Backspace
                          return InkWell(
                            onTap: () => _onKeypadTap('backspace'),
                            borderRadius: BorderRadius.circular(28.r),
                            child: const Center(
                              child: Icon(Icons.backspace_outlined,
                                  color: AppColors.onSurfaceVariant),
                            ),
                          );
                        }

                        // Numbers 1-9, and 0
                        final number = index == 10 ? '0' : '${index + 1}';
                        return InkWell(
                          onTap: () => _onKeypadTap(number),
                          borderRadius: BorderRadius.circular(28.r),
                          child: Center(
                            child: Text(
                              number,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Verify Button
                  Padding(
                    padding:
                        EdgeInsets.only(left: 24.w, right: 24.w, bottom: 32.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed:
                            _otpCode.join('').length == 4 ? _verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          disabledBackgroundColor:
                              AppColors.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Verify',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _otpCode.join('').length == 4
                                        ? AppColors.onPrimaryContainer
                                        : AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

