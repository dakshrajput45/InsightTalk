import 'package:flutter/material.dart';

class ClientChatView extends StatefulWidget {
  const ClientChatView({super.key});

  @override
  State<ClientChatView> createState() => _ClientChatViewState();
}

class _ClientChatViewState extends State<ClientChatView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Client Chat",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        )
      ],
    );
  }
}
