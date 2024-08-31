import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/appointment/appointment_apis.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_appointment.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdAppointmentController {
  final DsdAppointmentApis _dsdAppointmentApis = DsdAppointmentApis();
  final DsdUserDetailsApis _dsdUserApis = DsdUserDetailsApis();

  Future<(List<DsdAppointment>, DocumentSnapshot<Object?>?)> fetchAppointments({
    DateTime? endDateTime,
    String? uid,
    bool? isShowCancelled,
    required DateTimeFilter dateFilter,
    DocumentSnapshot<Object?>? startAfter,
  }) async {
    try {
      return await _dsdAppointmentApis.fetchAppointments(
        isUser: false,
        uid: uid,
        dateFilter: dateFilter,
        startAfter: startAfter,
        limit: 20,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<(String, String)> fetchUserById(String userId) async {
    try {
      DsdUser? user = await _dsdUserApis.fetchUserById(userId: userId);

      String profileImage = user!.profileImage!;
      String userName = user.userName!;
      return (profileImage, userName);
    } catch (e) {
      rethrow;
    }
  }
}
