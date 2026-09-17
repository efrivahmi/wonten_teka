import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/claim_models.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class ClaimDetailScreen extends StatelessWidget {
  final ClaimModel claim;
  const ClaimDetailScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Detail klaim'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text(claim.claimCategory?.name ?? 'Klaim', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 8.h),
          Text(claim.status.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          SizedBox(height: 24.h),
          InfoCard(child: Column(children: [
            _row('Jumlah', money.format(claim.amount)),
            const Divider(),
            _row('Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(claim.expenseDate)),
          ])),
          SizedBox(height: 20.h),
          Text('Keterangan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 8.h),
          InfoCard(child: Text(claim.description.isEmpty ? 'Tidak ada keterangan.' : claim.description)),
          if (claim.receiptUrl != null) ...[
            SizedBox(height: 20.h),
            Text('Bukti pengeluaran', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(claim.receiptUrl!, errorBuilder: (_, __, ___) => const InfoCard(child: Text('Bukti tidak dapat dimuat.'))),
            ),
          ],
        ],
      ),
    ));
  }

  Widget _row(String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
  );
}
