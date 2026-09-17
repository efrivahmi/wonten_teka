import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class PayrollConfigurationScreen extends StatelessWidget {
  const PayrollConfigurationScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur sedang dikembangkan')),
    );
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
          title: const AppBrandTitle(section: 'Konfigurasi Payroll'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showComingSoon(context),
          
          child: const Icon(Icons.save, color: AppColors.onPrimary)),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Section(title: 'Komponen Pendapatan', children: [
              _ConfigItem(label: 'Gaji Pokok', type: 'Tetap', isActive: true, onToggle: () => _showComingSoon(context)),
              _ConfigItem(
                  label: 'Tunjangan Makan',
                  type: 'Harian (Berdasarkan Kehadiran)',
                  isActive: true, onToggle: () => _showComingSoon(context)),
              _ConfigItem(
                  label: 'Tunjangan Transport',
                  type: 'Harian (Berdasarkan Kehadiran)',
                  isActive: true, onToggle: () => _showComingSoon(context)),
              _ConfigItem(label: 'Lembur', type: 'Per Jam', isActive: true, onToggle: () => _showComingSoon(context)),
            ]),
            SizedBox(height: 24.h),
            _Section(title: 'Komponen Potongan', children: [
              _ConfigItem(
                  label: 'PPh 21 (TER)',
                  type: 'Persentase Pajak',
                  isActive: true, onToggle: () => _showComingSoon(context)),
              _ConfigItem(label: 'BPJS Kesehatan', type: '1%', isActive: true, onToggle: () => _showComingSoon(context)),
              _ConfigItem(
                  label: 'BPJS Ketenagakerjaan (JHT)',
                  type: '2%',
                  isActive: true, onToggle: () => _showComingSoon(context)),
              _ConfigItem(
                  label: 'Potongan Terlambat',
                  type: 'Per Menit/Jam',
                  isActive: false, onToggle: () => _showComingSoon(context)),
            ]),
            SizedBox(height: 24.h),
            _Section(title: 'Jadwal Cut-off', children: [
              ListTile(
                  title:
                      const Text('Periode Kehadiran', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Tanggal 21 - 20 bulan berikutnya',
                      style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showComingSoon(context)),
              ListTile(
                  title: const Text('Tanggal Pembayaran',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Tanggal 25', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showComingSoon(context)),
            ]),
          ])),
    ));
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        InfoCard(
            child: Column(
                children: children
                    .expand((c) => [
                          c,
                          if (c != children.last)
                            Divider(
                                height: 1,
                                color: AppColors.outlineVariant
                                    .withValues(alpha: 0.3))
                        ])
                    .toList())),
      ]);
}

class _ConfigItem extends StatelessWidget {
  final String label, type;
  final bool isActive;
  final VoidCallback onToggle;
  const _ConfigItem(
      {required this.label, required this.type, required this.isActive, required this.onToggle});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp)),
          Text(type,
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
        ])),
        Switch(
            value: isActive,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppColors.primaryContainer),
      ]));
}

