import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/modal/modal_appointment.dart';
import 'package:insighttalk_backend/apis/appointment/appointment_apis.dart';
import 'package:insighttalk_backend/modal/modal_expert.dart';

class DsdAppointmentController {
  final DsdAppointmentApis _dsdAppointmentApis = DsdAppointmentApis();
  final DsdExpertApis _dsdExpertApis = DsdExpertApis();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();

  Future<void> createAppointment(
      String userId,
      String expertId,
      Timestamp appointmentTime,
      String reason,
      List<String> category,
      int fee,
      String duration) async {
    try {
      DsdAppointment appointment = DsdAppointment(
          expertId: expertId,
          userId: userId,
          createdAt: Timestamp.now(),
          appointmentTime: appointmentTime,
          duration: duration,
          fee: fee,
          reason: reason,
          category: category,
          confirmation: false,
          canceled: false,
          linkAdded: "");

      await _dsdAppointmentApis.createAppointment(appointment);
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<DsdAppointment>, DocumentSnapshot<Object?>?)> fetchAppointments({
    DateTime? endDateTime,
    String? uid,
    bool? isShowCancelled,
    required DateTimeFilter dateFilter,
    DocumentSnapshot<Object?>? startAfter,
  }) async {
    try {
      return await _dsdAppointmentApis.fetchAppointments(
        isUser: true,
        uid: uid,
        dateFilter: dateFilter,
        startAfter: startAfter,
        limit: 20,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<(String, String)> fetchExpertById(String expertId) async {
    try {
      DsdExpert? expert =
          await _dsdExpertApis.fetchExpertById(expertId: expertId);

      String profileImage = expert!.profileImage!;
      String userName = expert.expertName!;
      return (profileImage, userName);
    } catch (e) {
      rethrow;
    }
  }
}
