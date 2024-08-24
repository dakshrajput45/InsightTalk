import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_category.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdProfileController {
  final DsdUserDetailsApis _dsdUserDetailsApis = DsdUserDetailsApis();
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();

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

  Future<void> deleteUserIdInCategory(
      {required String categoryTitle, required String userId}) async {
    try {
      await _dsdCategoryApis.removeUserIdFromCategory(
          categoryTitle: categoryTitle, userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DsdExpert>?> fetchExpertData({required String categoryId}) async {
    try {
      List<DsdExpert>? experts =
          await _dsdCategoryApis.fetchExpertOfCategory(categoryId);
      return experts;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileData> getProfileData() async {
    try {
      String userId = _itUserAuthSDK.getUser()!.uid;
      DsdUser? fetchedUserData =
          await _dsdUserDetailsApis.fetchUserById(userId: userId);

      List<String>? categoryIds = fetchedUserData?.category;

      List<Future<DsdCategory?>> categoryFutures =
          categoryIds!.map((categoryId) async {
        return await _dsdCategoryApis.fetchCategoryById(categoryId: categoryId);
      }).toList();
      List<DsdCategory?> fetchedCategories = await Future.wait(categoryFutures);
      List<DsdCategory> validCategories =
          fetchedCategories.whereType<DsdCategory>().toList();
      return ProfileData(categories: validCategories, user: fetchedUserData);
    } catch (e) {
      rethrow;
    }
  }
}

class ProfileData {
  final List<DsdCategory> categories;
  final DsdUser? user;

  ProfileData({
    required this.categories,
    required this.user,
  });
}
