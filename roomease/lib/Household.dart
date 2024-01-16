import 'package:roomease/User.dart';
import 'package:roomease/chores/Chore.dart';

class Household {
  String name;
  String id;
  List<User> users;
  List<Chore> chores;

  Household(this.name, this.id, this.users, this.chores);
}
