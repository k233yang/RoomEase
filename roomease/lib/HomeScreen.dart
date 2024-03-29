import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/Roomeo/ChatListScreen.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/profile/EditProfileScreen.dart';
import 'package:roomease/profile/ProfileScreen.dart';

import 'calendar/CalendarScreen.dart';
import 'chores/ChoreScreen.dart';

class Home extends StatefulWidget {
  @override
  State createState() {
    return _HomeState();
  }
}

class _HomeState extends State {
  int _currentIndex = 0;
  List _children = [];
  @override
  void initState() {
    _children = [
      HomeScreen(updateIndex),
      ChatListScreen(),
      CalendarScreen(),
      ChoreScreen(),
      Profile()
    ];
    DatabaseManager.householdUserIdSubscription(
        CurrentHousehold.getCurrentHouseholdId());
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/home_icon.png'),
                height: 40,
                width: 40),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/chat_icon.png'),
                height: 40,
                width: 40),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/schedule_icon.png'),
                height: 40,
                width: 40),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/chores_icon.png'),
                height: 40,
                width: 40),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/profile_icon.png'),
                height: 40,
                width: 40),
            label: "",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorConstants.lightPurple,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(int) updateIndex;
  HomeScreen(this.updateIndex);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          welcomeSection(),
          Divider(indent: 20, endIndent: 20),
          statusList(updateIndex),
          Divider(indent: 20, endIndent: 20),
          quickActions(updateIndex)
        ])));
  }
}

Widget welcomeSection() {
  return Center(
      child: Column(
    children: [
      Padding(
          padding: EdgeInsets.only(top: 20),
          child: Image(
            image: AssetImage(
                iconNumberMapping(CurrentUser.getCurrentUserIconNumber())),
            height: 150,
            width: 150,
          )),
      Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: DatabaseManager.userNameStreamBuilder(
              CurrentUser.getCurrentUserId())),
    ],
  ));
}

Widget quickActions(Function(int) updateIndex) {
  return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 40),
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Quick Actions",
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 20))),
          actionCard(
              updateIndex, 1, "Chat With Roomeo", "assets/roomeo_icon.png"),
          actionCard(
              updateIndex, 2, "View Calendar", "assets/schedule_icon.png"),
          actionCard(updateIndex, 3, "View Chores", "assets/chores_icon.png")
        ],
      ));
}

Widget actionCard(
    Function(int) updateIndex, int index, String text, String assetUrl) {
  return TextButton(
      onPressed: () {
        updateIndex(index);
      },
      style: TextButton.styleFrom(backgroundColor: ColorConstants.lightPurple),
      child: SizedBox(
        width: 300,
        child: Row(
          children: [
            Text(text),
            Spacer(),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Image(
                  width: 20,
                  height: 20,
                  image: AssetImage(assetUrl),
                ))
          ],
        ),
      ));
}

Widget statusList(updateIndex) {
  return Padding(
      padding: EdgeInsets.only(top: 30, bottom: 30),
      child: Column(children: [
        ValueListenableBuilder(
            valueListenable: CurrentHousehold.householdStatusValueListener,
            builder: (context, value, child) {
              if (value.entries.isNotEmpty) {
                List<Widget> statusList = value.values
                    .map((entry) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      style: TextStyle(fontSize: 15),
                                      entry["name"]!)),
                              SizedBox(
                                  width: 90,
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(
                                          style: TextStyle(fontSize: 15),
                                          '${entry["totalPoints"]!} points'))),
                              SizedBox(
                                  width: 100,
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(
                                          style: TextStyle(fontSize: 15),
                                          entry["status"]!))),
                            ]))
                    .toList();
                statusList.insert(
                    0,
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                          width: 100,
                          child: Text(
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              'Roommates')),
                      SizedBox(
                          width: 90,
                          child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  'Points'))),
                      SizedBox(
                          width: 100,
                          child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  'Status')))
                    ]));
                return Padding(
                  padding: EdgeInsets.only(left: 50, right: 50, top: 10),
                  child: Column(
                    children: statusList,
                  ),
                );
              } else {
                return Column(children: [
                  Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                            color: ColorConstants.lightPurple),
                      )),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Loading Roommate Statuses...'),
                  ),
                ]);
              }
            }),
        Padding(
            padding: EdgeInsets.only(top: 20),
            child: OutlinedButton(
                child: Text("Update Your Status"),
                onPressed: () {
                  updateIndex(4);
                }))
      ]));
}
