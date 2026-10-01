import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/payslip_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../bloc/payslip_cubit.dart';

class PayslipListScreen extends StatefulWidget {
  const PayslipListScreen({super.key});

  @override
  State<PayslipListScreen> createState() => _PayslipListScreenState();
}

class _PayslipListScreenState extends State<PayslipListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PayslipCubit>().loadHistory();
    });
  }

  String _currency(num amount) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);

  String _status(PayslipModel slip) {
    return switch (slip.paymentStatus) {
      'collected' => 'Sudah diambil',
      'available' => 'Tersedia untuk diambil',
      _ => 'Belum diproses',
    };
  }

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Slip Gaji'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
          actions: [
            IconButton(
              tooltip: 'Muat ulang',
              onPressed: () => context.read<PayslipCubit>().loadHistory(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocBuilder<PayslipCubit, PayslipState>(
          builder: (context, state) {
            if (state is PayslipLoading || state is PayslipInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is PayslipError) {
              return _MessageState(
                icon: Icons.cloud_off_rounded,
                title: 'Slip belum dapat dimuat',
                message: state.message,
                action: FilledButton.icon(
                  onPressed: () => context.read<PayslipCubit>().loadHistory(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              );
            }
            if (state is! PayslipLoaded) return const SizedBox.shrink();
            if (state.payslips.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<PayslipCubit>().loadHistory(),
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(24.w),
                  children: [
                    SizedBox(height: 100.h),
                    const _MessageState(
                      icon: Icons.receipt_long_rounded,
                      title: 'Belum ada slip gaji',
                      message:
                          'Slip akan muncul di sini setelah payroll diproses dan diterbitkan oleh admin.',
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<PayslipCubit>()
                  .loadHistory(page: state.currentPage),
              color: AppColors.primary,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                itemCount: state.payslips.length + 2,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _SummaryHeader(
                      count: state.payslips.length,
                      page: state.currentPage,
                      totalPages: state.lastPage,
                    );
                  }
                  if (index == state.payslips.length + 1) {
                    return _PageControls(
                      page: state.currentPage,
                      totalPages: state.lastPage,
                      onPage: (page) =>
                          context.read<PayslipCubit>().loadHistory(page: page),
                    );
                  }
                  final slip = state.payslips[index - 1];
                  return InkWell(
                    borderRadius: BorderRadius.circular(22.r),
                    onTap: () =>
                        context.push('/app/payslip/detail', extra: slip),
                    child: Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .91),
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .06),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(Icons.receipt_long_rounded,
                                color: AppColors.primary, size: 23.w),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _period(slip),
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  _currency(slip.netSalary),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17.sp,
                                  ),
                                ),
                                SizedBox(height: 7.h),
                                Text(
                                  _status(slip),
                                  style: TextStyle(
                                    color: slip.paymentStatus == 'collected'
                                        ? AppColors.infoCerulean
                                        : slip.paymentStatus == 'available'
                                            ? AppColors.successEmerald
                                            : AppColors.onSurfaceVariant,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.onSurfaceVariant, size: 25.w),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _period(PayslipModel slip) {
    final run = slip.payrollRun;
    if (run != null && run.periodMonth > 0 && run.periodYear > 0) {
      return DateFormat('MMMM yyyy', 'id_ID')
          .format(DateTime(run.periodYear, run.periodMonth));
    }
    return slip.periodLabel;
  }
}

class _SummaryHeader extends StatelessWidget {
  final int count;
  final int page;
  final int totalPages;
  const _SummaryHeader(
      {required this.count, required this.page, required this.totalPages});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF087A4B), Color(0xFF16A56A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 28.w),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Riwayat penghasilan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4.h),
                  Text('$count slip pada halaman $page dari $totalPages',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: .85),
                          fontSize: 12.sp)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _PageControls extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPage;
  const _PageControls(
      {required this.page, required this.totalPages, required this.onPage});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            onPressed: page > 1 ? () => onPage(page - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text('$page / $totalPages',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          IconButton.filledTonal(
            onPressed: page < totalPages ? () => onPage(page + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      );
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const _MessageState(
      {required this.icon,
      required this.title,
      required this.message,
      this.action});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 54.w, color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 7.h),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 13.sp)),
              if (action != null) ...[SizedBox(height: 18.h), action!],
            ],
          ),
        ),
      );
}
