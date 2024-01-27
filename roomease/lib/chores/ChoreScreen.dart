import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/chores/ChoreEnums.dart';
import 'package:roomease/chores/ChoreItem.dart';

import '../colors/ColorConstants.dart';

class ChoreScreen extends StatefulWidget {
  const ChoreScreen({super.key});

  @override
  State<ChoreScreen> createState() => _ChoreScreen();
}

class _ChoreScreen extends State<ChoreScreen> {
  String householdCode = CurrentHousehold.getCurrentHouseholdId();
  @override
  Widget build(BuildContext context) {
    // Todo: Starting with getting Todo chores for now, sort later
    Iterable choreList = DatabaseManager.getChoreList(ChoreEnums.toDo, householdCode) as Iterable;

    String choreTitle = "";
    String assignedMemberName = "";
    String choreDescription = "";
    String choreScore = "";
    ChoreEnums choreStatus = ChoreEnums.toDo; // Todo: don't hardcode this toDo status
    for (final child in choreList) {
      // TODO: **
      // choreTitle = get name somehow
    }


    return Scaffold(
        appBar: AppBar(
        title: const Text('Chores'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: Container(
        color: ColorConstants.white,
        child: Column(
          children: [
            Center(child: ChoreItem(choreTitle, assignedMemberName, choreDescription, choreScore, choreStatus)),
          ]
        )
      ),
      floatingActionButton:  CreateAddChoreButton(
        onButtonPress: () {
          Navigator.pushNamed(context, "/addChore");
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CreateAddChoreButton extends StatelessWidget {
  final VoidCallback onButtonPress;

  CreateAddChoreButton(
    {Key? key, required this.onButtonPress})
    : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: ColorConstants.white,
      backgroundColor: ColorConstants.darkPurple,
      shape: CircleBorder(),
      onPressed: onButtonPress,
      child: const Icon(Icons.add)
    );
  }
}