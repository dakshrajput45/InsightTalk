import 'package:cloud_firestore/cloud_firestore.dart';

class DsdMessage {
  String? id;
  String? text;
  Timestamp? time;
  String? senderName;

  DsdMessage({
    this.id,
    required this.text,
    required this.time,
    required this.senderName,
  });

  factory DsdMessage.fromJson(Map<String, dynamic> json, String id) {
    try {
      return DsdMessage(
        id: id,
        text: json['text'],
        time: json['time'],
        senderName: json['senderName'],
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
      if (time != null) 'time': time,
      if (senderName != null) 'senderName': senderName
    };
  }
}
