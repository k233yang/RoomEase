import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
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
  late Future<String> toDoListLoaded;
  late Future<String> inProgressListLoaded;
  late Future<String> completedListLoaded;

  @override
  void initState() {
    super.initState();
    currHousehold = CurrentHousehold.getCurrentHousehold();

    DatabaseManager.updateChorePoints(CurrentHousehold.getCurrentHouseholdId());

    toDoListLoaded = currHousehold.updateChoresList(ChoreStatus.toDo);
    inProgressListLoaded =
        currHousehold.updateChoresList(ChoreStatus.inProgress);
    completedListLoaded = currHousehold.updateChoresList(ChoreStatus.completed);
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
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20))),
              ),
              buildChoreTiles(ChoreStatus.toDo),
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("In Progress",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20))),
              ),
              buildChoreTiles(ChoreStatus.inProgress),
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("Completed",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20))),
              ),
              buildChoreTiles(ChoreStatus.completed),
            ])),
      ),
      floatingActionButton: CreateAddChoreButton(onButtonPress: () {
        Navigator.pushNamed(context, "/addChore").then((value) {
          setState(() {
            DatabaseManager.updateChorePoints(
                CurrentHousehold.getCurrentHouseholdId());
            toDoListLoaded = currHousehold.updateChoresList(ChoreStatus.toDo);
            inProgressListLoaded =
                currHousehold.updateChoresList(ChoreStatus.inProgress);
            completedListLoaded =
                currHousehold.updateChoresList(ChoreStatus.completed);
          });
        });
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
    } else {
      // status is ChoreEnums.archived
      throw Exception(
          "Chore status 'Archived' not supported for buildChoreTiles(status)");
    }

    return FutureBuilder<String>(
      future: listLoaded,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = getChoreTile(context, currHousehold, status);
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
          children = <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child:
                  CircularProgressIndicator(color: ColorConstants.lightPurple),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Loading chores...'),
            ),
          ];
        }
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: children.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              background: Container(
                  color: ColorConstants.lightRed,
                  child: Align(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      if (status == ChoreStatus.toDo)
                        Text(
                          'Remove chore',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      if (status == ChoreStatus.inProgress)
                        Text(
                          'Move to To-Do',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      if (status == ChoreStatus.completed)
                        Text(
                          'Move to In Progress',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.left,
                        ),
                    ],
                  ))),
              secondaryBackground: Container(
                  color: ColorConstants.lightGreen,
                  child: Align(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      if (status == ChoreStatus.toDo)
                        Text(
                          'Assign to me',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      if (status == ChoreStatus.inProgress)
                        Text(
                          'Move to Completed',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      if (status == ChoreStatus.completed)
                        Text(
                          'Remove chore',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ))),
              key: ValueKey<Widget>(children[index]),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  if (status == ChoreStatus.toDo) {
                    try {
                      DatabaseManager.updateChoreStatus(
                              CurrentUser.getCurrentUserId(),
                              currHousehold.choresToDo[index].id,
                              status,
                              ChoreStatus.inProgress)
                          .then((value) {
                        setState(() {
                          children.removeAt(index);
                          refreshTiles();
                        });
                      });
                    } catch (e) {
                      print('Failed to move chore: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Chore assigned!')));
                  } else if (status == ChoreStatus.inProgress) {
                    try {
                      DatabaseManager.updateChoreStatus(
                              currHousehold
                                  .choresInProgress[index].assignedUserId,
                              currHousehold.choresInProgress[index].id,
                              status,
                              ChoreStatus.completed)
                          .then((value) {
                        setState(() {
                          children.removeAt(index);
                          refreshTiles();
                        });
                      });
                    } catch (e) {
                      print('Failed to move chore: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Chore completed!')));
                  } else if (status == ChoreStatus.completed) {
                    try {
                      DatabaseManager.deleteChore(
                              currHousehold.choresCompleted[index].id,
                              ChoreStatus.completed)
                          .then((value) {
                        setState(() {
                          children.removeAt(index);
                          refreshTiles();
                        });
                      });
                    } catch (e) {
                      print('Failed to move chore: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Chore removed!')));
                  }
                } else if (direction == DismissDirection.startToEnd) {
                  if (status == ChoreStatus.toDo) {
                    try {
                      DatabaseManager.deleteChore(
                              currHousehold.choresToDo[index].id,
                              ChoreStatus.toDo)
                          .then((value) {
                        setState(() {
                          children.removeAt(index);
                          refreshTiles();
                        });
                      });
                    } catch (e) {
                      print('Failed to move chore: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Chore removed!')));
                  } else if (status == ChoreStatus.inProgress) {
                    try {
                      DatabaseManager.updateChoreStatus(
                              currHousehold
                                  .choresInProgress[index].assignedUserId,
                              currHousehold.choresInProgress[index].id,
                              status,
                              ChoreStatus.toDo)
                          .then((value) {
                        setState(() {
                          children.removeAt(index);
                          refreshTiles();
                        });
                      });
                    } catch (e) {
                      print('Failed to move chore: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Chore unassigned!')));
                  } else if (status == ChoreStatus.completed) {
                    try {
                      DatabaseManager.updateChoreStatus(
                              currHousehold
                                  .choresCompleted[index].assignedUserId,
                              currHousehold.choresCompleted[index].id,
                              status,
                              ChoreStatus.inProgress)
                          .then((value) {
                        setState(() {
                          children.removeAt(index);
                          refreshTiles();
                        });
                      });
                    } catch (e) {
                      print('Failed to move chore: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Chore back in progress!')));
                  }
                }
              },
              child: children[index],
            );
          },
        );
      },
    );
  }

  void refreshTiles() {
    DatabaseManager.updateChorePoints(CurrentHousehold.getCurrentHouseholdId());
    toDoListLoaded = currHousehold.updateChoresList(ChoreStatus.toDo);
    inProgressListLoaded =
        currHousehold.updateChoresList(ChoreStatus.inProgress);
    completedListLoaded = currHousehold.updateChoresList(ChoreStatus.completed);
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
        backgroundColor: ColorConstants.lightPurple,
        shape: CircleBorder(),
        onPressed: onButtonPress,
        child: const Icon(Icons.add));
  }
}

