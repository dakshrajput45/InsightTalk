import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insighttalk_backend/apis/expert/expert_apis.dart';
import 'package:insighttalk_backend/apis/userApis/user_details_api.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_backend/modal/modal_message.dart';
import 'package:insighttalk_backend/services/push_notification_service.dart.dart';

class DsdChatApis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DsdUserDetailsApis _dsdUserDetailsApis = DsdUserDetailsApis();
  final DsdExpertApis _dsdExpertApis = DsdExpertApis();
  final DsdPushNotificationService dsdPushNotificationService =
      DsdPushNotificationService();

  BuildContext? get context => null;

  Future<String> createChatRoom(String userId, String expertId) async {
    try {
      var user = await _dsdUserDetailsApis.fetchUserById(userId: userId);
      var expert = await _dsdExpertApis.fetchExpertById(expertId: expertId);

      final chatRoom = _firestore.collection('chatRooms').doc();
      final newChatRoom = DsdChatRooms(
          userId: userId,
          expertId: expertId,
          lock: false,
          lastMessage: null,
          user: user,
          expert: expert);
      await chatRoom.set(newChatRoom.toJson());
      return chatRoom.id;
    } catch (e) {
      print("chat room not created");
      rethrow;
    }
  }

  Future<(List<DsdChatRooms>, DocumentSnapshot?)> getChatRooms(
      {required String id,
      bool isUser = true, // userId ke liye true, expertId ke liye false
      DocumentSnapshot? lastDocumentSnapshot,
      int pageSize = 10 // Default page size 10
      }) async {
    try {
      Query query = _firestore.collection('chatRooms');

      if (isUser) {
        query = query.where('userId',
            isEqualTo: id); // Agar user hai toh userId ke basis pe query
      } else {
        query = query.where('expertId',
            isEqualTo: id); // Agar expert hai toh expertId ke basis pe query
      }

      // query = query.orderBy('updatedAt', descending: true).limit(pageSize);

      if (lastDocumentSnapshot != null) {
        query = query.startAfterDocument(
            lastDocumentSnapshot); // Last document ke baad se query shuru karo
      }
      final querySnapshot = await query.get();
      var lastDoc = lastDocumentSnapshot;
      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs[querySnapshot.size -
            1]; // Last document ko store karo for next query
      }
      List<DsdChatRooms> chatRooms = querySnapshot.docs.map((doc) {
        return DsdChatRooms.fromJson(
          json: doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
      return (
        chatRooms,
        lastDoc
      ); // Chat rooms aur last document ko return karo
    } catch (e) {
      print('Error fetching chat rooms: $e');
      rethrow;
    }
  }

  Future<void> sendMessage({
    required DsdChatRooms chatRoom,
    required DsdMessage message,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chatRooms')
          .doc(chatRoom.id)
          .collection('messages')
          .doc();

      final newMessage = DsdMessage(
        id: messageRef.id,
        text: message.text,
        time: message.time,
        senderName: message.senderName,
      );

      await Future.wait([
        messageRef.set(newMessage.toJson(withId: true)),
        _updateLastMessage(chatRoom.id!, newMessage),
      ]);
      print("kch to ho");
      bool isUser =
          message.senderName == chatRoom.user!.userName! ? true : false;
      print(isUser);
      String token =
          isUser ? chatRoom.expert!.fcmToken! : chatRoom.user!.fcmToken!;
    
      print("token = $token");
      dsdPushNotificationService.sendNotification(
          token, message.senderName!, message.text!);
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateLastMessage(String chatRoomId, DsdMessage message) async {
    try {
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': {
          'id': message.id,
          'text': message.text,
          'time': message.time,
          'senderName': message.senderName,
        },
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<DsdMessage>, DocumentSnapshot?)> fetchOldMessages({
    required String roomId,
    required Timestamp time,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _firestore
          .collection("chatRooms")
          .doc(roomId)
          .collection("messages")
          .where("time", isLessThanOrEqualTo: time)
          .orderBy("time", descending: true);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      var res = await query.limit(10).get();

      if (res.docs.isNotEmpty) {
        var lastDoc = res.docs[res.size - 1];
        var messages = res.docs.map((e) {
          return DsdMessage.fromJson(e.data(), e.id);
        }).toList();
        return (messages, lastDoc);
      }

      return (<DsdMessage>[], startAfter);
    } catch (e) {
      rethrow;
    }
  }
}
