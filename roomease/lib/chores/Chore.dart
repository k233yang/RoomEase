import 'package:roomease/User.dart';
import 'ChoreStatus.dart';

class Chore {
  String id;
  String name;
  String details;
  String deadline;
  String dateCreated;
  String dateLastIncremented;
  int score;
  int timesIncremented;
  int daysSinceLastIncremented;
  String createdByUserId;
  String? assignedUserId;
  String status;

  Chore(
      this.id,
      this.name,
      this.details,
      this.deadline,
      this.dateCreated,
      this.dateLastIncremented,
      this.score,
      this.timesIncremented,
      this.daysSinceLastIncremented,
      this.createdByUserId,
      this.assignedUserId,
      this.status);
}
