import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/ChatScreen.dart';
import 'package:roomease/Roomeo/NewMessageRoomScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/profile/EditProfileScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen> {
  @override
  void initState() {
    DatabaseManager.userMessageRoomSubscription(CurrentUser.getCurrentUserId());
    super.initState();
  }

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
              children: [
                ValueListenableBuilder(
                    valueListenable: CurrentUser.userMessageRoomValueListener,
                    builder: (context, value, child) {
                      if (value.entries.isNotEmpty) {
                        List<String> userIds = [];
                        List<String> userNames = [];
                        value.values.map((entry) {
                          entry.map((e) {
                            userIds.add(e["id"] as String);
                            userNames.add(e["name"] as String);
                          });
                        });
                        List<Widget> messageRoomList = value.entries
                            .map((entry) => chatRow(entry.value, entry.key))
                            .toList();
                        return Column(
                          children: messageRoomList,
                        );
                      } else {
                        return Column(children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                                color: ColorConstants.lightPurple),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Loading Chats...'),
                          ),
                        ]);
                      }
                    })
              ],
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

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewMessageRoomScreen(
                    roommateUserIds: userIds,
                    roommateUserNames: userNames,
                  ),
                ),
              ).then((value) => setState(() {
                    DatabaseManager.userMessageRoomSubscription(
                        CurrentUser.getCurrentUserId());
                  }));
            },
            child: const Icon(Icons.add)));
  }

  Widget chatRow(List<Map<String, String>> entry, String messageRoomId) {
    String userid = "";
    if (entry.length == 1) {
      userid = entry[0]["id"] as String;
    }
    List<String> userNames = [];
    entry.forEach((element) {
      userNames.add(element["name"] as String);
    });
    return InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                  messageRoomId: messageRoomId, userNames: userNames),
            ),
          );
        },
        child: Column(children: [
          Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Row(
                children: [
                  FutureBuilder<int>(
                    future: DatabaseManager.getUserCurrentIconNumber(userid),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Image(
                              image: AssetImage(
                                  'assets/user_profile_icon_purple.png'),
                              width: 40,
                              height: 40);
                        case ConnectionState.waiting:
                          return Image(
                              image: AssetImage(
                                  'assets/user_profile_icon_purple.png'),
                              width: 40,
                              height: 40);
                        default:
                          if (snapshot.hasData) {
                            return Image(
                                image: AssetImage(
                                    iconNumberMapping(snapshot.data!)),
                                width: 40,
                                height: 40);
                          } else {
                            return Image(
                                image: AssetImage(
                                    'assets/user_profile_icon_purple.png'),
                                width: 40,
                                height: 40);
                          }
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                        style: TextStyle(fontSize: 15),
                        entry
                            .map((e) => e["name"] as String)
                            .toList()
                            .join(",")),
                  )
                ],
              )),
          Divider(indent: 10, endIndent: 10)
        ]));
  }
}
