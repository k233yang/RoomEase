import 'package:flutter/material.dart';
import 'package:roomease/colors/ColorConstants.dart';

class CreateJoinHouseholdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // total height and width of screen

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
                Center(
                  child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 50, bottom: 30),
                      child: Text(
                          "Are you creating a new household or joining an existing household?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15))),
                ),
                CreateJoinHouseholdButton(
                    buttonText: "Create Household",
                    onButtonPress: () {
                      Navigator.pushNamed(context, "/createHousehold");
                    }),
                CreateJoinHouseholdButton(
                    buttonText: "Join Household",
                    onButtonPress: () {
                      Navigator.pushNamed(context, "/joinHousehold");
                    })
              ],
            )));
  }
}

class CreateJoinHouseholdButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onButtonPress;

  CreateJoinHouseholdButton(
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
