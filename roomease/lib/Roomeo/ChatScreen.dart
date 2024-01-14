import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import '../Message.dart';
import '../User.dart';
import '../colors/ColorConstants.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:roomease/Roomeo/ChatGPTAPI.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';

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
          // add the user message to the database, and get the key for this user's message
          String? userMessageKey;
          try {
            userMessageKey = await DatabaseManager.addMessage("messageRoomId",
                Message(message, CurrentUser.getCurrentUser(), DateTime.now()));
          } catch (e) {
            print('Failed to add user message: $e');
          }
          //TODO: instead of local messagelist, pull list from DB and extract name to figure out
          //which side to display message on
          messageList.add(
              Message(message, CurrentUser.getCurrentUser(), DateTime.now()));
          _controller.clear();
          textFieldFocusNode.requestFocus();
          setState(() {});

          // get chatGPT's response to user's message, add response to database as well as get response's message key
          String? gptMessageKey;
          String? gptMessage;
          try {
            gptMessage = await getChatGPTResponse(message);
            try {
              gptMessageKey = await DatabaseManager.addMessage(
                  "messageRoomId",
                  Message(
                      gptMessage,
                      User("chatgpt", "useridchatgpt",
                          CurrentHousehold.getCurrentHouseholdId()),
                      DateTime.now())); // add chatGPT message to DB
            } catch (e) {
              print('Failed to add chatGPT message: $e');
            }
          } catch (e) {
            print('failed to get chatGPT response: e');
          }
          // fetch the user message's generated vector:
          List<double>? userResVector;
          try {
            userResVector = await getVectorEmbeddingArray(message);
            print(userResVector);
          } catch (e) {
            print('Failed to get user vector for input message: $message.');
            print(': $e');
          }
          // fetch chatGPT message's generated vector
          List<double>? chatGPTResVector;
          try {
            if (gptMessage != null) {
              chatGPTResVector = await getVectorEmbeddingArray(gptMessage);
              print(chatGPTResVector);
            }
          } catch (e) {
            print('Failed to get chatGPT vector for input message: $message.');
            print(': $e');
          }
          // TODO: put user message vector and chatbot's vector to vector DB:

          // userResVector.then((vector) => {
          //   insertVector(vector, "messageroomid" /*TODO: pinecone starter plan only supports 1 index. Need to upgrade plan, and replace roomID with actual room ID */
          //   , );
          // });
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
  if (message.sender.userId == CurrentUser.getCurrentUserId()) {
    alignment = MainAxisAlignment.end;
  } else {
    alignment = MainAxisAlignment.start;
  }
  return Row(
    mainAxisAlignment: alignment,
    children: [
      BubbleSpecialThree(
        isSender: message.sender.userId == CurrentUser.getCurrentUserId(),
        text: message.text,
        color: ColorConstants.lightPurple,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      )
    ],
  );
}
