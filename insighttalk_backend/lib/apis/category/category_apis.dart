import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/category.dart';

class DsdCategoryApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = "categories";

  Future<void> addCategory({required DsdCategory category}) async {
    try {
      await _db.collection(_collectionPath).add(category.toJson());
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateCategory(
      {required String categoryId, required DsdCategory category}) async {
    try {
      await _db
          .collection(_collectionPath)
          .doc(categoryId)
          .set(category.toJson(), SetOptions(merge: true));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<DsdCategory>> fetchAllCategories() async {
    try {
      var result = await _db.collection(_collectionPath).get();
      return result.docs
          .map((doc) => DsdCategory.fromJson(json: doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<DsdCategory?> fetchCategoryById({required String categoryId}) async {
    try {
      var result = await _db.collection(_collectionPath).doc(categoryId).get();
      if (result.exists) {
        return DsdCategory.fromJson(json: result.data()!, id: result.id);
      }
      return null;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteCategory({required String categoryId}) async {
    try {
      await _db.collection(_collectionPath).doc(categoryId).delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
