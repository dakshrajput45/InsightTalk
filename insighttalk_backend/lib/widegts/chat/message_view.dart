import 'package:flutter/material.dart';
import 'package:insighttalk_backend/modal/modal_message.dart';

class DsdMessageView extends StatelessWidget {
  const DsdMessageView({
    super.key,
    required this.message,
    required this.selfMessage,
    required this.bgColor,
    required this.fgColor,
  });

  final DsdMessage message;
  final bool selfMessage;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  message.text!,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: Row(
                  children: [
                    Divider(),
                    Expanded(
                        child: Text(
                      "Delete Message",
                    )),
                    Icon(
                      Icons.delete,
                    ),
                  ],
                ),
              ),
            ],
          ),
          showDragHandle: true,
        );
      },
      child: Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.text!,
              style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
    );
  }
}
