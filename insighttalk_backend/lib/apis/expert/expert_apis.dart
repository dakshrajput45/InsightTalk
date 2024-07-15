import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';

class DsdExpertApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = "experts";

  Future<void> addRating(String expertId, int rating) async {
  try {
    DocumentReference docRef = _db.collection(_collectionPath).doc(expertId);

    // Use a transaction to ensure atomicity
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("Expert does not exist!");
      }

      int sumOfRatings = snapshot.get('sumOfRatings');
      int numberOfRatings = snapshot.get('numberOfRatings');

      int newSumOfRatings = sumOfRatings + rating;
      int newNumberOfRatings = numberOfRatings + 1;

      transaction.update(docRef, {
        'sumOfRatings': newSumOfRatings,
        'numberOfRatings': newNumberOfRatings,
      });
    });

    print("Rating added successfully.");
  } catch (e) {
    print("Error adding rating: $e");
  }
}
}
