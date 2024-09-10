import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:insighttalk_backend/apis/chat/chat_api.dart';
import 'package:insighttalk_backend/helper/extension.dart';
import 'package:insighttalk_backend/modal/modal_chat_rooms.dart';
import 'package:insighttalk_backend/modal/modal_message.dart';
import 'package:insighttalk_backend/widegts/chat/chat_contoller.dart';
import 'package:insighttalk_backend/widegts/chat/message_view.dart';

class ClientChatView extends StatefulWidget {
  final String? roomId;
  final DsdChatRooms? room;

  const ClientChatView({
    super.key,
    required this.roomId,
    required this.room,
  });

  @override
  State<ClientChatView> createState() => _ClientChatViewState();
}

class _ClientChatViewState extends State<ClientChatView> {
  TextEditingController senderMessageController = TextEditingController();
  final ScrollController _listViewController = ScrollController();
  final DsdChatController _dsdChatController = DsdChatController();
  final DsdChatApis _dsdChatApis = DsdChatApis();
  late Stream<QuerySnapshot> _messageStream;
  bool _isLoading = true;
  DsdChatRooms? _chatRoom;
  String? senderName;

  final List<DsdMessage> _messages = [];
  final Timestamp screenLoadTime = Timestamp.now();

  void _sendTextMessage(String text) {
    if (widget.roomId == null) return;
    if (text.isEmpty) return;

    DsdMessage message = DsdMessage(
        text: text,
        time: Timestamp.now(),
        senderName: senderName,
        senderId: _chatRoom?.expertId!);
    _dsdChatController.sendMessage(
      message: message,
      room: widget.room!,
    );
    senderMessageController.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listViewController.hasClients) {
        _listViewController.animateTo(
          _listViewController.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void scrollToTop() {
    if (_listViewController.positions.isNotEmpty) {
      _listViewController.animateTo(
        _listViewController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    }
  }

  void _sortMessages() {
    _messages.sort(
      (b, a) => a.time!.toDate().compareTo(b.time!.toDate()),
    );
  }

  Future<void> loadData() async {
    var name =
        await _dsdChatApis.fetchNameAndImage(widget.room!.expertId!, false);
    senderName = name.$1;
  }

  Future<void> loadOldMessages(
      {bool hardReset = false,
      bool scrollBottom = false,
      bool showLoader = true,
      bool scrollTop = false}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    _messages.addAll(await _dsdChatController.fetchOldMessages(
      roomId: widget.roomId!,
      time: screenLoadTime,
      hardReset: hardReset,
    ));
    _sortMessages();

    setState(() {
      _isLoading = false;
    });
    if (scrollBottom && _messages.isNotEmpty) scrollToBottom();
    if (scrollTop && _messages.isNotEmpty) scrollToTop();
  }

  late StreamSubscription<QuerySnapshot<Object?>> docChangeListener;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      chatRoomListener;

  @override
  void initState() {
    super.initState();
    loadData();
    loadOldMessages(hardReset: true, showLoader: true, scrollBottom: true);
    _messageStream = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.roomId)
        .collection("messages")
        .where("time", isGreaterThan: screenLoadTime)
        .orderBy("time", descending: true)
        .snapshots();
    docChangeListener = _messageStream.listen(
      (event) async {
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              {
                FlutterRingtonePlayer()
                    .play(fromAsset: "assets/sounds/pop.mp3");
                setState(() {
                  _messages.add(DsdMessage.fromJson(
                      change.doc.data() as Map<String, dynamic>,
                      change.doc.id));
                  _sortMessages();
                });

                scrollToBottom();
              }
              break;
            case DocumentChangeType.modified:
              break;
            case DocumentChangeType.removed:
              break;
          }
        }
      },
    );
    chatRoomListener = FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(widget.roomId)
        .snapshots()
        .listen(
      (event) {
        _chatRoom = DsdChatRooms.fromJson(json: event.data()!, id: event.id);
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    docChangeListener.cancel();
    chatRoomListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.room!.name);
    print(widget.room!.profileImage);
    return Container(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage('${widget.room!.profileImage}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.room!.name}".toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: _messages.isNotEmpty
                        ? buildMessages()
                        : const Center(
                            child:
                                Text("Type a message to begin conversation!"),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: senderMessageController,
                            onChanged: (val) {
                              setState(() {});
                            },
                            minLines: 1,
                            autocorrect: true,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Write a message...',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            maxLength:
                                senderMessageController.value.text.length > 900
                                    ? 1024
                                    : null,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        if (senderMessageController.value.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _sendTextMessage(senderMessageController.text);
                            },
                            color: Theme.of(context).colorScheme.primary,
                            icon: const Icon(
                              Icons.send,
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget buildMessages() {
    return RefreshIndicator(
      onRefresh: () async {
        loadOldMessages(showLoader: false).then(
          (value) {
            scrollToTop();
          },
        );
      },
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: ListView.builder(
        reverse: true,
        controller: _listViewController,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final selfMessage = message.senderName == senderName && message.senderId == widget.room!.expertId;
          final bgColor = selfMessage
              ? Theme.of(context).colorScheme.primary
              : const Color.fromARGB(255, 202, 202, 202);
          final fgColor = selfMessage
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.black;

          // Previous message ka time check karenge
          bool showDate = false;
          if (index == _messages.length - 1) {
            // Agar pehla message hai, toh date dikhani hogi
            showDate = true;
          } else {
            final lastMessage = _messages[index + 1];
            // Agar current message aur previous message ka date alag hai, toh date dikhani hogi
            if (message.time!.toDate().day != lastMessage.time!.toDate().day ||
                message.time!.toDate().month !=
                    lastMessage.time!.toDate().month ||
                message.time!.toDate().year !=
                    lastMessage.time!.toDate().year) {
              showDate = true;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: selfMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showDate) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            message.time!
                                .toDate()
                                .dateFormatter("EEEE, dd MMMM"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ],
                DsdMessageView(
                    message: message,
                    selfMessage: selfMessage,
                    bgColor: bgColor,
                    fgColor: fgColor),
                Row(
                  mainAxisAlignment: selfMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      message.time!.toDate().dateFormatter("hh:mm aa"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
