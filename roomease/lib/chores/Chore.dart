import 'package:roomease/User.dart';
import 'ChoreStatus.dart';

class Chore {
  String id;
  String name;
  String details;
  String deadline;
  int score;
  String createdByUserId;
  String? assignedUserId;
  String status;

  Chore(this.id, this.name, this.details, this.deadline, this.score, this.createdByUserId, this.assignedUserId, this.status);
}
