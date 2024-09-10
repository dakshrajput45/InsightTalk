import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insighttalk_backend/apis/chat/chat_api.dart';
import 'package:insighttalk_backend/apis/userApis/auth_user.dart';
import 'package:insighttalk_backend/helper/extension.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_backend/widegts/chat/chat_contoller.dart';
import 'package:insighttalk_expert/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CleintChatRoomView extends StatefulWidget {
  const CleintChatRoomView({super.key});

  @override
  State<CleintChatRoomView> createState() => _CleintChatRoomViewState();
}

class _CleintChatRoomViewState extends State<CleintChatRoomView> {
  bool _loading = false;
  DsdChatController chatController = DsdChatController();
  final DsdChatApis _dsdChatApis = DsdChatApis();
  final ITUserAuthSDK _itUserAuthSDK = ITUserAuthSDK();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    chatController.initializeSharedPreference();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> openChatRoom(BuildContext context,
      {required String chatRoomId,
      required DsdChatRooms chatRoom}) async {
    await context.pushNamed(routeNames.chat, pathParameters: {
      "id": chatRoomId
    }, extra: {
      "chatRoom": chatRoom, // Pass the object directly
    });

    chatController.logTimeToSharedPreference(chatRoomId);

    if (!mounted) return; // Ensure the widget is still mounted before calling _loadData
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return; // Add this line to check if the widget is still mounted

    setState(() {
      _loading = true;
    });

    await chatController.initializeSharedPreference();

    var userId = _itUserAuthSDK.getUser()!.uid;

    await chatController.fetchChatRooms(hardReset: true, userId: userId);

    // Fetch name and profile image for each chat room
    for (var chatRoom in chatController.myChatRooms) {
      var details = await _dsdChatApis.fetchNameAndImage(chatRoom.userId!, true);
      chatRoom.name = details.$1;
      chatRoom.profileImage = details.$2;
    }

    if (!mounted) return; // Check again before calling setState

    setState(() {
      _loading = false;
    });
  }

  bool _isNewMessage(DsdChatRooms chatRoom) {
    String? lastSeenMessageTime = _prefs?.getString(chatRoom.id!);
    if (lastSeenMessageTime == null) {
      return true; // Assume it's new if we've never seen it before
    }

    DateTime lastSeen = DateTime.parse(lastSeenMessageTime);
    return chatRoom.lastMessage!.time!.toDate().isAfter(lastSeen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : chatController.myChatRooms.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: chatController.myChatRooms.length,
                    itemBuilder: (BuildContext context, int index) {
                      var chatRoom = chatController.myChatRooms[index];
                      var isNewMessage = _isNewMessage(chatRoom);
                      return Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              await openChatRoom(
                                  context,
                                  chatRoomId: chatRoom.id!,
                                  chatRoom: chatRoom);
                              if (!mounted) return; // Ensure the widget is mounted before calling _loadData
                              await _loadData();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    foregroundImage:
                                        CachedNetworkImageProvider(
                                      chatRoom.profileImage!,
                                    ),
                                    child: const Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(chatRoom.name!.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            )),
                                        const SizedBox(height: 4),
                                        if (chatRoom.lastMessage != null)
                                          Text(
                                            chatRoom.lastMessage!.text!
                                                .toUpperCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      if (chatRoom.lastMessage != null)
                                        Text(
                                          chatRoom.lastMessage!.time!
                                              .toDate()
                                              .dateFormatter("dd MMM"),
                                        ),
                                      if (isNewMessage)
                                        Icon(
                                          Icons.circle_notifications_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(color: Colors.grey)
                        ],
                      );
                    },
                  ),
                )
              : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No chat rooms available.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // Navigate to a booking page or another action
              Navigator.pushNamed(context, '/bookingPage');
            },
            child: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }
}
