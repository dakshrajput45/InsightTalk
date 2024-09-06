import 'package:cloud_firestore/cloud_firestore.dart';

class Dsdtoken {
  final String _collectionPath = "expertDetails";
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getExpertFcmToken(String expertId) async {
    try {
      var result = await _db.collection(_collectionPath).doc(expertId).get();
      print(result.data()?['fcmToken'] as String?);
      return result.data()?['fcmToken'] as String?;
    } catch (e) {
      rethrow;
    }
  }
  Future<String?> getUserFcmToken(String userId) async {
    try {
      var result = await _db.collection("userDetails").doc(userId).get();
      print(result.data()?['fcmToken'] as String?);
      return result.data()?['fcmToken'] as String?;
    } catch (e) {
      rethrow;
    }
  }
}
