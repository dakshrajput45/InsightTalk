import 'package:cloud_firestore/cloud_firestore.dart';

class DsdMessage {
  String? id;
  String? text;
  Timestamp? time;
  String? senderId;

  DsdMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.senderId,
  });

  factory DsdMessage.fromJson(
      {required Map<String, dynamic> json, required String id}) {
    try {
      return DsdMessage(
        id: id,
        text: json['text'],
        time: json['time'],
        senderId: json['senderId'],
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (withId) 'id': id,
      if (text != null) 'text': text,
      if (time != null) 'time':time,
      if (senderId != null) 'senderId':senderId
    };
  }
}
