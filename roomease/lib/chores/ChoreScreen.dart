import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/chores/EditChoreFromChoreScreen.dart';
import '../CurrentHousehold.dart';
import '../Household.dart';
import '../colors/ColorConstants.dart';
import 'Chore.dart';
import 'ChoreStatus.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';

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
          children = <Widget>[getChoreTile(context, currHousehold, status)];
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  ListView getDismissible(List<Widget> children, ChoreStatus status) {
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
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              if (status == ChoreStatus.toDo) {
                try {
                  await updateVectorMetadata(
                      CurrentHousehold.getCurrentHouseholdId(),
                      currHousehold.choresToDo[index].id,
                      {'choreStatus': ChoreStatus.inProgress.value});
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
                  await updateVectorMetadata(
                      CurrentHousehold.getCurrentHouseholdId(),
                      currHousehold.choresToDo[index].id,
                      {'choreStatus': ChoreStatus.completed.value});
                  DatabaseManager.updateChoreStatus(
                          currHousehold.choresInProgress[index].assignedUserId,
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
                  await deleteVector(CurrentHousehold.getCurrentHouseholdId(),
                      currHousehold.choresToDo[index].id);
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
                  await deleteVector(CurrentHousehold.getCurrentHouseholdId(),
                      currHousehold.choresToDo[index].id);
                  DatabaseManager.deleteChore(
                          currHousehold.choresToDo[index].id, ChoreStatus.toDo)
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
                  print("I GET IN HERE GOOD");
                  await updateVectorMetadata(
                      CurrentHousehold.getCurrentHouseholdId(),
                      currHousehold.choresToDo[index].id,
                      {'choreStatus': ChoreStatus.toDo.value});
                  DatabaseManager.updateChoreStatus(
                          currHousehold.choresInProgress[index].assignedUserId,
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
                  await updateVectorMetadata(
                      CurrentHousehold.getCurrentHouseholdId(),
                      currHousehold.choresToDo[index].id,
                      {'choreStatus': ChoreStatus.inProgress.value});
                  DatabaseManager.updateChoreStatus(
                          currHousehold.choresCompleted[index].assignedUserId,
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
  }

  void refreshTiles() {
    DatabaseManager.updateChorePoints(CurrentHousehold.getCurrentHouseholdId());
    toDoListLoaded = currHousehold.updateChoresList(ChoreStatus.toDo);
    inProgressListLoaded =
        currHousehold.updateChoresList(ChoreStatus.inProgress);
    completedListLoaded = currHousehold.updateChoresList(ChoreStatus.completed);
  }

  ListView getChoreTile(
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
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 1,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Center(child: Text("No chores in category!")),
                ));
          });
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
              title: Builder(
                builder: (context) {
                  if (choreItem.status != ChoreStatus.completed.value &&
                      DateTime.now()
                              .difference(DateFormat('yyyy-MM-dd hh:mm a')
                                  .parse(choreItem.deadline))
                              .inMinutes >
                          0) {
                    return Text(
                      choreItem.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: ColorConstants.red),
                    );
                  } else {
                    return Text(
                      choreItem.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    );
                  }
                },
              ),
              collapsedBackgroundColor: tileColor,
              backgroundColor: backgroundColor,
              subtitle: FutureBuilder<String>(
                future: assignedUserName,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
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
              trailing: FittedBox(
                child: Row(children: [
                  if (choreItem.status == ChoreStatus.toDo.value &&
                      choreItem.timesIncremented > 0 &&
                      choreItem.daysSinceLastIncremented < 2)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          child: Image(
                            image: AssetImage('assets/points_increase.png'),
                            height: 30,
                            width: 30,
                          ),
                        )
                      ],
                    ),
                  Column(
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          // color: pointCircleColor,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pointCircleColor,
                          ),
                          child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 3),
                                    child: Text('${choreItem.points}',
                                        style: TextStyle(
                                            height: 1.0,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color: ColorConstants.black)),
                                  ),
                                  Text('points',
                                      style: TextStyle(
                                          height: 1.0,
                                          fontSize: 11,
                                          fontWeight: FontWeight.normal,
                                          color: ColorConstants.black)),
                                ],
                              )))
                    ],
                  ),
                ]),
              ),
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Text("Details",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 6, bottom: 10),
                    child: Text(choreItem.details,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Builder(
                      builder: (context) {
                        if (choreItem.status != ChoreStatus.completed.value &&
                            DateTime.now()
                                    .difference(DateFormat('yyyy-MM-dd hh:mm a')
                                        .parse(choreItem.deadline))
                                    .inMinutes >
                                0) {
                          return Text("Deadline",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.red));
                        } else {
                          return Text("Deadline",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ));
                        }
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 6, bottom: 10),
                    child: Builder(
                      builder: (context) {
                        if (choreItem.status != ChoreStatus.completed.value &&
                            DateTime.now()
                                    .difference(DateFormat('yyyy-MM-dd hh:mm a')
                                        .parse(choreItem.deadline))
                                    .inMinutes >
                                0) {
                          return Text(choreItem.deadline,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: ColorConstants.red));
                        } else {
                          return Text(choreItem.deadline,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ));
                        }
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Text("Past Point Increases",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 6, bottom: 10),
                    child: Text(
                        "Points were increased ${choreItem.timesIncremented.toString()} time(s)",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 100, right: 100, top: 0, bottom: 10),
                    child: CreateEditChoreButton(onButtonPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditChoreFromChoreScreen(
                              choreId: choreItem.id,
                              onChoreUpdate: (Map<String, String> newChore,
                                  Map<String, String> oldChore) async {
                                Navigator.of(context).pop();
                              },
                            ),
                          )).then((value) {
                        setState(() {
                          refreshTiles();
                        });
                      });
                    }),
                  ),
                ),
              ],
              onExpansionChanged: (bool expanded) {
                // Do nothing for now
              },
            )),
          )));
    }

    return getDismissible(choreTileList, status);
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

class CreateEditChoreButton extends StatelessWidget {
  final VoidCallback onButtonPress;

  CreateEditChoreButton({Key? key, required this.onButtonPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onButtonPress,
        child: Row(children: [
          Text("Edit Chore"),
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Image(
                  image: AssetImage('assets/edit_icon.png'),
                  height: 30,
                  width: 30)),
        ]));
  }
}
