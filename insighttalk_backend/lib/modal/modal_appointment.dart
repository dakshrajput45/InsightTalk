import 'package:cloud_firestore/cloud_firestore.dart';

class DsdAppointment {
  String? id;
  String? expertId;
  String? userId;
  String? chatRoomId;
  Timestamp? createdAt;
  Timestamp? appointmentTime;
  int? duration;
  int? fee;
  String? reason;
  List<String>? category;
  String? linkAdded;
  bool? confirmation;
  bool? canceled;
  String? name;
  String? profileImage;

  DsdAppointment(
      {this.id,
      this.expertId,
      this.userId,
      this.chatRoomId,
      this.createdAt,
      this.appointmentTime,
      this.duration,
      this.fee,
      this.reason,
      this.category,
      this.linkAdded,
      this.confirmation,
      this.canceled,
      this.name,
      this.profileImage});

  // fromJson method
  factory DsdAppointment.fromJson({required Map<String, dynamic> json, required String id}) {
    return DsdAppointment(
      id: id,
      expertId: json['expertId'] as String?,
      userId: json['userId'] as String?,
      chatRoomId: json['chatRoomId'] as String?,
      createdAt: json['createdAt'] != null ? json['createdAt'] as Timestamp : null,
      appointmentTime:
          json['appointmentTime'] != null ? json['appointmentTime'] as Timestamp : null,
      duration: json['duration'] as int?,
      fee: json['fee'] as int?,
      reason: json['reason'] as String?,
      category: json['category'] != null ? List<String>.from(json['category']) : null,
      linkAdded: json['linkAdded'] as String?,
      confirmation: json['confirmation'] as bool?,
      canceled: json['canceled'] as bool?,
      name: json['name'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }

  // toJson method for converting the model to a Map<String, dynamic>
  Map<String, dynamic> toJson({withId = false}) {
    return {
      'id': id,
      'expertId': expertId,
      'userId': userId,
      'chatRoomId': chatRoomId,
      'createdAt': createdAt,
      'appointmentTime': appointmentTime,
      'duration': duration,
      'fee': fee,
      'reason': reason,
      'category': category,
      'linkAdded': linkAdded,
      'confirmation': confirmation,
      'canceled': canceled
    };
  }
}
