import 'package:flutter_test/flutter_test.dart';
import 'package:wonten_teka_mobile/features/schedule/presentation/shift_time_formatter.dart';

void main() {
  group('formatShiftTime', () {
    test('accepts API time without seconds', () {
      expect(formatShiftTime('08:00'), '08:00');
    });

    test('removes seconds from API time', () {
      expect(formatShiftTime('16:00:00'), '16:00');
    });

    test('handles missing time safely', () {
      expect(formatShiftTime(null), '-');
      expect(formatShiftTime(''), '-');
    });
  });
}
