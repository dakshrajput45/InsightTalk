import 'package:cloud_firestore/cloud_firestore.dart';

class DsdExpertAvailability {
  String? expertId;
  Map<DateTime, List<AvailabilitySlot>>? availability;

  DsdExpertAvailability({
    required this.expertId,
    required this.availability});

  factory DsdExpertAvailability.fromJson({
    required Map<String, dynamic> json,
    required String id,
  }) {
    try {
      return DsdExpertAvailability(
        expertId: json['expertId'],
        availability: (json['availability'] as Map<String, dynamic>?)?.map(
          (dateStr, slots) {
            return MapEntry(
              DateTime.parse(dateStr),
              (slots as List<dynamic>).map((slotJson) {
                return AvailabilitySlot.fromJson(
                    slotJson as Map<String, dynamic>);
              }).toList(),
            );
          },
        ),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (availability != null)
        'availability': availability!.map((date, slots) {
          return MapEntry(
            date.toIso8601String(),
            slots.map((slot) => slot.toJson()).toList(),
          );
        }),
      if(expertId != null) 'expertId': expertId
    };
  }
}

class AvailabilitySlot {
  DateTime start;
  DateTime end;

  AvailabilitySlot({required this.start, required this.end});

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      start: (json['start'] as Timestamp).toDate(),
      end: (json['end'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
    };
  }
}
