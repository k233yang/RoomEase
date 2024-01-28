import 'package:flutter/material.dart';
import 'package:roomease/Household.dart';
import 'package:roomease/chores/ChoreStatus.dart';

import '../DatabaseManager.dart';
import 'Chore.dart';

ExpansionTile getChoreTile(ChoreStatus status) {
  Household household = DatabaseManager.currentHousehold;

  // Ensure household list is not empty
  DatabaseManager.getChoreList(status, household.id);

  List<Chore> list = <Chore>[];

  Color? tileColor;
  Color? pointCircleColor;

  if (status == ChoreStatus.toDo) {
    tileColor = Colors.purple[200];
    pointCircleColor = Colors.purple[800];
    print("Household list is being accessed now");
    list = household.choresToDo;
  } else if (status == ChoreStatus.inProgress) {
    tileColor = Colors.deepPurple[200];
    pointCircleColor = Colors.deepPurple[800];
    list = household.choresInProgress;
  } else if (status == ChoreStatus.completed) {
    tileColor = Colors.indigo[200];
    pointCircleColor = Colors.indigo[800];
    list = household.choresCompleted;
  } else {
    // choreState is ChoreEnums.archived
    tileColor = Colors.blueGrey[200];
    pointCircleColor = Colors.blueGrey[800];
    list = household.choresArchived;
  }

  // Chore firstItem = list[0]; // TODO: Need to find a way to display a tile for ALL items in the list, but working with just the first item for now
  Chore firstItem = Chore("", "hardcodedSadgeTestSweep", "Sweep da flooor", "2024-01-24 4:08 AM", 3, "EZ5ZkiFsVZMySudqICUIhmskgXw1", null, "toDo");

  String choreName = firstItem.name;
  String? assignedMemberName = firstItem.assignedUserId;
  String? choreDetails = firstItem.details;
  String pointValue = firstItem.score.toString();
  String? choreDeadline = firstItem.deadline;

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
      Text(choreDetails),
      Text("Deadline: $choreDeadline")
    ],
    onExpansionChanged: (bool expanded) {
      // Do nothing for now
    },
  );
}