import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insighttalk_backend/apis/chat/chat_api.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_backend/modal/modal_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DsdChatController {
  DsdChatApis dsdChatSdk = DsdChatApis();
  DocumentSnapshot<Object?>? lastChatRoomSnapshot;
  final List<DsdChatRooms> _myChatRooms = [];
  List<DsdChatRooms> get myChatRooms => _myChatRooms;

  Future<void> sendMessage({
    required DsdChatRooms room,
    required DsdMessage message,
  }) async {
    try {
      await dsdChatSdk.sendMessage(
        message: message,
        chatRoom: room,
      );
    } catch (e) {
      rethrow;
    }
  }

  fetchChatRooms({bool hardReset = false, required String userId,required bool isUser}) async {
    if (hardReset) {
      _myChatRooms.clear();
      lastChatRoomSnapshot = null;
    }
    var rooms = await dsdChatSdk.getChatRooms(
      id: userId,
      isUser: isUser,
      lastDocumentSnapshot: lastChatRoomSnapshot,
    );
    _myChatRooms.addAll(rooms.$1);
    lastChatRoomSnapshot = rooms.$2;
  }

  late SharedPreferences prefs;
  Future<void> logTimeToSharedPreference(String chatRoomId) async {
    await prefs.setInt(
        "$chatRoomId.lastSeen", DateTime.now().millisecondsSinceEpoch);
  }

  DateTime? getTimeFromSharedPreference(String chatRoomId) {
    var lastSeen = prefs.getInt("$chatRoomId.lastSeen");
    if (lastSeen != null) {
      return DateTime.fromMicrosecondsSinceEpoch(lastSeen);
    }
    return null;
  }

  Future<void> initializeSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  DocumentSnapshot<Object?>? _lastChatMessage;

  Future<List<DsdMessage>> fetchOldMessages(
      {required String roomId,
      required Timestamp time,
      bool hardReset = false}) async {
    try {
      if (hardReset) _lastChatMessage = null;
      var result = await dsdChatSdk.fetchOldMessages(
          roomId: roomId, time: time, startAfter: _lastChatMessage);
      _lastChatMessage = result.$2;
      return result.$1;
    } catch (e) {
      rethrow;
    }
  }
}
