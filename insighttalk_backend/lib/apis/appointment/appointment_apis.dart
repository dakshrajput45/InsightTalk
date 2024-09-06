import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/chat/chat_api.dart';
import 'package:insighttalk_backend/helper/get_fcm_token.dart';
import 'package:insighttalk_backend/helper/time_helper.dart';
import 'package:insighttalk_backend/modal/modal_appointment.dart';
import 'package:insighttalk_backend/services/push_notification_service.dart.dart';

class DsdAppointmentApis {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _collectionPath = "appointments";
  final Dsdtoken _token = Dsdtoken();
  final DsdChatApis _dsdChatApis = DsdChatApis();
  final DsdPushNotificationService _dsdPushNotificationService =
      DsdPushNotificationService();

  Future<void> createAppointment(DsdAppointment appointment) async {
    try {
      var token = await _token.getExpertFcmToken(appointment.expertId!);
      DocumentReference docRef = _db.collection(_collectionPath).doc();
      appointment.id = docRef.id;
      await docRef.set(appointment.toJson());
      _dsdPushNotificationService.sendAppointmentRequest(token!);
      print("Appointment successfully created with ID: ${appointment.id}");
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<DsdAppointment>, DocumentSnapshot?)> fetchAppointments({
    bool? isUser,
    String? uid,
    required DateTimeFilter dateFilter,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      print('UID: $uid');
      print('IsUser: $isUser');

      Query query = _db
          .collection(_collectionPath)
          .orderBy('appointmentTime', descending: true)
          .limit(limit);

      if (uid != null && uid.isNotEmpty) {
        if (isUser != null && isUser) {
          query = query.where('userId', isEqualTo: uid);
          print('Querying by userId: $uid');
        } else if (isUser != null && !isUser) {
          query = query.where('expertId', isEqualTo: uid);
          print('Querying by expertId: $uid');
        }
      } else {
        print('UID is null or empty');
      }

      query = _applyDateFilter(query, dateFilter);
      print('Firestore Query: ${query.toString()}');

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      var result = await query.get();
      print('Query results: ${result.docs.length} documents found');

      var appointments = result.docs.map((doc) {
        print('Document ID: ${doc.id}');
        return DsdAppointment.fromJson(
            json: doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();

      var lastDocument = result.docs.isNotEmpty ? result.docs.last : startAfter;
      return (appointments, lastDocument);
    } catch (e) {
      print('Error fetching appointments: $e');
      rethrow;
    }
  }

  Query _applyDateFilter(Query query, DateTimeFilter dateFilter) {
    final now = Timestamp.now();
    final todayStart =
        Timestamp.fromDate(DsdDateTimeHelper.toMidnight(now.toDate()));
    final todayEnd =
        Timestamp.fromDate(DsdDateTimeHelper.toEndOfDay(now.toDate()));

    switch (dateFilter) {
      case DateTimeFilter.today:
        return query
            .where('appointmentTime', isGreaterThanOrEqualTo: todayStart)
            .where('appointmentTime', isLessThanOrEqualTo: todayEnd);
      case DateTimeFilter.past:
        // For "past", return only appointments before today.
        return query.where('appointmentTime', isLessThan: todayStart);
      case DateTimeFilter.future:
        // For "future", return only appointments from tomorrow onwards.
        final startOfTomorrow = Timestamp.fromDate(DsdDateTimeHelper.toMidnight(
            now.toDate().add(const Duration(days: 1))));
        return query.where('appointmentTime',
            isGreaterThanOrEqualTo: startOfTomorrow);
      default:
        return query;
    }
  }

  Future<DsdAppointment?> fetchAppointmentById(String id) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(_collectionPath).doc(id).get();
      if (doc.exists) {
        print('fetchAppointmentById : $id');
        return DsdAppointment.fromJson(
          json: doc.data() as Map<String, dynamic>,
          id: id,
        );
      }
      return null;
    } catch (e) {
      print("Error fetching appointment by id: $e");
      rethrow;
    }
  }

  Future<void> updateConfirmation(
      String appointmentId, String link, String userId, String expertId) async {
    try {
      String chatRoomId = await _dsdChatApis.createChatRoom(userId, expertId);
      print('this is chatRoom Id $chatRoomId');
      DocumentReference docRef =
          _db.collection(_collectionPath).doc(appointmentId);

      await docRef.update(
          {'confirmation': true, 'linkAdded': link, 'chatRoomId': chatRoomId});

      var token = await _token.getUserFcmToken(userId);
      _dsdPushNotificationService.sendAppointmentLinkAdded(token!);
      print('Document updated successfully.');
    } catch (e) {
      print('Error updating Document: $e');
      rethrow;
    }
  }
}

enum DateTimeFilter {
  today,
  past,
  future,
}
