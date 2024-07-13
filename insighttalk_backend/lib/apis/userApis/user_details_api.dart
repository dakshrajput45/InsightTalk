import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdUserDetailsApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
}
