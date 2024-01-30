import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/Roomeo/ChatScreen.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/profile/ProfileScreen.dart';

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
      ChatScreen(),
      ChatScreen(),
      ChoreScreen(),
      Profile()
    ];
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
                height: 50,
                width: 50),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/chat_icon.png'),
                height: 50,
                width: 50),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/schedule_icon.png'),
                height: 50,
                width: 50),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/chores_icon.png'),
                height: 50,
                width: 50),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image(
                image: AssetImage('assets/profile_icon.png'),
                height: 50,
                width: 50),
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
        body: Column(children: [HomeCards(updateIndex), statusList()]));
  }
}

class HomeCards extends StatelessWidget {
  final Function(int) updateIndex;
  HomeCards(this.updateIndex);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Padding(
            padding: EdgeInsets.only(top: 20),
            child: DatabaseManager.userNameStreamBuilder(
                CurrentUser.getCurrentUserId())),
        Padding(padding: EdgeInsets.only(top: 20), child: ChatCard(updateIndex))
      ],
    ));
  }
}

class ChatCard extends StatelessWidget {
  final Function(int) updateIndex;
  ChatCard(this.updateIndex);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          updateIndex(1);
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(children: [Text("Chat with Roomeo")]))));
  }
}

Widget statusList() {
  List<Widget> statusList = CurrentHousehold.householdStatusMap.entries
      .map((entry) => Row(children: [
            Text(entry.value[0]),
            Padding(
                padding: EdgeInsets.only(left: 50), child: Text(entry.value[1]))
          ]))
      .toList();
  statusList.insert(0, Row(children: [Text("Roommate Statuses")]));
  return Padding(
      padding: EdgeInsets.only(left: 50, right: 50, top: 50),
      child: Column(
        children: statusList,
      ));
}
