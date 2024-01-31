import 'package:flutter/material.dart';
import 'package:roomease/DatabaseManager.dart';
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
    inProgressListLoaded =
        currHousehold.updateChoresList(ChoreStatus.inProgress);
    completedListLoaded = currHousehold.updateChoresList(ChoreStatus.completed);

      DatabaseManager.updateChorePoints(CurrentHousehold.getCurrentHouseholdId());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chores'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: SingleChildScrollView(
        child: Container(
            color: ColorConstants.white,
            child: Column(children: [
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("To-Do",
                        style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 20))
                ),
              ),
              buildChoreTiles(ChoreStatus.toDo),
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("In Progress",
                        style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 20))
                ),
              ),
              buildChoreTiles(ChoreStatus.inProgress),
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("Completed",
                        style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 20))
                ),
              ),
              buildChoreTiles(ChoreStatus.completed),
            ])
        ),
      ),
      floatingActionButton: CreateAddChoreButton(onButtonPress: () {
        Navigator.pushNamed(context, "/addChore");
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  FutureBuilder<String> buildChoreTiles(ChoreStatus status) {
    Future<String> listLoaded;

    if (status == ChoreStatus.toDo) {
      listLoaded = toDoListLoaded;
    } else if (status == ChoreStatus.inProgress) {
      listLoaded = inProgressListLoaded;
    } else if (status == ChoreStatus.completed) {
      listLoaded = completedListLoaded;
    } else {     // status is ChoreEnums.archived
      throw Exception("Chore status 'Archived' not supported for buildChoreTiles(status)");
    }

    return FutureBuilder<String>(
      future: listLoaded,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = getChoreTile(currHousehold, status);
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
    );
  }
}

class CreateAddChoreButton extends StatelessWidget {
  final VoidCallback onButtonPress;

  CreateAddChoreButton({Key? key, required this.onButtonPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        foregroundColor: ColorConstants.white,
        backgroundColor: ColorConstants.darkPurple,
        shape: CircleBorder(),
        onPressed: onButtonPress,
        child: const Icon(Icons.add));
  }
}

List<Widget> getChoreTile(Household currHousehold, ChoreStatus status) {

  List<Chore> list = <Chore>[];
  List<Widget> choreTileList = <Widget>[];

  Color? tileColor;
  Color? backgroundColor;
  Color? pointCircleColor;

  if (status == ChoreStatus.toDo) {
    tileColor = Colors.purple[200];
    backgroundColor = Colors.purple[100];
    pointCircleColor = Colors.purple[800];
    list = currHousehold.choresToDo;
  } else if (status == ChoreStatus.inProgress) {
    tileColor = Colors.deepPurple[200];
    backgroundColor = Colors.deepPurple[100];
    pointCircleColor = Colors.deepPurple[800];
    list = currHousehold.choresInProgress;
  } else if (status == ChoreStatus.completed) {
    tileColor = Colors.indigo[200];
    backgroundColor = Colors.indigo[100];
    pointCircleColor = Colors.indigo[800];
    list = currHousehold.choresCompleted;
  } else { // status is ChoreEnums.archived
    tileColor = Colors.blueGrey[200];
    backgroundColor = Colors.blueGrey[100];
    pointCircleColor = Colors.blueGrey[800];
    list = currHousehold.choresArchived;
  }

  if (list.isEmpty) {
    return <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Center(
                child: Text("No chores in category!")
            ),
          )
      )
    ];
  }

  for (final choreItem in list) {
    final Future<String> assignedUserName = DatabaseManager.getUserName(choreItem.assignedUserId);

    choreTileList.add(
      Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Center(
                child: ExpansionTile(
                  title: Text(
                    choreItem.name,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                  collapsedBackgroundColor: tileColor,
                  backgroundColor: backgroundColor,
                  subtitle: FutureBuilder<String>(
                    future: assignedUserName,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      Widget outputText;
                      if (snapshot.hasData) {
                        if(snapshot.data == "") {
                          outputText = Text("Unassigned",
                              style: TextStyle(fontSize: 14));
                        } else {
                          outputText = Text("Assigned to ${snapshot.data as String}",
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14));
                        }
                      } else if (snapshot.hasError) {
                        outputText =
                          Text('Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 14));
                      } else {
                        outputText = Text('Loading name...',
                            style: TextStyle(fontSize: 14));
                      }
                      return outputText;
                    },
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
                        child: Text(choreItem.points.toString(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: ColorConstants.white)),
                      )),
                  children: <Widget>[
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text("Details",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    ListTile(
                        visualDensity: VisualDensity.compact, title: Text(choreItem.details)),
                    ListTile(
                        visualDensity: VisualDensity.compact,
                        title: Text("Deadline",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ))),
                    ListTile(
                        visualDensity: VisualDensity.compact,
                        title: Text(choreItem.deadline)),
                  ],
                  onExpansionChanged: (bool expanded) {
                    // Do nothing for now
                  },
                )
            ),
          )
      )
    );
  }

  return choreTileList;
}
