import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '--';
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '--';
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  static String formatMonthYear(DateTime? date) {
    if (date == null) return '--';
    return DateFormat(AppConstants.monthYearFormat).format(date);
  }

  static String formatInputDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat(AppConstants.dateInputFormat).format(date);
  }

  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      try {
        return DateFormat(AppConstants.dateFormat).parse(value);
      } catch (_) {
        return null;
      }
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String todayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static int workingDaysInMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final weekday = DateTime(year, month, d).weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  static List<DateTime> daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => first.add(Duration(days: i)));
  }
}