List<Widget> getChoreTile(
  BuildContext context,
  Household currHousehold,
  ChoreStatus status,
) {
  List<Chore> list = <Chore>[];
  List<Widget> choreTileList = <Widget>[];

  Color? tileColor;
  Color? backgroundColor;
  Color? pointCircleColor;

  if (status == ChoreStatus.toDo) {
    tileColor = ColorConstants.lightPink;
    backgroundColor = ColorConstants.lightPink;
    pointCircleColor = ColorConstants.pink;
    list = currHousehold.choresToDo;
  } else if (status == ChoreStatus.inProgress) {
    tileColor = ColorConstants.lavender;
    backgroundColor = ColorConstants.lavender;
    pointCircleColor = ColorConstants.lightPurple;
    list = currHousehold.choresInProgress;
  } else if (status == ChoreStatus.completed) {
    tileColor = ColorConstants.lightBlue;
    backgroundColor = ColorConstants.lightBlue;
    pointCircleColor = ColorConstants.skyBlue;
    list = currHousehold.choresCompleted;
  } else {
    // status is ChoreEnums.archived
    tileColor = Colors.blueGrey[200];
    backgroundColor = Colors.blueGrey[100];
    pointCircleColor = Colors.blueGrey[800];
    list = currHousehold.choresArchived;
  }

  if (list.isEmpty) {
    return <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Center(child: Text("No chores in category!")),
          ))
    ];
  }

  for (final choreItem in list) {
    final Future<String> assignedUserName =
        DatabaseManager.getUserName(choreItem.assignedUserId);

    choreTileList.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Center(
              child: ExpansionTile(
            shape: Border(),
            title: Text(
              choreItem.name,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            collapsedBackgroundColor: tileColor,
            backgroundColor: backgroundColor,
            subtitle: FutureBuilder<String>(
              future: assignedUserName,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                Widget outputText;
                if (snapshot.hasData) {
                  if (snapshot.data == "") {
                    outputText =
                        Text("Unassigned", style: TextStyle(fontSize: 14));
                  } else {
                    if (status == ChoreStatus.completed) {
                      outputText = Text(
                          "Completed by ${snapshot.data as String}",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14));
                    } else {
                      outputText = Text(
                          "Assigned to ${snapshot.data as String}",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14));
                    }
                  }
                } else if (snapshot.hasError) {
                  outputText = Text('Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 14));
                } else {
                  outputText =
                      Text('Loading name...', style: TextStyle(fontSize: 14));
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
                          fontWeight: FontWeight.normal,
                          color: ColorConstants.black)),
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
                  visualDensity: VisualDensity.compact,
                  title: Text(choreItem.details)),
              ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text("Deadline",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ))),
              ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(choreItem.deadline)),
              /*
                   if (choreItem.status == ChoreStatus.toDo.value) Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 8),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            DatabaseManager.assignChoreToUser(CurrentUser.getCurrentUserId(), choreItem.id);
                          } catch (e) {
                            print('Failed to assign chore: $e');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar( content: Text('Chore successfully assigned!'))
                          );
                        },
                        child: const Text('Assign to me'),
                      )
                    )*/
            ],
            onExpansionChanged: (bool expanded) {
              // Do nothing for now
            },
          )),
        )));
  }

  return choreTileList;
}
