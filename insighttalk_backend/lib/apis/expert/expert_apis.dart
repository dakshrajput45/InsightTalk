import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/helper/dsd_dob_validator.dart';
import 'package:insighttalk_backend/modal/modal_availablity.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';

class DsdExpertApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();
  final String _expertCollectionPath = "expertDetails";

  Future<void> updateExpertDetails(
      {required String expertId, required DsdExpert expert}) async {
    try {
      await _db
          .collection(_expertCollectionPath)
          .doc(expertId)
          .set(expert.toJson(), SetOptions(merge: true));
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

  Future<List<DsdCategory>?> fetchExpertCategories(
      {required String expertId}) async {
    try {
      var result =
          await _db.collection(_expertCollectionPath).doc(expertId).get();
      if (result.exists) {
        DsdExpert expertData =
            DsdExpert.fromJson(json: result.data()!, id: result.id);
        List<String>? category = expertData.category;
        List<DsdCategory> expertCategory = [];
        print(category);
        await Future.forEach(category!, (x) async {
          print(x);
          DsdCategory? categoryData =
              await _dsdCategoryApis.fetchCategoryById(categoryId: x);
          if (categoryData != null) {
            expertCategory.add(categoryData);
          }
        });
        return expertCategory;
      }
      return null;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
