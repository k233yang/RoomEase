import 'package:flutter/material.dart';
import 'package:roomease/Message.dart';
import '../CurrentUser.dart';
import '../colors/ColorConstants.dart';

class ChatBoxGeneric extends StatelessWidget {
  const ChatBoxGeneric(this.message, {super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.senderId == CurrentUser.getCurrentUserId()
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Card(
          color: message.senderId == CurrentUser.getCurrentUserId()
              ? ColorConstants.lightPurple
              : ColorConstants.lighterGray,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message.text),
          ),
        ),
      ),
    );
  }
}
