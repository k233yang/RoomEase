import 'package:flutter/material.dart';

import '../CurrentHousehold.dart';
import '../Household.dart';
import '../colors/ColorConstants.dart';
import 'Chore.dart';
import 'ChoreStatus.dart';

class ChoreScreen extends StatefulWidget {
  const ChoreScreen({super.key});

  @override
  State<ChoreScreen> createState() => _ChoreScreen();
}

class _ChoreScreen extends State<ChoreScreen> {
  late final Household currHousehold;
  late final Future<String> toDoListLoaded;
  late final Future<String> inProgressListLoaded;
  late final Future<String> completedListLoaded;

  @override
  void initState() {
    super.initState();
    currHousehold = CurrentHousehold.getCurrentHousehold();

    toDoListLoaded = currHousehold.updateChoresList(ChoreStatus.toDo);
    inProgressListLoaded = currHousehold.updateChoresList(ChoreStatus.inProgress);
    completedListLoaded = currHousehold.updateChoresList(ChoreStatus.completed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Chores'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: Container(
        color: ColorConstants.white,
        child: Column(
          children: [
            Center(child: Text("To-Do",
                style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20))
            ),
            // TODO: Potentially put below code into function?
            FutureBuilder<String>(
              future: toDoListLoaded,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                if(snapshot.hasData) {
                  children = <Widget> [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Center( child: getChoreTile(currHousehold, ChoreStatus.toDo)),
                        )
                    )
                  ];
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  ];
                } else {
                  children = const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Loading chores...'),
                    ),
                  ];
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                );
              },
            ),
            Center(child: Text("In Progress",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20))
            ),
            // TODO: Potentially put below code into function?
            FutureBuilder<String>(
              future: inProgressListLoaded,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                if(snapshot.hasData) {
                  children = <Widget> [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Center( child: getChoreTile(currHousehold, ChoreStatus.inProgress)),
                        )
                    )
                  ];
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  ];
                } else {
                  children = const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Loading chores...'),
                    ),
                  ];
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                );
              },
            ),
            Center(child: Text("Completed",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20))
            ),
            // TODO: Potentially put below code into function?
            FutureBuilder<String>(
              future: completedListLoaded,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                if(snapshot.hasData) {
                  children = <Widget> [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Center( child: getChoreTile(currHousehold, ChoreStatus.completed)),
                        )
                    )
                  ];
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  ];
                } else {
                  children = const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Loading chores...'),
                    ),
                  ];
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                );
              },
            ),
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

Widget getChoreTile(Household currHousehold, ChoreStatus status) {
  List<Chore> list = <Chore>[];

  Color? tileColor;
  Color? pointCircleColor;

  if (status == ChoreStatus.toDo) {
    tileColor = Colors.purple[200];
    pointCircleColor = Colors.purple[800];
    list = currHousehold.choresToDo;
  } else if (status == ChoreStatus.inProgress) {
    tileColor = Colors.deepPurple[200];
    pointCircleColor = Colors.deepPurple[800];
    list = currHousehold.choresInProgress;
  } else if (status == ChoreStatus.completed) {
    tileColor = Colors.indigo[200];
    pointCircleColor = Colors.indigo[800];
    list = currHousehold.choresCompleted;
  } else { // status is ChoreEnums.archived
    tileColor = Colors.blueGrey[200];
    pointCircleColor = Colors.blueGrey[800];
    list = currHousehold.choresArchived;
  }

  if(list.isEmpty) {
    return Text("No chores in category!");
  }

  // TODO: Configure so that it displays all items in list, for now testing with just the first item
  Chore choreItem = list[0];

  return ExpansionTile(
    title: Text(
      choreItem.name,
      style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20
      ),
    ),
    backgroundColor: tileColor,
    collapsedBackgroundColor: tileColor,
    subtitle: Text(
      choreItem.assignedUserId ?? "Unassigned", // TODO: We need to change this to be getting user NAME not id. But yet, either way it should never print "null" which it is doing right now.
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
              choreItem.score.toString(),
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
              choreItem.details
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
              choreItem.deadline
          )),
    ],
    onExpansionChanged: (bool expanded) {
      // Do nothing for now
    },
  );
}
