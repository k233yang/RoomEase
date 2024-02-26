import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/ChatBoxGeneric.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import '../Message.dart';
import '../colors/ColorConstants.dart';
import 'package:roomease/Roomeo/Roomeo.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:roomease/Roomeo/missinginputs/UserCommandParamInputScreen.dart';
import 'package:roomease/Roomeo/missinginputs/MissingDateInput.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatRoomId});

  final String chatRoomId;

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
    // Scroll to the bottom when the widget is built
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // tap outside keyboard to unfocus it
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
        ),
      ),
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
            // add user + Roomeo response to the DB. Get the gptResponse message

            // TODO: PLEASE REFACTOR TO SCHEMATIC

            // below operations can be performed concurrently:
            late String userMessageKey;
            late String category;
            try {
              var results = await Future.wait([
                addUserInput(message,
                    dateTime), // add message to FB, get the key/ID for that message
                getCommandCategory(
                    message), // get the command category of the message
              ]);
              userMessageKey = results[0];
              // do some precautionary cleaning
              final pattern = RegExp(r'[a-zA-Z0-9 ]');
              category = results[1]
                  .split('')
                  .where((char) => pattern.hasMatch(char))
                  .join('');
              print('CATEGORY IS: $category');
            } catch (e) {
              print(
                  'Error occured adding message to Firebase or getting command category: $e');
            }

            if (isCommand(category)) {
              if (isParseableCommand(category)) {
                Map<String, String> commandParams =
                    await getCommandParameters(category, message);
                print("PARAMETERS ARE: $commandParams");
                // if there are missing params, navigate to UserCommandParamInputScreen
                // to prompt the user for the missing params
                if (commandParams.containsValue("Missing")) {
                  if (mounted) {
                    // Check if the widget is still in the tree
                    final result = await Navigator.of(context).push(
                      // Directly use context if it's valid
                      MaterialPageRoute(
                        builder: (context) => UserCommandParamInputScreen(
                          category: category,
                          commandParams: commandParams,
                          onParamsUpdated: (updatedParams) {
                            setState(() {
                              commandParams = updatedParams;
                            });
                          },
                        ),
                      ),
                    );
                    // if the user exited the UserCommandParamInputScreen, delete
                    // the most recent message, and we are done. It is no longer useful
                    if (result != null && result['exited'] == true) {
                      await DatabaseManager.removeMessageFromID(
                        CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                        userMessageKey,
                      );
                      return;
                    }
                  }
                }
                // replace the old message with this correct input:
                String fullCommandInput =
                    generateFullCommandInput(commandParams);
                await DatabaseManager.replaceMessage(
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  userMessageKey,
                  fullCommandInput,
                );
                // get Roomeo's response to the command
                await getRoomeoResponse(fullCommandInput, userMessageKey);
              }
              // view schedule doesn't need parameters, so we can just show it
              else if (category == 'View Schedule') {
                final localContext = context;
                if (mounted) {
                  Navigator.pushNamed(localContext, '/calendar');
                }
                // get Roomeo's response to the command
                await getRoomeoResponse(message, userMessageKey);
              }
            } else {
              await getRoomeoResponse(message, userMessageKey);
            }
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

// this thing gets the stream of messages
Widget buildListMessage(List<Message> messages) {
  return GroupedListView<Message, DateTime>(
    padding: const EdgeInsets.all(8),
    reverse: true,
    order: GroupedListOrder.DESC,
    floatingHeader: true,
    elements: messages,
    groupBy: (message) => DateTime(
        message.timestamp.year, message.timestamp.month, message.timestamp.day),
    groupHeaderBuilder: (Message message) => SizedBox(
      height: 40,
      child: Center(
        child: Card(
          color: ColorConstants.lightPurple,
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
    itemBuilder: (context, Message message) {
      return ChatBoxGeneric(message);
    },
  );
}
