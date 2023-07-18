import 'package:flutter/material.dart';
import 'colors/ColorConstants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
          backgroundColor: Color(0xFFCDB9F6),
        ),
        body: Column(children: [
          Spacer(),
          Center(
              child: TextField(
                  controller: _controller,
                  onSubmitted: (String value) async {},
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorConstants.lightGray,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorConstants.lightPurple)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorConstants.lightPurple)),
                      hintText: 'What would you like to ask Roomeo today?'),
                  cursorColor: ColorConstants.lightPurple)),
        ]));
  }
}
