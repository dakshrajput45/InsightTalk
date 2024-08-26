import 'package:cloud_firestore/cloud_firestore.dart';

class DsdAppointment {
  String? id;
  String? expertId;
  String? userId;
  String? chatRoomId;
  Timestamp? createdAt;
  Timestamp? appointmentTime;
  String? duaration;
  int? fee;
  String? reason;
  String? category;

  DsdAppointment({
    this.id,
    required this.expertId,
    required this.userId,
    this.chatRoomId,
    required this.createdAt,
    required this.appointmentTime,
    required this.duaration,
    required this.fee,
    required this.reason,
    required this.category,
  });

  factory DsdAppointment.fromJson({required Map<String, dynamic> json,required String id}) {
    try {
      return DsdAppointment(
        id: id,
        expertId: json['expert'] as String,
        userId: json['user'] as String,
        chatRoomId: json['chatRoomId'] as String,
        createdAt: json['createdAt'] as Timestamp?,
        appointmentTime: json['appointmentTime'] as Timestamp?,
        duaration: json['duaration'] as String?,
        fee: json['fee'] as int?,
        reason: json['reason'] as String?,
        category: json['category'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (withId && id != null) 'id': id,
      if (expertId != null) 'expertId': expertId,
      if (userId != null) 'userId': userId,
      if (chatRoomId != null) 'chatRoom': chatRoomId,
      if (createdAt != null) 'createdAt': createdAt,
      if (appointmentTime != null) 'appointmentTime': appointmentTime,
      if (duaration != null) 'duaration': duaration,
      if (fee != null) 'fee': fee,
      if (reason != null) 'reason': reason,
      if (category != null) 'category': category,
    };
  }
}
