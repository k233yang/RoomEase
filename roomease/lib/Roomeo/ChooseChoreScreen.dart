import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:roomease/Roomeo/Roomeo.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import 'package:roomease/chores/Chore.dart';
import 'package:roomease/chores/EditChoreScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';

// TODO: FINISH THIS NEXT
class ChooseChoreScreen extends StatefulWidget {
  final List<String> choreIds;
  final String placeholder;
  final String? messageId;
  final bool shouldUpdate;
  final bool shouldRemove;
  final Function(String) onChoreSelect;
  const ChooseChoreScreen(
      {super.key,
      required this.choreIds,
      required this.placeholder,
      required this.onChoreSelect,
      this.shouldUpdate = false,
      this.shouldRemove = false,
      this.messageId});

  @override
  State<ChooseChoreScreen> createState() => _ChooseChoreScreenState();
}

class _ChooseChoreScreenState extends State<ChooseChoreScreen> {
  Future<List<Chore>> fetchChores() async {
    final choresFutures = widget.choreIds.map((choreId) =>
        DatabaseManager.getChoreFromId(
            choreId, CurrentHousehold.getCurrentHouseholdId()));
    final chores = await Future.wait(choresFutures);
    return chores.whereType<Chore>().toList();
  }

  void handleChoreSelect(String choreId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Do you want to select this chore?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // get rid of the confirmation bubble
                Navigator.of(context).pop(true);
                // go to the edit chore screen, if the user
                // wants to update a chore
                if (widget.shouldUpdate) {
                  if (mounted) {
                    final result =
                        await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditChoreScreen(
                        choreId: choreId,
                        // when the user confirms the edit
                        onChoreUpdate:
                            (String newChoreId, Chore oldChore) async {
                          // go back to the chat screen (by popping twice):
                          // once for the edit chore page, once for the choose
                          // chore page
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          // update the message with the new chore update message
                          Chore? newChore =
                              await DatabaseManager.getChoreFromId(newChoreId,
                                  CurrentHousehold.getCurrentHouseholdId());
                          Map<String, String> oldChoreParameters = {
                            "ChorePerson": await DatabaseManager.getUserName(
                                oldChore.assignedUserId!),
                            "ChoreTitle": oldChore.name,
                            "ChoreDescription": oldChore.details,
                            "ChoreDate": oldChore.deadline,
                            "ChorePoints": oldChore.points.toString(),
                            "ChorePointsThreshold":
                                oldChore.threshold.toString(),
                          };
                          Map<String, String> newChoreParameters = {
                            "ChorePerson": await DatabaseManager.getUserName(
                                newChore!.assignedUserId!),
                            "ChoreTitle": newChore.name,
                            "ChoreDescription": newChore.details,
                            "ChoreDate": newChore.deadline,
                            "ChorePoints": newChore.points.toString(),
                            "ChorePointsThreshold":
                                newChore.threshold.toString(),
                          };
                          String updateChoreMessage =
                              generateUpdateCommandInput(
                                  oldChoreParameters, newChoreParameters);
                          // update the user message with the updateChoreMessage
                          DatabaseManager.replaceMessage(
                            CurrentUser.getCurrentUserId() +
                                RoomeoUser.user.userId,
                            widget.messageId!,
                            updateChoreMessage,
                          );
                          await getRoomeoResponse(
                              updateChoreMessage, widget.messageId!,
                              shouldQueryHouseholdsInstead: true);
                        },
                      ),
                    ));
                  }
                } else if (widget.shouldRemove) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    // remove the chore:
                    // get the premade message:
                    Chore? choreToRemove = await DatabaseManager.getChoreFromId(
                      choreId,
                      CurrentHousehold.getCurrentHouseholdId(),
                    );
                    String removeChoreMessage =
                        "Remove the chore '${choreToRemove!.name}'";
                    print(removeChoreMessage);
                    // do some back-end stuff:
                    // replace the FB message:
                    await DatabaseManager.replaceMessage(
                      CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
                      widget.messageId!,
                      removeChoreMessage,
                    );
                    // get roomeo's response
                    await getRoomeoResponse(
                      removeChoreMessage,
                      widget.messageId!,
                      shouldQueryHouseholdsInstead: true,
                    );
                    // below operations can be performed concurrently
                    await Future.wait([
                      // delete the chore vector from the household VDB
                      deleteVector(
                        CurrentHousehold.getCurrentHouseholdId(),
                        choreId,
                      ),
                      // delete the actual chore from the household FB
                      DatabaseManager.deleteChoreFromStringStatus(
                        choreToRemove.id,
                        choreToRemove.status,
                      ),
                    ]);
                  }
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      widget.onChoreSelect(choreId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.placeholder),
          backgroundColor: ColorConstants.lightPurple,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop({
                  'exited': true,
                });
              }),
        ),
        body: FutureBuilder<List<Chore>>(
          future: fetchChores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No chores found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final chore = snapshot.data![index];
                  return Card(
                    child: ListTile(
                      title: Text(chore.name),
                      subtitle: Text('Description: ${chore.details}'),
                      onTap: () => handleChoreSelect(chore.id),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
