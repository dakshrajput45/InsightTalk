import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DsdDobValidator {
  String? dobValidator(String? value, DateTime? dateOfBirth) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    if (dateOfBirth != null) {
      DateTime now = DateTime.now();
      if (dateOfBirth.isAfter(DateTime(now.year, now.month, now.day))) {
        return 'Date of birth cannot be in the future';
      }
      if (dateOfBirth == DateTime(now.year, now.month, now.day)) {
        return 'Date of birth cannot be today';
      }
    }
    return null;
  }

  Future<DateTime?> selectDOB(
      BuildContext context, DateTime dateOfBirth) async {
    final DateTime? selectedDOB = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialEntryMode:
          kIsWeb ? DatePickerEntryMode.input : DatePickerEntryMode.calendar,
      currentDate: dateOfBirth,
    );
    return selectedDOB;
  }
}
