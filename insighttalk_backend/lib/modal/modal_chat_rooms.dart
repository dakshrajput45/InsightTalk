import 'package:insighttalk_backend/modal/modal_message.dart';

class DsdChatRooms {
  String? id;
  String? userId;
  String? expertId;
  DsdMessage? lastMessage;
  List<DsdMessage>? chats;

  DsdChatRooms({
    required this.id,
    required this.userId,
    required this.expertId,
    required this.chats,
    required this.lastMessage,
  });

  factory DsdChatRooms.fromJson(
      {required Map<String, dynamic> json, required String id}) {
    try {
      return DsdChatRooms(
        id: id,
        userId: json['userId'],
        expertId: json['expertId'],
        lastMessage: json['lastMessage'] != null
            ? DsdMessage.fromJson(
                json: Map<String, dynamic>.from(json['lastMessage']), id: id)
            : null,
        chats: json['chats'] != null
            ? List<DsdMessage>.from(
                json['chats'].map(
                  (chat) => DsdMessage.fromJson(
                    json: Map<String, dynamic>.from(chat),
                    id: chat['id'], // assuming each message has its own 'id'
                  ),
                ),
              )
            : null,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

   Map<String, dynamic> toJson({bool withId = false}) {
    return {
      if (withId && id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (expertId != null) 'expertId': expertId,
      if (lastMessage != null) 'lastMessage': lastMessage?.toJson(withId: true),
      if (chats != null)
        'chats': chats?.map((message) => message.toJson(withId: true)).toList(),
    };
  }
}
