import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/profile/EditProfileScreen.dart';
import 'package:flutter/services.dart';

class Profile extends StatefulWidget {
  @override
  State createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  void pushEditProfile(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/editProfile", (_) => true)
        .then((value) => setState(() {}));
  }

  void pushAddStatus(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/addCustomStatus", (_) => true)
        .then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 40, bottom: 20),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Column(children: [
                    profileSection(context),
                    Divider(indent: 20, endIndent: 20),
                    userStatusSection(context),
                    Divider(indent: 20, endIndent: 20)
                  ]),
                  logOutButton(context),
                  deleteHouseholdButton(context)
                ]))));
  }

  Widget profileSection(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Image(
                    image: AssetImage(iconNumberMapping(
                        CurrentUser.getCurrentUserIconNumber())),
                    height: 100,
                    width: 100,
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 20), child: profileDetails())
            ],
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: editProfileButton(context))
              ])
        ]));
  }

  Widget editProfileButton(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          pushEditProfile(context);
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(CurrentUser.getCurrentUserName(),
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Member of: ${CurrentHousehold.getCurrentHouseholdName()}"),
        Text(
            "Total points: ${CurrentUser.getCurrentUserTotalPoints().toString()}"),
        Row(children: [
          Text("Household Code: ${CurrentHousehold.getCurrentHouseholdId()}"),
          SizedBox(
              width: 25,
              height: 20,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Image.asset('assets/copy_icon.png',
                      width: 20, height: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(
                        text: CurrentHousehold.getCurrentHouseholdId()));
                  }))
        ])
      ],
    );
  }

  Widget addCustomUserStatusButton(BuildContext context) {
    return OutlinedButton(
        child: Text("Add Custom Status"),
        onPressed: () {
          pushAddStatus(context);
        });
  }

  Widget logOutButton(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: TextButton(
                onPressed: () {
                  SharedPreferencesUtility.clear();
                  CurrentUser.userMessageRoomValueListener.value = {};
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/welcome", (_) => false);
                },
                child: Text("Log Out"))));
  }

  Widget deleteHouseholdButton(BuildContext context) {
    return Center(
        child: TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("Delete Household"),
                        content:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                              "Are you sure you would like to delete this household?",
                              textAlign: TextAlign.center),
                          Text(""),
                          Text("This action cannot be undone.",
                              textAlign: TextAlign.center),
                        ]),
                        actions: [
                          TextButton(
                              onPressed: () {
                                try {
                                  DatabaseManager.deleteCurrentHousehold();
                                } catch (e) {
                                  print("Failed to delete household: $e");
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text('Household deleted!')));
                                Navigator.pop(context);
                                SharedPreferencesUtility.clear();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/welcome", (_) => false);
                              },
                              child: Text("Yes, delete",
                                  style: TextStyle(color: Colors.red))),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No, return"))
                        ]);
                  });
            },
            child:
                Text("Delete Household", style: TextStyle(color: Colors.red))));
  }

  Widget userStatusSection(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserStatusDropdown(),
                    addCustomUserStatusButton(context)
                  ],
                ))
          ],
        ));
  }
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
