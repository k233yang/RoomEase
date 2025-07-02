class Event {
  String id;
  String name; // eventName
  String details;
  String startTime; // from
  String endTime; // to
  String dateCreated;
  String type; // decides background colour
  String createdByUserId;
  // TODO: add isAllDay boolean option

  Event(
    this.id,
    this.name,
    this.details,
    this.startTime,
    this.endTime,
    this.dateCreated,
    this.type,
    this.createdByUserId);
}