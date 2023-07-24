import 'package:flutter/material.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:roomease/welcome/LoginScreen.dart';
import 'package:roomease/welcome/RegisterScreen.dart';

class WelcomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // total height and width of screen

    return Container(
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
                })
          ],
        ));
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
