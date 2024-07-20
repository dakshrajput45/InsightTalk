import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdProfileController {
  final DsdUserDetailsApis _dsdUserDetailsApis = DsdUserDetailsApis();
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();

  Future<void> updateUser(
      {required DsdUser user, required String userId}) async {
    try {
      await _dsdUserDetailsApis.updateUserDetails(userId: userId, user: user);
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

  Future<void> updateUserIdInCategory(
      {required String categoryTitle, required String userId}) async {
    try {
      await _dsdCategoryApis.addUserIdToCategory(
          categoryTitle: categoryTitle, userId: userId);
    } catch (e) {
      rethrow;
    }
  }
}
