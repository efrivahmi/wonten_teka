String formatShiftTime(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  final parts = value.trim().split(':');
  if (parts.length < 2) return value;
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}
