import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/MessageRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import '../User.dart' as RUser;

class Login extends StatefulWidget {
  @override
  State createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

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
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
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
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                          if (user != null) {
                            //Sets user's name
                            DatabaseManager.getUserName(user.user!.uid);
                            CurrentUser.setCurrentUserId(user.user!.uid);
                            // Checking if user is part of a household yet
                            String? householdId =
                                await DatabaseManager.getUsersHousehold(
                                    user.user!.uid);
                            if (householdId != null) {
                              // Part of household, go to home screen
                              updateUserInformation(
                                  householdId, user.user!.uid);
                              SharedPreferencesUtility.setValue(
                                  "isLoggedIn", true);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/home", (_) => false);
                            } else {
                              // Not part of household, go to create/join household screen
                              Navigator.pushNamedAndRemoveUntil(context,
                                  "/createJoinHousehold", (_) => false);
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Email or password is incorrect')),
                          );
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email or password is incorrect')),
                        );
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

  void updateUserInformation(String householdId, String userId) async {
    // Update user message rooms
    List<String>? messageRoomIds =
        await DatabaseManager.getUserMessageRoomIds(userId);
    if (messageRoomIds != null) {
      CurrentUser.setCurrentMessageRoomIds(messageRoomIds);
    } else {
      // Add message room for older users that don't have an entry in the DB
      DatabaseManager.addMessageRoom(MessageRoom(
          CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
          [],
          <RUser.User>[CurrentUser.getCurrentUser(), RoomeoUser.user]));
      DatabaseManager.addMessageRoomIdToUser(
          userId, CurrentUser.getCurrentUserId() + RoomeoUser.user.userId);
      CurrentUser.setCurrentMessageRoomIds(
          [CurrentUser.getCurrentUserId() + RoomeoUser.user.userId]);
    }

    // Update user household
    CurrentHousehold.setCurrentHouseholdId(householdId);
    String householdName = await DatabaseManager.getHouseholdName(householdId);
    CurrentHousehold.setCurrentHouseholdName(householdName);

    // Update user status
    String userStatus = await DatabaseManager.getUserCurrentStatus(userId);
    CurrentUser.setCurrentUserStatus(userStatus);
    List<String> userStatusList =
        await DatabaseManager.getUserStatusList(userId);
    CurrentUser.setCurrentUserStatusList(userStatusList);
  }
}
