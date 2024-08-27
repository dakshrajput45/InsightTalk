import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/modal/modal_appointment.dart';
import 'package:insighttalk_backend/apis/appointment/appointment_apis.dart';

class DsdAppointmentController {
  final DsdAppointmentApis _dsdAppointmentApis = DsdAppointmentApis();

  Future<void> createAppointment(
      String userId,
      String expertId,
      Timestamp appointmentTime,
      String reason,
      String category,
      int fee,
      String duaration) async {
    try {
      DsdAppointment appointment = DsdAppointment(
          expertId: expertId,
          userId: userId,
          createdAt: Timestamp.now(),
          appointmentTime: appointmentTime,
          duaration: duaration,
          fee: fee,
          reason: reason,
          category: category);

      await _dsdAppointmentApis.createAppointment(appointment);
    } catch (e) {
      rethrow;
    }
  }
}
