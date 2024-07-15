import 'package:insighttalk_backend/apis/category/category_apis.dart';

class DsdProfileController {
  // final DsdUserDetailsApis _dsdUserDetailsApis = DsdUserDetailsApis();
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();

  Future<List<Map<String, dynamic>>> fetchPopularCategories() async {
    try {
      List<Map<String, dynamic>> categories =
          await _dsdCategoryApis.fetchPopularCategories();
      return categories;
    } catch (e) {
      rethrow;
    }
  }
}
