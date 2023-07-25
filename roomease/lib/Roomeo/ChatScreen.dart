import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import '../Message.dart';
import '../User.dart';
import '../colors/ColorConstants.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:roomease/Roomeo/ChatGPTAPI.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late TextEditingController _controller;
  final messageList = <Message>[];
  late FocusNode textFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    textFieldFocusNode = FocusNode();
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
        body: Container(
            color: ColorConstants.white,
            child: Column(children: [
              DatabaseManager.messagesStreamBuilder("messageRoomId"),
              Center(child: chatTextField()),
            ])));
  }

  Widget chatTextField() {
    return TextField(
        focusNode: textFieldFocusNode,
        controller: _controller,
        onSubmitted: (String message) async {
          //TODO: add a message object with message Id
          DatabaseManager.addMessage("messageRoomId",
              Message(message, CurrentUser.user, DateTime.now()));
          //TODO: instead of local messagelist, pull list from DB and extract name to figure out
          //which side to display message on
          messageList.add(Message(message, CurrentUser.user, DateTime.now()));
          _controller.clear();
          textFieldFocusNode.requestFocus();
          setState(() {});
          Future<String> res = getChatGPTResponse(message);
          res
              .then((message) => DatabaseManager.addMessage(
                  "messageRoomId",
                  Message(message, User("chatgpt", "useridchatgpt"),
                      DateTime.now())))
              .catchError((onError) => print(onError));
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
  return Flexible(
      child: ListView.builder(
    itemCount: messages.length,
    itemBuilder: (context, index) => chatMessage(messages[index]),
  ));
}

Widget chatMessage(Message message) {
  MainAxisAlignment alignment;
  if (message.sender.userId == CurrentUser.user.userId) {
    alignment = MainAxisAlignment.end;
  } else {
    alignment = MainAxisAlignment.start;
  }
  return Row(
    mainAxisAlignment: alignment,
    children: [
      BubbleSpecialThree(
        isSender: message.sender.userId == CurrentUser.user.userId,
        text: message.text,
        color: ColorConstants.lightPurple,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      )
    ],
  );
}
