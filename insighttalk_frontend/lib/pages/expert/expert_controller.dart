import 'package:insighttalk_backend/apis/category/category_apis.dart';
import 'package:insighttalk_backend/modal/category.dart';

class DsdExpertController {
  // final DsdUserDetailsApis _dsdUserDetailsApis = DsdUserDetailsApis();
  final DsdCategoryApis _dsdCategoryApis = DsdCategoryApis();

  Future<List<DsdCategory>?> fetchPopularCategories() async {
    try {
      List<DsdCategory>? categories = await _dsdCategoryApis.fetchPopularCategories();
      return categories?.take(5).toList();
    } catch (e) {
      rethrow;
    }
  }
}
