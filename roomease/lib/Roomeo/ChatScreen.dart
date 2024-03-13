import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/ChatBoxGeneric.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import 'package:roomease/Roomeo/ChooseChoreScreen.dart';
import 'package:roomease/chores/ChoreStatus.dart';
import '../Message.dart';
import '../colors/ColorConstants.dart';
import 'package:roomease/Roomeo/Roomeo.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:roomease/Roomeo/missinginputs/UserCommandParamInputScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key, required this.messageRoomId, required this.userNames});

  final String messageRoomId;
  final List<String> userNames; // does not include current user

  @override
  State<ChatScreen> createState() => _ChatScreen(messageRoomId, userNames);
}

class _ChatScreen extends State<ChatScreen> {
  _ChatScreen(this.messageRoomId, this.userNames);
  late TextEditingController _controller;
  final messageList = <Message>[];
  late FocusNode textFieldFocusNode;
  final String messageRoomId;
  final List<String> userNames;
  bool isConversationWithRoomeo = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    textFieldFocusNode = FocusNode();
    // Scroll to the bottom when the widget is built
    isConversationWithRoomeo = userNames.join() == "Roomeo";
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
          title: Text("Chat with ${userNames.join(" ")}"),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Column(
          children: [
            Expanded(
                child: DatabaseManager.messagesStreamBuilder(messageRoomId)),
            Container(
              color: ColorConstants.white,
              child: chatTextField(userNames.join(" ")),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatTextField(String userNames) {
    String hintText = "What would you like to ask Roomeo today?";
    if (userNames != "Roomeo") {
      hintText = "Enter your message";
    }
    return TextField(
        focusNode: textFieldFocusNode,
        controller: _controller,
        onSubmitted: handleMessageSubmit,
        decoration: InputDecoration(
            filled: true,
            fillColor: ColorConstants.lightGray,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstants.lightPurple)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstants.lightPurple)),
            hintText: hintText),
        cursorColor: ColorConstants.lightPurple);
  }

