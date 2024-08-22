import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension TimestampOnDateTime on DateTime {
  Timestamp toTimestamp() {
    return Timestamp.fromDate(this);
  }

  String dateFormatter(String? format) {
    return DateFormat(format).format(this);
  }
  
  String calculateAge({DateTime? when}) {
    final today = when ?? DateTime.now();
    Duration age = today.difference(this);

    if (age.compareTo(const Duration(days: 365)) >= 0) {
      return '${(age.inDays / 365).floor()} years';
    } else if (age.compareTo(const Duration(days: 7)) >= 0) {
      return '${(age.inDays / 7).floor()} weeks';
    } else if (age.compareTo(const Duration(hours: 24)) >= 0) {
      return '${age.inDays} days';
    } else {
      return '${age.inHours} hours';
    }
  }
}
