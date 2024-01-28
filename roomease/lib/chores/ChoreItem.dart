import 'package:flutter/material.dart';
import 'package:roomease/Household.dart';
import 'package:roomease/chores/ChoreStatus.dart';
import 'package:roomease/colors/ColorConstants.dart';

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
  Chore firstItem = Chore("", "Clean Toilet", "can u clean the toilet", "2024-01-24 4:08 AM", 3, "EZ5ZkiFsVZMySudqICUIhmskgXw1", "Kevin", "toDo");

  String choreName = firstItem.name;
  String? assignedMemberName = firstItem.assignedUserId;
  String? choreDetails = firstItem.details;
  String pointValue = firstItem.score.toString();
  String? choreDeadline = firstItem.deadline;

  return ExpansionTile(
    title: Text(
      choreName,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20
      ),
    ),
    backgroundColor: tileColor,
    collapsedBackgroundColor: tileColor,
    subtitle: Text(
      assignedMemberName ?? "Unassigned",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14
      ),
    ),
    trailing: Container(
      width: 60,
      height: 60,
      // color: pointCircleColor,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pointCircleColor,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          pointValue,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ColorConstants.white
          )
        ),
      )
    ),
    children: <Widget>[
      ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          "Details",
          style: TextStyle(
          fontWeight: FontWeight.w500,
        )),
      ),
      ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
        choreDetails
      )),
      ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          "Deadline",
          style: TextStyle(
            fontWeight: FontWeight.w500,
        ))
      ),
      ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
        choreDeadline
      )),
    ],
    onExpansionChanged: (bool expanded) {
      // Do nothing for now
    },
  );
}