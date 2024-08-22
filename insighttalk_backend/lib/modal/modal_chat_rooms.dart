import 'package:insighttalk_backend/modal/modal_expert.dart';
import 'package:insighttalk_backend/modal/modal_message.dart';
import 'package:insighttalk_backend/modal/modal_user.dart';

class DsdChatRooms {
  String? id;
  String? userId;
  String? expertId;
  bool? lock;
  DsdMessage? lastMessage;
  DsdUser? user;
  DsdExpert? expert;

  DsdChatRooms({
    this.id,
    required this.userId,
    required this.expertId,
    required this.lock,
    this.lastMessage,
    this.user,
    this.expert,
  });

  factory DsdChatRooms.fromJson(Map<String, dynamic> json, String id) {
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
        user: json['user'] != null
            ? DsdUser.fromJson(
                json: json['user'] as Map<String, dynamic>,
                id: json['user']['id'] as String,
              )
            : null,
        expert: json['expert'] != null
            ? DsdExpert.fromJson(
                json: json['expert'] as Map<String, dynamic>,
                id: json['expert']['id'] as String,
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
      if (user != null) 'user': user?.toJson(withId: true),
      if (expert != null) 'expert': expert?.toJson(withId: true),
    };
  }
}
