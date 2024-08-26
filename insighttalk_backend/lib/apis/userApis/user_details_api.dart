import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdUserDetailsApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  final _userCollectionPath = "userDetails";

  Future<void> updateUserDetails(
      {required String userId, required DsdUser user}) async {
    try {
      await _db
          .collection(_userCollectionPath)
          .doc(userId)
          .set(user.toJson(), SetOptions(merge: true),);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<DsdUser?> fetchUserById({required String userId}) async {
    try {
      var result = await _db.collection(_userCollectionPath).doc(userId).get();
      if (result.exists) {
        return DsdUser.fromJson(json: result.data()!, id: result.id);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<DsdCategory>?> fetchUserCategories(
      {required String userId}) async {
    try {
      var result = await _db.collection(_userCollectionPath).doc(userId).get();
      if (result.exists) {
        DsdUser userData =
            DsdUser.fromJson(json: result.data()!, id: result.id);
        List<String>? categoryIds = userData.category;

        if (categoryIds != null && categoryIds.isNotEmpty) {
          // Fetch all categories concurrently
          List<Future<DsdCategory?>> categoryFutures =
              categoryIds.map((categoryId) async {
            try {
              return await _dsdCategoryApis.fetchCategoryById(
                  categoryId: categoryId);
            } catch (e) {
              print('Error fetching category $categoryId: $e');
              return null; // Handle individual fetch errors
            }
          }).toList();

          // Wait for all futures to complete
          List<DsdCategory?> fetchedCategories =
              await Future.wait(categoryFutures);

          // Filter out null values
          List<DsdCategory> validCategories =
              fetchedCategories.whereType<DsdCategory>().toList();

          return validCategories;
        }
        return [];
      }
      return [];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      await _db.collection(_userCollectionPath).doc(userId).set({
        'fcmtoken': token, 
      }, SetOptions(merge: true));
      print("Updated token!!");
    } catch (e) {
      rethrow;
    }
  }
}
