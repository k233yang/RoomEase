import 'package:roomease/User.dart';
import 'package:roomease/chores/Chore.dart';

class Household {
  String name;
  String id;
  List<User> users;
  List<Chore> choresToDo;
  List<Chore> choresInProgress;
  List<Chore> choresCompleted;
  List<Chore> choresArchived;

  Household(this.name, this.id, this.users, this.choresToDo, this.choresInProgress, this.choresCompleted, this.choresArchived);
}
