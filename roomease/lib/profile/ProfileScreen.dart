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
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              profileSection(),
              UserStatusDropdown(),
              addCustomUserStatus(),
              logOutButton(context)
            ])));
  }
}

Widget profileSection() {
  return Row(
    children: [
      Padding(
          padding: EdgeInsets.only(left: 50),
          child: Image(
            image: AssetImage('assets/user_profile_icon.png'),
            height: 100,
            width: 100,
          )),
      Padding(
          padding: EdgeInsets.only(left: 30, right: 50),
          child: profileDetails())
    ],
  );
}

Widget profileDetails() {
  return Column(
    children: [
      Text(CurrentUser.getCurrentUserName()),
      Text("Member of: ${CurrentHousehold.getCurrentHouseholdName()}"),
      Text("Edit Information")
    ],
  );
}

Widget addCustomUserStatus() {
  return Padding(
      padding: EdgeInsets.only(left: 50),
      child: TextButton(
        child: Text("Add Custom Status"),
        onPressed: () async {
          // TODO: Add textfield and update status list
        },
      ));
}

Widget logOutButton(BuildContext context) {
  return Padding(
      padding: EdgeInsets.only(left: 50),
      child: TextButton(
          onPressed: () {
            SharedPreferencesUtility.clear();
            Navigator.pushNamedAndRemoveUntil(
                context, "/welcome", (_) => false);
          },
          child: Text("Log Out")));
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
    return Padding(
        padding: EdgeInsets.only(left: 50),
        child: Row(
          children: [
            Text("Current Status"),
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
        ));
  }
}
