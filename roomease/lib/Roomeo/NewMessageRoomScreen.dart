import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/MessageRoom.dart';
import 'package:roomease/colors/ColorConstants.dart';

class NewMessageRoomScreen extends StatefulWidget {
  const NewMessageRoomScreen(
      {super.key,
      required this.roommateUserIds,
      required this.roommateUserNames});

  final List<String> roommateUserIds;
  final List<String> roommateUserNames;

  @override
  State<NewMessageRoomScreen> createState() => _NewMessageRoomScreen(
      roommateUserIds: roommateUserIds, roommateUserNames: roommateUserNames);
}

class _NewMessageRoomScreen extends State<NewMessageRoomScreen> {
  _NewMessageRoomScreen(
      {required this.roommateUserIds, required this.roommateUserNames});
  bool isRoommateSelected = false;
  int selectedIndex = -1;

  final List<String> roommateUserIds;
  final List<String> roommateUserNames;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Select one of your roommates to start messaging",
                      style: TextStyle(fontSize: 15),
                    )),
                if (roommateUserNames.isEmpty)
                  Text("You have no roommates to start a chat with.")
                else
                  for (var i = 0; i < roommateUserNames.length; i++)
                    roommateRow(roommateUserNames.elementAt(i), i),
                if (isRoommateSelected)
                  TextButton(
                      onPressed: () async {
                        await DatabaseManager.addMessageRoomWithList([
                          CurrentUser.getCurrentUserId(),
                          roommateUserIds.elementAt(selectedIndex)
                        ]);
                        await DatabaseManager.addMessageRoomIdToUser(
                            CurrentUser.getCurrentUserId(),
                            CurrentUser.getCurrentUserId() +
                                roommateUserIds.elementAt(selectedIndex));
                        await DatabaseManager.addMessageRoomIdToUser(
                            roommateUserIds.elementAt(selectedIndex),
                            CurrentUser.getCurrentUserId() +
                                roommateUserIds.elementAt(selectedIndex));
                        Navigator.pop(context, true);
                      },
                      child: Text("Continue"))
              ],
            )));
  }

  Widget roommateRow(String name, int index) {
    Color outlineColor =
        selectedIndex == index ? Colors.black : Colors.transparent;
    Icon addSubtractIcon =
        selectedIndex == index ? Icon(Icons.remove) : Icon(Icons.add);
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: outlineColor, width: 1),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 15), child: Text(name)),
            Spacer(),
            IconButton(
                onPressed: () {
                  setState(() {
                    if (isRoommateSelected) {
                      selectedIndex = -1;
                    } else {
                      selectedIndex = index;
                    }
                    isRoommateSelected = !isRoommateSelected;
                  });
                },
                icon: addSubtractIcon)
          ],
        ));
  }
}
