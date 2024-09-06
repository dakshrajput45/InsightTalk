import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/modal_availablity.dart';

class DsdAvailablitySDK {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> removeOldAvailability(String expertId) async {
    try {
      // Reference to the expert's availability document
      final docRef = _db.collection('expertAvailablity').doc(expertId);

      // Fetch the current data
      final doc = await docRef.get();
      if (!doc.exists) {
        // No document found, so nothing to remove
        print('No document found for expert ID: $expertId');
        return;
      }

      final data = doc.data();
      if (data == null || !data.containsKey('availability')) {
        // No availability data found, so nothing to remove
        print('No availability data found for expert ID: $expertId');
        return;
      }

      final currentAvailability = data['availability'] as Map<String, dynamic>;
      final now = DateTime.now();

      // Create a new map with filtered availability
      final filteredAvailability = <String, dynamic>{};
      currentAvailability.forEach((dateStr, slots) {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(now)) {
          filteredAvailability[dateStr] = slots;
        }
      });

      // Update Firestore document with filtered availability
      await docRef.set(
        {'availability': filteredAvailability},
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error removing old availability: $e');
      rethrow; // Optionally rethrow the error to handle it elsewhere
    }
  }

  Future<void> updateExpertAvailability({
    required String expertId,
    required DsdExpertAvailability newAvailability,
  }) async {
    try {
      final expertDocRef = _db.collection("expertAvailablity").doc(expertId);

      // Fetch the current availability data
      final docSnapshot = await expertDocRef.get();
      Map<String, dynamic>? currentData = docSnapshot.data();

      // Initialize current availability if no data exists
      Map<DateTime, List<AvailabilitySlot>> currentAvailability = {};
      if (currentData != null && currentData.containsKey('availability')) {
        final currentMap = currentData['availability'] as Map<String, dynamic>;
        currentAvailability = currentMap.map((dateStr, slots) {
          return MapEntry(
            DateTime.parse(dateStr),
            (slots as List<dynamic>).map((slotJson) {
              return AvailabilitySlot.fromJson(
                  slotJson as Map<String, dynamic>);
            }).toList(),
          );
        });
      }

      // Merge the new availability with the current one, ensuring uniqueness
      newAvailability.availability?.forEach((date, newSlots) {
        currentAvailability.update(
          date,
          (existingSlots) {
            // Check for uniqueness by comparing start and end times
            final uniqueSlots = [...existingSlots];

            for (var newSlot in newSlots) {
              // Add new slot if no slot with the same start and end time exists
              bool isUnique = !existingSlots.any((existingSlot) =>
                  existingSlot.start == newSlot.start &&
                  existingSlot.end == newSlot.end);

              if (isUnique) {
                uniqueSlots.add(newSlot);
              }
            }

            return uniqueSlots;
          },
          ifAbsent: () =>
              newSlots, // If no slots exist for this date, add new ones directly
        );
      });

      // Use the DsdExpertAvailability's toJson method to convert the merged data
      final updatedAvailability = DsdExpertAvailability(
          availability: currentAvailability, expertId: expertId);
      final updatedAvailabilityJson = updatedAvailability.toJson();

      // Update the Firestore document
      await expertDocRef.set(updatedAvailabilityJson, SetOptions(merge: true));
    } catch (e) {
      print(e);
      rethrow; // rethrow the error to handle it elsewhere if needed
    }
  }

  Future<DsdExpertAvailability?> getAvailability(String expertId) async {
    try {
      // Reference to the expert's availability document
      final docRef = _db.collection('expertAvailablity').doc(expertId);

      // Fetch the document
      final doc = await docRef.get();
      if (!doc.exists) {
        // No document found
        print('No document found for expert ID: $expertId');
        return null;
      }

      final data = doc.data();
      if (data == null || !data.containsKey('availability')) {
        // No availability data found
        print('No availability data found for expert ID: $expertId');
        return null;
      }

      // Convert the data to DsdExpertAvailability object
      return DsdExpertAvailability.fromJson(
        json: data,
        id: expertId,
      );
    } catch (e) {
      print('Error fetching availability: $e');
      rethrow; // Optionally rethrow the error to handle it elsewhere
    }
  }
}
