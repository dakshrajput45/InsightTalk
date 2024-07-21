import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdChat {
  String? chatId;
  DsdExpert? expert;
  DsdUser? user;
  List<DsdMessage>? messages;

  DsdChat({
    this.chatId,
    this.expert,
    this.user,
    this.messages,
  });

  factory DsdChat.fromJson({
    required Map<String, dynamic> json,
    required String chatId,
  }) {
    try {
      return DsdChat(
        chatId: chatId,
        expert: json['expert'],
        user: json['user'],
        messages: List<DsdMessage>.from(
            json['messages']?.map((msg) => DsdMessage.fromJson(json: msg)) ??
                []),
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Map<String, dynamic> toJson({bool withId = true}) {
    return {
      if (withId) 'chatId': chatId,
      if (expert != null) 'expert': expert,
      if (user != null) 'user': user,
      if (messages != null)
        'messages': messages?.map((msg) => msg.toJson()).toList(),
    };
  }
}

class DsdMessage {
  String? userId;
  String? expertId;
  String? message;
  DateTime? timestamp;

  DsdMessage({
    this.userId,
    this.expertId,
    this.message,
    this.timestamp,
  });

  factory DsdMessage.fromJson({required Map<String, dynamic> json}) {
    return DsdMessage(
      userId: json['userId'],
      expertId: json['expertId'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (expertId != null) 'expertId': expertId,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}
