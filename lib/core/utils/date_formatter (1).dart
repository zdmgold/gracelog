import 'package:intl/intl.dart';

/// Centralized date formatting utility.
/// All date display logic routes through here.
class DateFormatter {
  const DateFormatter._();

  /// Formats a DateTime to a locale-aware string.
  /// Pattern examples: 'MMM d, y', 'EEEE, MMM d', 'y-MM-dd'
  static String formatDate(
    DateTime date, {
    String pattern = 'MMM d, y',
    String? locale,
  }) {
    final effectiveLocale = locale ?? Intl.defaultLocale ?? 'en';
    return DateFormat(pattern, effectiveLocale).format(date);
  }

  /// Formats a DateTime to a relative string.
  /// Returns: "Today", "Yesterday", or "X days ago"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    return switch (difference) {
      0 => 'Today',
      1 => 'Yesterday',
      < 7 => '$difference days ago',
      < 30 => '${(difference / 7).floor()} weeks ago',
      < 365 => '${(difference / 30).floor()} months ago',
      _ => '${(difference / 365).floor()} years ago',
    };
  }

  /// Checks if two DateTimes represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns the start (Monday) and end (Sunday) of the week containing [date].
  static ({DateTime start, DateTime end}) getWeekRange(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final start = DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 6));
    return (start: start, end: end);
  }

  /// Returns the month name for a given month number (1-12).
  static String getMonthName(int month, {String? locale}) {
    assert(month >= 1 && month <= 12, 'Month must be between 1 and 12');
    final effectiveLocale = locale ?? Intl.defaultLocale ?? 'en';
    final date = DateTime(2024, month, 1);
    return DateFormat.MMMM(effectiveLocale).format(date);
  }

  /// Formats a DateTime to ISO 8601 for database storage.
  static String toIso8601(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  /// Parses an ISO 8601 string from database storage.
  static DateTime fromIso8601(String isoString) {
    return DateTime.parse(isoString).toLocal();
  }

  /// Returns the start of the day (00:00:00.000).
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of the day (23:59:59.999).
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
