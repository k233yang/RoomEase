import 'package:roomease/User.dart';
import 'package:roomease/chores/Chore.dart';

import 'DatabaseManager.dart';
import 'calendar/Event.dart';
import 'chores/ChoreStatus.dart';

class Household {
  String name;
  String id;
  List<User> users;
  List<Chore> choresToDo;
  List<Chore> choresInProgress;
  List<Chore> choresCompleted;
  List<Chore> choresArchived;
  List<Event> calendarEvents;

  Household(this.name, this.id, this.users, this.choresToDo, this.choresInProgress, this.choresCompleted, this.choresArchived, this.calendarEvents);

  Future<String> updateChoresList(ChoreStatus status) async {
    if (status == ChoreStatus.toDo) {
      choresToDo = await DatabaseManager.getChoresFromDB(ChoreStatus.toDo, id);
    } else if (status == ChoreStatus.inProgress) {
      choresInProgress = await DatabaseManager.getChoresFromDB(ChoreStatus.inProgress, id);
    } else if (status == ChoreStatus.completed) {
      choresCompleted = await DatabaseManager.getChoresFromDB(ChoreStatus.completed, id);
    } else { // ChoreStatus.archived
      choresArchived = await DatabaseManager.getChoresFromDB(ChoreStatus.archived, id);
    }
    return "completed";
  }

  Future<String> updateCalendarEventsList() async {
    calendarEvents = await DatabaseManager.getCalendarEventsFromDB(id);
    return "completed";
  }
}
