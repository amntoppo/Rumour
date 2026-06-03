import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/extensions/date_extensions.dart';

void main() {
  group('DateTimeX.isSameDayAs', () {
    test('returns true for identical DateTimes', () {
      final a = DateTime(2024, 6, 15, 10, 30);
      final b = DateTime(2024, 6, 15, 22, 59);
      expect(a.isSameDayAs(b), isTrue);
    });

    test('returns false when days differ', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2024, 6, 16);
      expect(a.isSameDayAs(b), isFalse);
    });

    test('returns false when months differ', () {
      final a = DateTime(2024, 5, 1);
      final b = DateTime(2024, 6, 1);
      expect(a.isSameDayAs(b), isFalse);
    });

    test('returns false when years differ', () {
      final a = DateTime(2023, 6, 15);
      final b = DateTime(2024, 6, 15);
      expect(a.isSameDayAs(b), isFalse);
    });
  });

  group('DateTimeX.hhmm', () {
    test('formats single-digit minutes with leading zero', () {
      final dt = DateTime(2024, 1, 1, 9, 5);
      expect(dt.hhmm, '09:05');
    });

    test('formats noon correctly', () {
      final dt = DateTime(2024, 1, 1, 12, 0);
      expect(dt.hhmm, '12:00');
    });

    test('formats midnight as 00:00', () {
      final dt = DateTime(2024, 1, 1, 0, 0);
      expect(dt.hhmm, '00:00');
    });

    test('formats 23:59 correctly', () {
      final dt = DateTime(2024, 1, 1, 23, 59);
      expect(dt.hhmm, '23:59');
    });
  });

  group('DateTimeX.dateSeparatorLabel', () {
    test('returns "Today" when date matches now', () {
      final today = DateTime(2024, 6, 15);
      final dt = DateTime(2024, 6, 15, 8, 0);
      expect(dt.dateSeparatorLabel(now: today), 'Today');
    });

    test('returns "Yesterday" for one day before today', () {
      final today = DateTime(2024, 6, 15);
      final dt = DateTime(2024, 6, 14, 8, 0);
      expect(dt.dateSeparatorLabel(now: today), 'Yesterday');
    });

    test('returns formatted date for older dates', () {
      final today = DateTime(2024, 6, 15);
      final dt = DateTime(2024, 1, 5, 8, 0);
      expect(dt.dateSeparatorLabel(now: today), '5 Jan 2024');
    });
  });
}
