import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/category.dart';

class DsdCategoryApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = "categories";

  Future<void> addCategory({required DsdCategory category}) async {
    try {
      // Ensure categoryTitle is unique and valid
      String? categoryTitle =
          category.categoryTitle; // Adjust this based on your category model
      await _db
          .collection(_collectionPath)
          .doc(categoryTitle)
          .set(category.toJson());

      print('Category added successfully.');
    } catch (e) {
      print('Error adding category: $e');
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

  Future<void> addUserIdToCategory(
      {required String categoryTitle, required String userId}) async {
    try {
      DocumentReference docRef =
          _db.collection(_collectionPath).doc(categoryTitle);
      // Update the document to add the userId to the userIds array
      await docRef.update({
        'users': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addExpertIdToCategory(
      {required String categoryTitle, required String expertId}) async {
    try {
      DocumentReference docRef =
          _db.collection(_collectionPath).doc(categoryTitle);
      // Update the document to add the expertId to the userIds array
      await docRef.update({
        'experts': FieldValue.arrayUnion([expertId])
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> removeUserIdFromCategory(
      {required String categoryTitle, required String userId}) async {
    try {
      DocumentReference docRef =
          _db.collection(_collectionPath).doc(categoryTitle);
      // Update the document to remove the userId to the userIds array
      await docRef.update({
        'users': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> removeExpertIdFromCategory(
      {required String categoryTitle, required String expertId}) async {
    try {
      DocumentReference docRef =
          _db.collection(_collectionPath).doc(categoryTitle);
      // Update the document to remove the expertId to the userIds array
      await docRef.update({
        'experts': FieldValue.arrayRemove([expertId])
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<DsdCategory>?> fetchPopularCategories() async {
    try {
      var result =
          await FirebaseFirestore.instance.collection(_collectionPath).get();

      List<DsdCategory> categories = result.docs.map((doc) {
        return DsdCategory.fromJson(
          json: doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
      categories.sort((a, b) => (b.experts!.length + b.users!.length)
          .compareTo(a.experts!.length + a.users!.length));

      return categories;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
