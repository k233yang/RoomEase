import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'package:roomease/colors/ColorConstants.dart';

class Profile extends StatefulWidget {
  @override
  State createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 40, bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(children: [
                profileSection(),
                Divider(indent: 20, endIndent: 20),
                userStatusSection(),
                Divider(indent: 20, endIndent: 20)
              ])),
              logOutButton(context)
            ])));
  }
}

Widget profileSection() {
  return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 50),
                child: Image(
                  image: AssetImage('assets/user_profile_icon.png'),
                  height: 100,
                  width: 100,
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.only(right: 50), child: profileDetails())
          ],
        ),
        Row(children: [
          Padding(
              padding: EdgeInsets.only(left: 40, top: 30),
              child: editProfileButton())
        ])
      ]));
}

Widget editProfileButton() {
  return OutlinedButton(
      onPressed: () {
        // TODO: add edit profile screen
      },
      child: Row(children: [
        Text("Edit Profile"),
        Padding(
            padding: EdgeInsets.only(left: 10),
            child: Image(
                image: AssetImage('assets/edit_icon.png'),
                height: 30,
                width: 30)),
      ]));
}

Widget profileDetails() {
  return Column(
    children: [
      Text(CurrentUser.getCurrentUserName()),
      Text("Member of: ${CurrentHousehold.getCurrentHouseholdName()}"),
      Text("Household Code: ${CurrentHousehold.getCurrentHouseholdId()}")
    ],
  );
}

Widget addCustomUserStatusButton() {
  return OutlinedButton(
    child: Text("Add Custom Status"),
    onPressed: () async {
      // TODO: Add textfield and update status list
    },
  );
}

Widget logOutButton(BuildContext context) {
  return Center(
      child: TextButton(
          onPressed: () {
            SharedPreferencesUtility.clear();
            Navigator.pushNamedAndRemoveUntil(
                context, "/welcome", (_) => false);
          },
          child: Text("Log Out")));
}

Widget userStatusSection() {
  return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Padding(
              padding: EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [UserStatusDropdown(), addCustomUserStatusButton()],
              ))
        ],
      ));
}

class UserStatusDropdown extends StatefulWidget {
  const UserStatusDropdown({super.key});

  @override
  State<UserStatusDropdown> createState() => _UserStatusDropdown();
}

class _UserStatusDropdown extends State<UserStatusDropdown> {
  String dropdownValue = CurrentUser.getCurrentUserStatusList().first;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 30),
            child: DropdownButton<String>(
              value: CurrentUser.getCurrentUserStatus(),
              items: CurrentUser.getCurrentUserStatusList()
                  .map<DropdownMenuItem<String>>((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dropdownValue = value!;
                });
                DatabaseManager.setUserCurrentStatus(
                    value!, CurrentUser.getCurrentUserId());
                CurrentUser.setCurrentUserStatus(value);
              },
            )),
      ],
    );
  }
}
