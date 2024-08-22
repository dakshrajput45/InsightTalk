import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';

class DsdExpertProfileController {
  final DsdExpertApis _dsdExpertApis = DsdExpertApis();
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();

  Future<void> updateExpert(
      {required DsdExpert expert, required String expertId}) async {
    try {
      await _dsdExpertApis.updateExpertDetails(
          expertId: expertId, expert: expert);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DsdCategory>> fetchAllCategories() async {
    try {
      List<DsdCategory> categories =
          await _dsdCategoryApis.fetchAllCategories();
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpertIdInCategory(
      {required String categoryTitle, required String expertId}) async {
    try {
      await _dsdCategoryApis.addExpertIdToCategory(
          categoryTitle: categoryTitle, expertId: expertId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExperIdCategory(
      {required String categoryTitle, required String expertId}) async {
    try {
      await _dsdCategoryApis.removeExpertIdFromCategory(
          categoryTitle: categoryTitle, expertId: expertId);
    } catch (e) {
      rethrow;
    }
  }
}
