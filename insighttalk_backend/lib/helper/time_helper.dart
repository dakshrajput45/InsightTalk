class DsdDateTimeHelper {
  /// Converts a given DateTime to midnight of the same day.
  static DateTime toMidnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime toEndOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }

  static DateTime dateFromHour(int hour, int minutes, {DateTime? initDate}) {
    return toMidnight(initDate?.trim() ?? DateTime.now().trim()).copyWith(
      hour: hour,
      minute: minutes,
    );
  }
}

extension DateTimeExtensions on DateTime {
  /// Trims the time component of the DateTime object, setting the time to midnight (00:00:00).
  DateTime trim() {
    return DateTime(year, month, day);
  }
}
