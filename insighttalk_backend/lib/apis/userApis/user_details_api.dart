import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdUserDetailsApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();
  final _userCollectionPath = "userDetails";

  Future<void> updateUserDetails(
      {required String userId, required DsdUser user}) async {
    try {
      await _db
          .collection(_userCollectionPath)
          .doc(userId)
          .set(user.toJson(), SetOptions(merge: true));
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
        List<String>? category = userData.category;
        List<DsdCategory> userCategory = [];
        print(category);
        await Future.forEach(category!, (x) async {
          print(x);
          DsdCategory? categoryData =
              await _dsdCategoryApis.fetchCategoryById(categoryId: x);
          if (categoryData != null) {
            userCategory.add(categoryData);
          }
        });
        return userCategory;
      }
      return null;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
