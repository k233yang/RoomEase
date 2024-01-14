import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/welcome/LoginScreen.dart';
import 'package:roomease/welcome/RegisterScreen.dart';

import '../../CurrentUser.dart';
import '../../DatabaseManager.dart';

class WelcomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // total height and width of screen
    final _auth = FirebaseAuth.instance;

    return Scaffold(
        appBar: AppBar(
          title: Text("RoomEase"),
        ),
        body: Container(
            height: size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Welcome To RoomEase"),
                WelcomeScreenButton(
                    buttonText: "Login",
                    onButtonPress: () {
                      Navigator.pushNamed(context, "/login");
                    }),
                WelcomeScreenButton(
                    buttonText: "Register",
                    onButtonPress: () {
                      Navigator.pushNamed(context, "/register");
                    }),
                WelcomeScreenButton(
                    buttonText: "Debug Login",
                    onButtonPress: () async {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: "testing@testing.com", password: "testing123");
                      if (user != null) {
                        DatabaseManager.getUserName(user.user!.uid);
                        CurrentUser.setCurrentUserId(
                          user.user!.uid,
                        );
                        CurrentHousehold.setCurrentHouseholdId("kIDMQ5");
                        DatabaseManager.updateHouseholdName("kIDMQ5");
                        SharedPreferencesUtility.setValue("isLoggedIn", true);
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (_) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email or password is incorrect')),
                        );
                      }
                    })
              ],
            )));
  }
}

class WelcomeScreenButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onButtonPress;

  WelcomeScreenButton(
      {Key? key, required this.buttonText, required this.onButtonPress})
      : super(key: key);

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      foregroundColor: ColorConstants.white,
      backgroundColor: ColorConstants.lightPurple);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // total height and width of screen
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.75,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: TextButton(
              style: flatButtonStyle,
              onPressed: onButtonPress,
              child: Text(buttonText))),
    );
  }
}
