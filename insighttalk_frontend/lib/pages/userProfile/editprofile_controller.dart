import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdProfileController {
  final DsdUserDetailsApis _dsdUserDetailsApis = DsdUserDetailsApis();

  Future<void> updateUser({required DsdUser user, required String userId}) async {
    await _dsdUserDetailsApis.updateUserDetails(userId: userId, user: user);
  }
}
