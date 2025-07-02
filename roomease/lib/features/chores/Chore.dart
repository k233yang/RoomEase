class Chore {
  String id;
  String name;
  String details;
  String deadline;
  String dateCreated;
  String dateLastIncremented;
  int points;
  int threshold;
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
      this.points,
      this.threshold,
      this.timesIncremented,
      this.daysSinceLastIncremented,
      this.createdByUserId,
      this.assignedUserId,
      this.status);

  factory Chore.buildChoreFromMap(Map<String, dynamic> map) {
    return Chore(
      map['id'] as String,
      map['name'] as String,
      map['details'] as String,
      map['deadline'] as String,
      map['dateCreated'] as String,
      map['dateLastIncremented'] as String,
      map['points'] as int,
      map['threshold'] as int,
      map['timesIncremented'] as int,
      map['daysSinceLastIncremented'] as int,
      map['createdByUserId'] as String,
      map['assignedUserId'] as String?,
      map['status'] as String,
    );
  }
}
