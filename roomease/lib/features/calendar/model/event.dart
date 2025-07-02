class Event {
  String id;
  String name;
  String details;
  String startTime;
  String endTime;
  String dateCreated;
  String type;
  String createdByUserId;

  Event(
    this.id,
    this.name,
    this.details,
    this.startTime,
    this.endTime,
    this.dateCreated,
    this.type,
    this.createdByUserId);

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "details": details,
    "startTime": startTime,
    "endTime": endTime,
    "dateCreated": dateCreated,
    "type": type,
    "createdByUserId": createdByUserId,
  };
}
