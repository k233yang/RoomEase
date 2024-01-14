import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/HomeScreen.dart';
import 'package:roomease/MessageRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../User.dart' as RUser;

class JoinHousehold extends StatefulWidget {
  @override
  State createState() {
    return _JoinHousehold();
  }
}

class _JoinHousehold extends State<JoinHousehold> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController householdCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RoomEase"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: householdCodeController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Household Code"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a household code';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool householdExists =
                            await DatabaseManager.checkHouseholdExists(
                                householdCodeController.text);
                        if (householdExists) {
                          DatabaseManager.addUser(CurrentUser.getCurrentUser());
                          DatabaseManager.joinHousehold(
                              CurrentUser.getCurrentUser(),
                              householdCodeController.text);
                          //TODO: add multiple chat rooms
                          DatabaseManager.addMessageRoom(
                              MessageRoom("messageRoomId", [], <RUser.User>[
                            CurrentUser.getCurrentUser(),
                            RUser.User("chatgpt", "useridchatgpt",
                                householdCodeController.text)
                          ]));
                          CurrentHousehold.setCurrentHouseholdId(
                              householdCodeController.text);
                          DatabaseManager.updateHouseholdName(
                              householdCodeController.text);
                          DatabaseManager.addHouseholdToUser(
                              CurrentUser.getCurrentUser().userId,
                              householdCodeController.text);
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/home", (_) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Household does not exist')));
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
