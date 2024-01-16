import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/MessageRoom.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';

import '../User.dart';

class CreateHousehold extends StatefulWidget {
  @override
  State createState() {
    return _CreateHousehold();
  }
}

class _CreateHousehold extends State<CreateHousehold> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController householdNameController = TextEditingController();

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
                  controller: householdNameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Household Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your household name';
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
                        DatabaseManager.addUser(CurrentUser.getCurrentUser());
                        DatabaseManager.getUserName(
                            CurrentUser.getCurrentUserId());
                        // Add household should add household to CurrentHousehold
                        await DatabaseManager.addHousehold(
                            CurrentUser.getCurrentUser(),
                            householdNameController.text);
                        CurrentHousehold.setCurrentHouseholdName(
                            householdNameController.text);
                        //TODO: add multiple chat rooms
                        DatabaseManager.addMessageRoom(MessageRoom(
                            CurrentUser.getCurrentUserId() +
                                RoomeoUser.user.userId,
                            [],
                            <User>[
                              CurrentUser.getCurrentUser(),
                              RoomeoUser.user
                            ]));
                        DatabaseManager.addMessageRoomIdToUser(
                            CurrentUser.getCurrentUserId(),
                            CurrentUser.getCurrentUserId() +
                                RoomeoUser.user.userId);
                        CurrentUser.setCurrentMessageRoomIds([
                          CurrentUser.getCurrentUserId() +
                              RoomeoUser.user.userId
                        ]);
                        DatabaseManager.addHouseholdToUser(
                            CurrentUser.getCurrentUser().userId,
                            CurrentHousehold.getCurrentHouseholdId());
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (_) => false);
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
