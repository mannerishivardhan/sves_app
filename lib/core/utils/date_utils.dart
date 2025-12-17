import 'package:intl/intl.dart';

/// Date utility functions
class DateHelper {
  DateHelper._();

  /// Format date to 'MMM dd, yyyy' (e.g., 'Jan 15, 2024')
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date to 'dd/MM/yyyy' (e.g., '15/01/2024')
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date with time (e.g., 'Jan 15, 2024 at 10:30 AM')
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(dateTime);
  }

  /// Format time only (e.g., '10:30 AM')
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Format date for display in lists (e.g., 'Today', 'Yesterday', or 'Jan 15')
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.year == date.year) {
      return DateFormat('MMM dd').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Get month-year string for grouping (e.g., '2024-01')
  static String getMonthYearKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  /// Calculate number of days between two dates (inclusive)
  static int calculateDaysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays + 1;
  }

  /// Check if a date is in the future
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isAfter(today);
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get current year
  static int getCurrentYear() {
    return DateTime.now().year;
  }

  /// Get first day of current year
  static DateTime getYearStart([int? year]) {
    final targetYear = year ?? DateTime.now().year;
    return DateTime(targetYear, 1, 1);
  }

  /// Get last day of current year
  static DateTime getYearEnd([int? year]) {
    final targetYear = year ?? DateTime.now().year;
    return DateTime(targetYear, 12, 31, 23, 59, 59);
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
