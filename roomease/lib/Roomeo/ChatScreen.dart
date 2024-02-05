import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import '../Message.dart';
import '../colors/ColorConstants.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:roomease/Roomeo/Roomeo.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late TextEditingController _controller;
  final messageList = <Message>[];
  late FocusNode textFieldFocusNode;
  static late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    scrollController = ScrollController();
    textFieldFocusNode = FocusNode();
    // Scroll to the bottom when the widget is built
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat with Roomeo'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Column(
          children: [
            Expanded(
                child: DatabaseManager.messagesStreamBuilder(
                    CurrentUser.getCurrentUserId() + RoomeoUser.user.userId)),
            Container(
              color: ColorConstants.white,
              child: chatTextField(),
            ),
          ],
        )

        // Container(
        //   color: ColorConstants.white,
        //   child: Column(children: [
        //     DatabaseManager.messagesStreamBuilder(
        //         CurrentUser.getCurrentUserId() + RoomeoUser.user.userId),
        //     Center(child: chatTextField()),
        //   ]),
        // ),
        );
  }

  Widget chatTextField() {
    return TextField(
        focusNode: textFieldFocusNode,
        controller: _controller,
        onSubmitted: (String message) async {
          if (message != "") {
            // add the user message to the database
            DateTime dateTime = DateTime.now();
            messageList.add(Message(message, CurrentUser.getCurrentUserId(),
                CurrentUser.getCurrentUserName(), dateTime));
            _controller.clear();
            textFieldFocusNode.requestFocus();
            setState(() {});
            // add user + Roomeo response to the DB
            await getRoomeoResponse(message, dateTime);
            // fetch the category of the message
            String category = await getCommandCategory(message);
            print("CATEGORY IS: $category");
            Map<String, dynamic> commandParams =
                await getCommandParameters(category, message);
            print(commandParams);
          }
        },
        decoration: InputDecoration(
            filled: true,
            fillColor: ColorConstants.lightGray,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstants.lightPurple)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstants.lightPurple)),
            hintText: 'What would you like to ask Roomeo today?'),
        cursorColor: ColorConstants.lightPurple);
  }
}

Widget buildListMessage(List<Message> messages) {
  return GroupedListView<Message, DateTime>(
    padding: const EdgeInsets.all(8),
    reverse: true,
    order: GroupedListOrder.DESC,
    useStickyGroupSeparators: true,
    floatingHeader: true,
    elements: messages,
    groupBy: (message) => DateTime(
        message.timestamp.year, message.timestamp.month, message.timestamp.day),
    groupHeaderBuilder: (Message message) => SizedBox(
      height: 40,
      child: Center(
        child: Card(
          color: ColorConstants.darkPurple,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              DateFormat.yMMMd().format(message.timestamp),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
    itemBuilder: (context, Message message) => Align(
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
    ),
  );
}

// Widget chatMessage(Message message) {
//   MainAxisAlignment alignment;
//   if (message.senderId == CurrentUser.getCurrentUserId()) {
//     alignment = MainAxisAlignment.end;
//   } else {
//     alignment = MainAxisAlignment.start;
//   }
//   return Row(
//     mainAxisAlignment: alignment,
//     children: [
//       BubbleSpecialThree(
//         isSender: message.senderId == CurrentUser.getCurrentUserId(),
//         text: message.text,
//         color: ColorConstants.lightPurple,
//         textStyle: TextStyle(color: Colors.white, fontSize: 16),
//       )
//     ],
//   );
// }
