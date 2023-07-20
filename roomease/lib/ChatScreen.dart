import 'package:flutter/material.dart';
import 'colors/ColorConstants.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

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
              buildListMessage(messageList),
              Center(child: chatTextField()),
            ])));
  }

  Widget chatTextField() {
    return TextField(
        focusNode: textFieldFocusNode,
        controller: _controller,
        onSubmitted: (String value) async {
          messageList.add(Message(value, true, DateTime.now()));
          _controller.clear();
          textFieldFocusNode.requestFocus();
          setState(() {});
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

  Widget buildListMessage(List<Message> messages) {
    return Flexible(
        child: ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) => chatMessage(messages[index]),
    ));
  }

  Widget chatMessage(Message message) {
    MainAxisAlignment alignment;
    if (message.isSender) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }
    return Row(
      mainAxisAlignment: alignment,
      children: [
        BubbleSpecialThree(
          isSender: message.isSender,
          text: message.text,
          color: ColorConstants.lightPurple,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        )
      ],
    );
  }
}

class Message {
  String text;
  bool isSender;
  DateTime timestamp;

  Message(this.text, this.isSender, this.timestamp);
}
