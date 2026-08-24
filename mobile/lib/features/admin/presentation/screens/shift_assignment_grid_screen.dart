import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class ShiftAssignmentGridScreen extends StatelessWidget {
  const ShiftAssignmentGridScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Assign Shift', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: Column(children: [
        Container(color: AppColors.surface, padding: EdgeInsets.all(16.w), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
          Text('Minggu 14 - 20 Jul 2025', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
        ])),
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: DataTable(
          columns: [
            const DataColumn(label: Text('Karyawan')),
            ...['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].map((d) => DataColumn(label: Text(d))),
          ],
          rows: List.generate(10, (i) => DataRow(cells: [
            DataCell(Text('Kar ${i+1}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ...List.generate(7, (j) {
              final color = j == 5 || j == 6 ? AppColors.surfaceContainerHigh : (j % 2 == 0 ? AppColors.successEmerald : AppColors.warningAmber);
              final text = j == 5 || j == 6 ? 'L' : (j % 2 == 0 ? 'P' : 'S');
              return DataCell(Container(
                margin: EdgeInsets.all(4.w), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4.r)),
                child: Center(child: Text(text, style: TextStyle(color: color == AppColors.surfaceContainerHigh ? AppColors.onSurfaceVariant : color, fontWeight: FontWeight.bold))),
              ), onTap: () {});
            }),
          ])),
        )))),
      ]),
    );
  }
}
