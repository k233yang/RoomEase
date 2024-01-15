import 'package:roomease/User.dart';

class Chore {
  String id;
  String name;
  String details;
  String deadline;
  int score;
  User? createdByUser;
  User? assignedUser;

  Chore(this.id, this.name, this.details, this.deadline, this.score, this.createdByUser, this.assignedUser);
}