import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/chat/chat_api.dart';
import 'package:insighttalk_backend/helper/time_helper.dart';
import 'package:insighttalk_backend/modal/modal_appointment.dart';

class DsdAppointmentApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _collectionPath = "appointments";
  final DsdChatApis _dsdChatApis = DsdChatApis();

  Future<void> createAppointment(DsdAppointment appointment) async {
    try {
      appointment.chatRoomId = await _dsdChatApis.createChatRoom(
          appointment.userId!, appointment.expertId!);
      await _db.collection(_collectionPath).add(appointment.toJson());
      print("ho gya kaam");
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<DsdAppointment>, DocumentSnapshot?)> fetchAppointmentsAdmin({
    required DateTimeFilter dateFilter,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection(_collectionPath)
          .orderBy('appointmentTime', descending: true)
          .limit(limit);

      query = _applyDateFilter(query, dateFilter);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      var result = await query.get();
      var appointments = result.docs.map((doc) {
        return DsdAppointment.fromJson(
            json: doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();

      var lastDocument = result.docs.isNotEmpty ? result.docs.last : startAfter;
      return (appointments, lastDocument);
    } catch (e) {
      rethrow;
    }
  }

  Query _applyDateFilter(Query query, DateTimeFilter dateFilter) {
    final now = Timestamp.now();
    switch (dateFilter) {
      case DateTimeFilter.today:
        final startOfDay =
            Timestamp.fromDate(DsdDateTimeHelper.toMidnight(now.toDate()));
        final endOfDay =
            Timestamp.fromDate(DsdDateTimeHelper.toEndOfDay(now.toDate()));
        return query
            .where('appointmentTime', isGreaterThanOrEqualTo: startOfDay)
            .where('appointmentTime', isLessThanOrEqualTo: endOfDay);
      case DateTimeFilter.past:
        return query.where('appointmentTime', isLessThan: now);
      case DateTimeFilter.future:
        final startOfDay = Timestamp.fromDate(DsdDateTimeHelper.toMidnight(
            now.toDate().add(const Duration(days: 1))));
        return query.where('appointmentTime',
            isGreaterThanOrEqualTo: startOfDay);
      default:
        return query;
    }
  }
}

enum DateTimeFilter {
  today,
  past,
  future,
}
