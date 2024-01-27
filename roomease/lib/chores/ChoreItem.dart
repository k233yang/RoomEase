import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/chores/ChoreEnums.dart';

class ChoreItem extends StatefulWidget {
  final String choreTitle;
  final String assignedMemberName;
  final String choreDescription;
  final String choreScore;
  final ChoreEnums choreStatus;
  
  ChoreItem(this.choreTitle, this.assignedMemberName, this.choreDescription, this.choreScore, this.choreStatus);

  @override
  State createState() {
    //TODO: huh to this warning about don't put logic..
    return _ChoreState(choreTitle, assignedMemberName, choreDescription, choreScore, choreStatus);
  }
}

class _ChoreState extends State<ChoreItem> {
  final String choreTitle;
  final String assignedMemberName;
  final String choreDescription;
  final String choreScore;
  final ChoreEnums choreStatus;

  _ChoreState(this.choreTitle, this.assignedMemberName, this.choreDescription, this.choreScore, this.choreStatus)
  // TODO: ** How to access choreTitle and etc in this class?
  
  @override
  Widget build(BuildContext context) {
    // TODO: get the values for the getChoreTile(...) arguments from chore status and chore add/edit page
    // String householdCode = CurrentHousehold.getCurrentHouseholdId();
    // ChoreName, AssignedTo, Description, Score, Status
    return getChoreTile(this.choreTitle, this.assignedMemberName, "Wash everything in the sink!", "5", ChoreEnums.completed);
  }
}

ChoreEnums getChoreState() {
  // TODO: Implement getting the actual state of the tile
  return ChoreEnums.completed;
}

ExpansionTile getChoreTile(String choreName, String? assignedMemberName, String? choreDetails, String pointValue, ChoreEnums choreState) {
  Color? tileColor;
  Color? pointCircleColor;
  ChoreEnums choreState = getChoreState();

  if (choreState == ChoreEnums.toDo) {
    tileColor = Colors.purple[200];
    pointCircleColor = Colors.purple[800];
  } else if (choreState == ChoreEnums.inProgress) {
    tileColor = Colors.deepPurple[200];
    pointCircleColor = Colors.deepPurple[800];
  } else if (choreState == ChoreEnums.completed) {
    tileColor = Colors.indigo[200];
    pointCircleColor = Colors.indigo[800];
  } else {
    // choreState is ChoreEnums.archived
    tileColor = Colors.blueGrey[200];
    pointCircleColor = Colors.blueGrey[800];
  }

  return ExpansionTile(
    title: Container(
        color: tileColor,
        child: Text(choreName)
    ),
    subtitle: Text(assignedMemberName ?? ""),
    trailing: Container(
      width: 60,
      height: 60,
      // color: pointCircleColor,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pointCircleColor,
      ),
      child: Text(pointValue)
    ),
    children: <Widget>[
      Text(
        choreDetails ?? "No details to display.",
      ),
    ],
    onExpansionChanged: (bool expanded) {
      // Do nothing for now
    },
  );
}