  Future<void> handleMessageSubmit(String message) async {
    if (message != "") {
      // add the user message to the database
      DateTime dateTime = DateTime.now();
      messageList.add(Message(message, CurrentUser.getCurrentUserId(),
          CurrentUser.getCurrentUserName(), dateTime));
      _controller.clear();
      textFieldFocusNode.requestFocus();
      setState(() {});
      if (!isConversationWithRoomeo) {
        DatabaseManager.addMessage(
            messageRoomId,
            Message(message, CurrentUser.getCurrentUserId(),
                CurrentUser.getCurrentUserName(), dateTime));
        setState(() {});
      } else {
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
            // Navigate to the command paramater input screen
            if (mounted) {
              // Check if the widget is still in the tree
              final result = await Navigator.of(context).push(
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

            if (category == 'Add Chore') {
              print('ADDING CHORE');
              // replace the old message with this correct input:
              String fullCommandInput = generateFullCommandInput(commandParams);
              await DatabaseManager.replaceMessage(
                CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                userMessageKey,
                fullCommandInput,
              );
              // add the chore to the chore DB in FB
              String choreId = await DatabaseManager.addChore(
                  CurrentHousehold.getCurrentHouseholdId(),
                  commandParams['ChoreTitle']!,
                  commandParams['ChoreDescription']! == 'Missing'
                      ? ''
                      : commandParams['ChoreDescription']!,
                  commandParams['ChoreDate']!,
                  DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime),
                  DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime),
                  int.parse(commandParams['ChorePoints']!),
                  1,
                  0,
                  0,
                  CurrentUser.getCurrentUserId(),
                  null,
                  ChoreStatus.toDo.value);
              // add the chore message to the chatroom in FB, as well as the
              // chatroom and chore indices in the VDB
              await getRoomeoResponse(fullCommandInput, userMessageKey,
                  isChore: true, choreId: choreId);
            } else if (category == 'Update Chore') {
              // The title of the chore to be updated should be found
              List<String> topChores =
                  await queryChores(commandParams['ChoreTitle']!);
              if (mounted) {
                final result = await Navigator.of(context).push(
                  // Directly use context if it's valid
                  MaterialPageRoute(
                    builder: (context) => ChooseChoreScreen(
                      choreIds: topChores,
                      placeholder: "Select a chore to update",
                      onChoreSelect: (String selectedChore) {},
                      messageId: userMessageKey,
                      shouldUpdate: true,
                    ),
                  ),
                );
                // if the user backed out of the select chore screen, delete their message
                if (result != null && result['exited'] == true) {
                  await DatabaseManager.removeMessageFromID(
                    CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                    userMessageKey,
                  );
                  return;
                }
              } // Check if the widget is still in the tree
            } else if (category == 'Remove Chore') {
              List<String> topChores =
                  await queryChores(commandParams['ChoreTitle']!);
              if (mounted) {
                final result = await Navigator.of(context).push(
                  // Directly use context if it's valid
                  MaterialPageRoute(
                    builder: (context) => ChooseChoreScreen(
                      choreIds: topChores,
                      placeholder: "Select a chore to remove",
                      onChoreSelect: (String selectedChore) {},
                      messageId: userMessageKey,
                      shouldRemove: true,
                    ),
                  ),
                );
                // if the user backed out of the select chore screen, delete their message
                if (result != null && result['exited'] == true) {
                  await DatabaseManager.removeMessageFromID(
                    CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                    userMessageKey,
                  );
                  return;
                }
              }
            } else if (category == 'View Status') {
              print("VIEW STATUS PARAMS ARE: $commandParams");
              String viewPerson = commandParams['ViewPerson']!;
              String? viewPersonId =
                  await DatabaseManager.getUserIdByName(viewPerson);
              String viewPersonStatus =
                  await DatabaseManager.getUserCurrentStatus(viewPersonId!);
              String viewStatusMessage = "What's $viewPerson's status?";
              String roomeoMessage =
                  "$viewPerson's status is currently '$viewPersonStatus'";
              var results = await Future.wait([
                getVectorEmbeddingArray(viewStatusMessage),
                getVectorEmbeddingArray(roomeoMessage),
              ]);
              List<double> viewStatusMessageVector = results[0];
              List<double> roomeoMessageVector = results[1];
              await DatabaseManager.replaceMessage(
                CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                userMessageKey,
                viewStatusMessage,
              );
              String gptMessageKey = await DatabaseManager.addMessage(
                messageRoomId,
                Message(
                  roomeoMessage,
                  RoomeoUser.user.userId,
                  RoomeoUser.user.name,
                  DateTime.now(),
                ),
              );
              await Future.wait([
                insertVector(
                  viewStatusMessageVector,
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  userMessageKey,
                ),
                insertVector(
                  roomeoMessageVector,
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  gptMessageKey,
                ),
              ]);
            } else if (category == 'Set Status') {
              String status = commandParams["Status"]!;
              print('ROOMEO SETTING STATUS TO: $status');
              // set the actual status
              CurrentUser.setCurrentUserStatus(status);
              // message room stuff:
              String setStatusMessage = "Set my status to '$status'";
              String roomeoMessage =
                  "Got it, I've set your current status to '$status'";
              var results = await Future.wait([
                getVectorEmbeddingArray(setStatusMessage),
                getVectorEmbeddingArray(roomeoMessage),
              ]);
              List<double> setStatusMessageVector = results[0];
              List<double> roomeoMessageVector = results[1];
              await DatabaseManager.replaceMessage(
                CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                userMessageKey,
                setStatusMessage,
              );
              String gptMessageKey = await DatabaseManager.addMessage(
                messageRoomId,
                Message(
                  roomeoMessage,
                  RoomeoUser.user.userId,
                  RoomeoUser.user.name,
                  DateTime.now(),
                ),
              );
              await Future.wait([
                insertVector(
                  setStatusMessageVector,
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  userMessageKey,
                ),
                insertVector(
                  roomeoMessageVector,
                  CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                  gptMessageKey,
                ),
              ]);
            } else if (category == 'Send a Message') {
              // send the actual message to the user
              String? sendPersonId = await DatabaseManager.getUserIdByName(
                  commandParams["SendPerson"]!);
              String message = commandParams["Message"]!;
              String messageRoomId = "";
              String possibleMessageRoomId_1 =
                  sendPersonId! + CurrentUser.getCurrentUserId();
              String possibleMessageRoomId_2 =
                  CurrentUser.getCurrentUserId() + sendPersonId;
              if (await DatabaseManager.doesMessageRoomExist(
                  possibleMessageRoomId_1)) {
                messageRoomId = possibleMessageRoomId_1;
              } else if (await DatabaseManager.doesMessageRoomExist(
                  possibleMessageRoomId_2)) {
                messageRoomId = possibleMessageRoomId_2;
              } else {
                // create the new message room for the user and recipient
                // if the room does not exist
                messageRoomId = CurrentUser.getCurrentUserId() + sendPersonId;
                await DatabaseManager.addMessageRoomWithList(
                    [CurrentUser.getCurrentUserId(), sendPersonId]);
                await DatabaseManager.addMessageRoomIdToUser(
                    CurrentUser.getCurrentUserId(), messageRoomId);
                await DatabaseManager.addMessageRoomIdToUser(
                    sendPersonId, messageRoomId);
              }
              await DatabaseManager.addMessage(
                messageRoomId,
                Message(
                  message,
                  CurrentUser.getCurrentUserId(),
                  CurrentUser.getCurrentUserName(),
                  DateTime.now(),
                ),
              );
              await getRoomeoResponse(
                  "Send the message: '$message' to ${commandParams["SendPerson"]}",
                  userMessageKey,
                  shouldQueryHouseholdsInstead: true);
              await DatabaseManager.replaceMessage(
                CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                userMessageKey,
                "Send the message: '$message' to ${commandParams["SendPerson"]}",
              );
            }
          } else if (category == 'View Schedule') {
            final localContext = context;
            if (mounted) {
              Navigator.pushNamed(localContext, '/calendar');
            }
            // get Roomeo's response to the command
            await getRoomeoResponse(message, userMessageKey);
          }
        }
        // view schedule doesn't need parameters, so we can just go to the calendar page
        else {
          await getRoomeoResponse(message, userMessageKey);
        }
      }
    }
  }
}

// this thing gets the stream of messages
Widget buildListMessage(List<Message> messages) {
  return GroupedListView<Message, DateTime>(
    padding: const EdgeInsets.all(8),
    reverse: true,
    order: GroupedListOrder.DESC,
    itemComparator: (a, b) => a.timestamp.compareTo(b.timestamp),
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
