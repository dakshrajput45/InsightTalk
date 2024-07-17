import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';

class DsdExpertApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _expertCollectionPath = "experts";

  Future<void> updateExpertDetails(
      {required String expertId, required DsdExpert user}) async {
    try {
      await _db
          .collection(_expertCollectionPath)
          .doc(expertId)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<DsdExpert?> fetchExpertById({required String expertId}) async {
    try {
      var result =
          await _db.collection(_expertCollectionPath).doc(expertId).get();
      if (result.exists) {
        return DsdExpert.fromJson(json: result.data()!, id: result.id);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addRating(
      {required String expertId, required int rating}) async {
    try {
      DocumentReference docRef =
          _db.collection(_expertCollectionPath).doc(expertId);

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
