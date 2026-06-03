import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String get hhmm => DateFormat.Hm().format(this);

  String dateSeparatorLabel({DateTime? now}) {
    final today = now ?? DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    if (isSameDayAs(today)) return 'Today';
    if (isSameDayAs(yesterday)) return 'Yesterday';
    return DateFormat('d MMM yyyy').format(this);
  }
}
