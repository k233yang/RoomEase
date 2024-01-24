import 'package:flutter/material.dart';
import 'package:pinecone/pinecone.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import '../Message.dart';
import '../User.dart';
import '../colors/ColorConstants.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:roomease/Roomeo/ChatGPTAPI.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';
import '../Errors.dart';

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
              DatabaseManager.messagesStreamBuilder(
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId),
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
            userMessageKey = await DatabaseManager.addMessage(
                CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                Message(message, CurrentUser.getCurrentUserId(),
                    CurrentUser.getCurrentUserName(), DateTime.now()));
          } catch (e) {
            print('Failed to add user message: $e');
          }
          //TODO: instead of local messagelist, pull list from DB and extract name to figure out
          //which side to display message on
          messageList.add(Message(message, CurrentUser.getCurrentUserId(),
              CurrentUser.getCurrentUserName(), DateTime.now()));
          _controller.clear();
          textFieldFocusNode.requestFocus();
          setState(() {});

          // fetch the user message's generated vector:
          List<double>? userResVector;
          try {
            userResVector = await getVectorEmbeddingArray(message);
            print(userResVector);
          } catch (e) {
            print('Failed to get user vector for input message: $message.');
            print(': $e');
          }
          //Query the vDB, then firebase for most relevant convos, and feed that info to chatGPT as context
          List<Message> contextMessageList = [];
          try {
            if (userResVector != null) {
              List<String> messageIDList = await fetchTopMessages(
                  userResVector,
                  CurrentUser.getCurrentUserId() +
                      RoomeoUser.user
                          .userId); // contains the firebase ID's for the messages
              messageIDList.sort((a, b) => a.compareTo(b));
              for (var i = 0; i < messageIDList.length; i++) {
                Message res = await DatabaseManager.getMessageFromID(
                    CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                    messageIDList[i]);
                contextMessageList.add(res);
                print('message $i: ${res.text}');
              }
            } else {
              throw NullObjectError(
                  'Querying vector DB failed: null user response vector!');
            }
          } catch (e) {
            print(e);
          }
          print('Fetched firebase stuff');
          // put user message vector to vector DB
          try {
            if (userResVector != null && userMessageKey != null) {
              await insertVector(
                  userResVector,
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  userMessageKey);
            } else {
              if (userResVector == null) {
                throw NullObjectError(
                    'Insertion into vector DB failed: null user response vector!');
              }
              if (userMessageKey == null) {
                throw NullObjectError(
                    'Insertion into vector DB failed: null user message key!');
              }
            }
          } catch (e) {
            print(e);
          }
          // get chatGPT's response to user's message, add response to firebase as well as get response's message key
          String? chatGPTMessageKey;
          String? chatGPTMessage;
          try {
            chatGPTMessage =
                await getChatGPTResponse(message, contextMessageList);
            try {
              chatGPTMessageKey = await DatabaseManager.addMessage(
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  Message(
                      chatGPTMessage,
                      RoomeoUser.user.userId,
                      RoomeoUser.user.name,
                      DateTime.now())); // add chatGPT message to DB
            } catch (e) {
              print('Failed to add chatGPT message to firebase: $e');
            }
          } catch (e) {
            print('failed to get chatGPT response: $e');
          }
          // fetch chatGPT message's generated vector
          List<double>? chatGPTResVector;
          try {
            if (chatGPTMessage != null) {
              chatGPTResVector = await getVectorEmbeddingArray(chatGPTMessage);
              print(chatGPTResVector);
            } else {
              throw NullObjectError('Null gptMessage!');
            }
          } catch (e) {
            print('Failed to get chatGPT vector for input message: $message.');
            print(': $e');
          }
          // put chatGPT vector into DB:
          try {
            if (chatGPTResVector != null && chatGPTMessageKey != null) {
              await insertVector(
                  chatGPTResVector,
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  chatGPTMessageKey);
            } else {
              if (userResVector == null) {
                throw NullObjectError(
                    'Insertion into vector DB failed: null chatGPT response vector!');
              }
              if (userMessageKey == null) {
                throw NullObjectError(
                    'Insertion into vector DB failed: null chatGPT message key!');
              }
            }
          } catch (e) {
            print(e);
          }
          // Testing categorizing message
          String category = await selectOption(message);
          print(category);
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
  if (message.senderId == CurrentUser.getCurrentUserId()) {
    alignment = MainAxisAlignment.end;
  } else {
    alignment = MainAxisAlignment.start;
  }
  return Row(
    mainAxisAlignment: alignment,
    children: [
      BubbleSpecialThree(
        isSender: message.senderId == CurrentUser.getCurrentUserId(),
        text: message.text,
        color: ColorConstants.lightPurple,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      )
    ],
  );
}
