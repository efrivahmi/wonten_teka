import 'package:flutter/material.dart';

class AdminPaginationBar extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final int total;
  final ValueChanged<int> onPageChanged;

  const AdminPaginationBar({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (lastPage <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Halaman sebelumnya',
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$currentPage / $lastPage  •  $total data'),
          IconButton(
            tooltip: 'Halaman berikutnya',
            onPressed: currentPage < lastPage
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
