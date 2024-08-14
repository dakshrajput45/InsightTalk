import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  TextEditingController senderMessageController = TextEditingController();
  final ScrollController _listViewController = ScrollController();

  // Dummy messages with additional messages and two users
  final List<Map<String, dynamic>> _messages = [
    {
      'senderName': 'user1',
      'text': "Sounds great! Let's catch up soon.",
      'timestamp': DateTime(2024, 8, 3, 10, 6, 0),
    },
    {
      'senderName': 'user2',
      'text': "Same here, keeping busy with work and hobbies.",
      'timestamp': DateTime(2024, 8, 3, 10, 5, 0),
    },
    {
      'senderName': 'user1',
      'text': "Just working on some projects. What about you?",
      'timestamp': DateTime(2024, 8, 3, 10, 4, 0),
    },
    {
      'senderName': 'user2',
      'text': "Glad to hear that! What have you been up to?",
      'timestamp': DateTime(2024, 8, 3, 10, 3, 0),
    },
    {
      'senderName': 'user1',
      'text': "I'm doing well, thanks for asking!",
      'timestamp': DateTime(2024, 8, 3, 10, 2, 0),
    },
    {
      'senderName': 'user2',
      'text': "I'm good, thanks! How about you?",
      'timestamp': DateTime(2024, 8, 3, 10, 1, 0),
    },
    {
      'senderName': 'user1',
      'text': 'Hello, how are you?',
      'timestamp': DateTime(2024, 8, 3, 10, 0, 0),
    },
    {
      'senderName': 'user2',
      'text': 'Hello, how are you?',
      'timestamp': DateTime(2024, 8, 3, 10, 0, 0),
    },
    {
      'senderName': 'user1',
      'text': 'Hello, how are you?',
      'timestamp': DateTime(2024, 8, 3, 10, 0, 0),
    },
  ];

  void _sendTextMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, {
        'senderName': "user1",
        'text': text,
        'timestamp': DateTime.now(),
      });
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://media.istockphoto.com/id/1327592506/vector/default-avatar-photo-placeholder-icon-grey-profile-picture-business-man.jpg?s=612x612&w=0&k=20&c=BpR0FVaEa5F24GIw7K8nMWiiGmbb8qmhfkpXcp1dhQg='),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Active Now',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
                    child: Text("Type a message to begin conversation!"),
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
                    maxLength: senderMessageController.value.text.length > 900
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
    );
  }

  Widget buildMessages() {
    return ListView.builder(
      reverse: true,
      controller: _listViewController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final selfMessage = message['senderName'] == "user1";
        final bgColor = selfMessage
            ? Theme.of(context).colorScheme.primary
            : const Color.fromARGB(255, 202, 202, 202);
        final fgColor = selfMessage
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.black;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:
                selfMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: selfMessage ? const EdgeInsets.only(left: 90) : const EdgeInsets.only(right: 90),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message['text'],
                  style: TextStyle(color: fgColor),
                ),
              ),
              Text(
                "${(message['timestamp'] as DateTime).hour}:${(message['timestamp'] as DateTime).minute} ${((message['timestamp'] as DateTime).hour < 12) ? 'AM' : 'PM'}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
