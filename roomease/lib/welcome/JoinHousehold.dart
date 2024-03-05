import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/MessageRoom.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
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
                          await updateUserInformation();
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

  Future<void> updateUserInformation() async {
    String userId = CurrentUser.getCurrentUserId();

    DatabaseManager.addUser(userId, CurrentUser.getCurrentUserName());
    DatabaseManager.joinHousehold(
        CurrentUser.getCurrentUser(), householdCodeController.text);

    // Update user message rooms
    DatabaseManager.addMessageRoom(MessageRoom(userId + RoomeoUser.user.userId,
        [], <RUser.User>[CurrentUser.getCurrentUser(), RoomeoUser.user]));
    DatabaseManager.addMessageRoomIdToUser(
        CurrentUser.getCurrentUserId(), userId + RoomeoUser.user.userId);
    CurrentUser.setCurrentMessageRoomIds([userId + RoomeoUser.user.userId]);

    // Update user household
    CurrentHousehold.setCurrentHouseholdId(householdCodeController.text);
    String householdName =
        await DatabaseManager.getHouseholdName(householdCodeController.text);
    CurrentHousehold.setCurrentHouseholdName(householdName);
    DatabaseManager.addHouseholdToUser(userId, householdCodeController.text);

    // Update user status
    await DatabaseManager.addStatusToUserStatusList("Home", userId);
    await DatabaseManager.addStatusToUserStatusList("Away", userId);
    DatabaseManager.setUserCurrentStatus("Home", userId);
    CurrentUser.setCurrentUserStatusList(["Home", "Away"]);
    CurrentUser.setCurrentUserStatus("Home");

    // User icon
    CurrentUser.setCurrentUserIconNumber(1);
    DatabaseManager.setUserCurrentIconNumber(userId, 1);

    // add the new user in the shared household DB
    await insertVector(
        await getVectorEmbeddingArray(CurrentUser.getCurrentUserName()),
        CurrentHousehold.getCurrentHouseholdId(),
        CurrentUser.getCurrentUserId(),
        metadata: {"isPerson": true});
  }
}
