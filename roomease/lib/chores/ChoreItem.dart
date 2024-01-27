import 'package:flutter/material.dart';
import 'package:roomease/chores/ChoreStatus.dart';

class ChoreItem extends StatefulWidget {
  @override
  State createState() {
    return _ChoreState();
  }
}

class _ChoreState extends State<ChoreItem> {
  @override
  Widget build(BuildContext context) {
    // TODO: get the values for the getChoreTile(...) arguments from chore status and chore add/edit page
    return getChoreTile("Wash Dishes", "Sookeong Cho", "Wash everything in the sink!", "5", ChoreStatus.completed);
  }
}

ChoreStatus getChoreState() {
  // TODO: Implement getting the actual state of the tile
  return ChoreStatus.completed;
}

ExpansionTile getChoreTile(String choreName, String? assignedMemberName, String? choreDetails, String pointValue, ChoreStatus choreState) {
  Color? tileColor;
  Color? pointCircleColor;
  ChoreStatus choreState = getChoreState();

  if (choreState == ChoreStatus.toDo) {
    tileColor = Colors.purple[200];
    pointCircleColor = Colors.purple[800];
  } else if (choreState == ChoreStatus.inProgress) {
    tileColor = Colors.deepPurple[200];
    pointCircleColor = Colors.deepPurple[800];
  } else if (choreState == ChoreStatus.completed) {
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