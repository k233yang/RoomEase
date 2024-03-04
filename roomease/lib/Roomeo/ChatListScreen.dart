import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/ChatScreen.dart';
import 'package:roomease/Roomeo/NewMessageRoomScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              children: [chatRow("Roomeo"), chatRow("Dave"), chatRow("Mark")],
            )),
        floatingActionButton: FloatingActionButton(
            foregroundColor: ColorConstants.white,
            backgroundColor: ColorConstants.lightPurple,
            shape: CircleBorder(),
            onPressed: () async {
              String householdId = CurrentHousehold.getCurrentHouseholdId();
              var userIds =
                  await DatabaseManager.getUserIdsFromHousehold(householdId);
              var userNames =
                  await DatabaseManager.getUserNamesFromHousehold(householdId);
              userIds.remove(CurrentUser.getCurrentUserId());
              userNames.remove(CurrentUser.getCurrentUserName());
              var messageRoomIds = await DatabaseManager.getUserMessageRoomIds(
                  CurrentUser.getCurrentUserId());
              //DatabaseManager.getUsersFromMessageRoom(userId, excludeCurrentUser=true)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewMessageRoomScreen(
                    roommateUserIds: userIds,
                    roommateUserNames: userNames,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add)));
  }

  Widget chatRow(String name) {
    return InkWell(
        onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chatRoomId: ""),
                ),
              )
            },
        child: Column(children: [
          Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Row(
                children: [
                  Image(
                      image: AssetImage('assets/user_profile_icon_purple.png'),
                      width: 40,
                      height: 40),
                  Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(style: TextStyle(fontSize: 15), name))
                ],
              )),
          Divider(indent: 10, endIndent: 10)
        ]));
  }
}
