import 'package:roomease/User.dart';
import 'package:roomease/chores/Chore.dart';

import 'chores/ChoreStatus.dart';

class Household {
  String name;
  String id;
  List<User> users;
  List<Chore> choresToDo;
  List<Chore> choresInProgress;
  List<Chore> choresCompleted;
  List<Chore> choresArchived;

  Household(this.name, this.id, this.users, this.choresToDo, this.choresInProgress, this.choresCompleted, this.choresArchived);

  // TODO: Potential function call when database is updated? thinking maybe not here..
  void addToChoreList(ChoreStatus status, Chore chore) {
    if (status == ChoreStatus.toDo) {
      print("Adding to toDo list"); // For testing
      choresToDo.add(chore);
      print(choresToDo[0].name); // For testing

    } else if (status == ChoreStatus.inProgress) {
      choresInProgress.add(chore);
    } else if (status == ChoreStatus.completed) {
      choresCompleted.add(chore);
    } else if (status == ChoreStatus.archived) {
      choresArchived.add(chore);
    } else {
      throw Exception("Cannot add to chore list - invalid chore status");
    }
  }
}

// WHERE TO HOLD THE HOUSEHOLD INSTANCE SO THAT IT CAN STAY ACCESSABLE???
// CURRENTLY HAVE IT IN CHATSCREEN.DART BUT THAT SEEMS INEFFICIENT CUZ THEN
/* IT'LL MAKE A NEW INSTANCE AND RENDER ALL THE CHORE LISTS EVERY TIME THE
SCREEN IS RE GENERATED. IS THIS THE BEST WAY??

AND IF SO, HOW CAN THE CHORELISTLISTENER FROM DATABASEMANAGER.DART ACCESS THIS
HOUSEHOLD TO CALL UPDATES WHEN IT NOTICES CHANGES WERE MADE TO THE CHORE LIST
IN THE DATABASE??

 */
