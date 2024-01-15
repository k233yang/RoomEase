import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/welcome/JoinHousehold.dart';

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
            child: Column(
                children: [profileSection(), logOutButton(context)],
                crossAxisAlignment: CrossAxisAlignment.start)));
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
            )
          ),
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

Widget logOutButton(BuildContext context) {
  return TextButton(
      onPressed: () {
        SharedPreferencesUtility.clear();
        Navigator.pushNamedAndRemoveUntil(context, "/welcome", (_) => false);
      },
      child: Text("Log Out"));
}
