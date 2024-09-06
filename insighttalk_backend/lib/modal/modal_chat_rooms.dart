import 'package:insighttalk_backend/modal/modal_message.dart';

class DsdChatRooms {
  String? id;
  String? userId;
  String? expertId;
  bool? lock;
  DsdMessage? lastMessage;
  String? name;
  String? profileImage;

  DsdChatRooms({
    this.id,
    required this.userId,
    required this.expertId,
    required this.lock,
    this.lastMessage,
    this.name,
    this.profileImage,
  });

  factory DsdChatRooms.fromJson(
      {required Map<String, dynamic> json, required String id}) {
    try {
      return DsdChatRooms(
        id: id,
        lock: json['lock'],
        userId: json['userId'],
        expertId: json['expertId'],
        lastMessage: json['lastMessage'] != null
            ? DsdMessage.fromJson(
                json['lastMessage'] as Map<String, dynamic>,
                id,
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
      if (lock != null) 'lock': lock,
      if (userId != null) 'userId': userId,
      if (expertId != null) 'expertId': expertId,
      if (lastMessage != null) 'lastMessage': lastMessage?.toJson(withId: true),
    };
  }
}
