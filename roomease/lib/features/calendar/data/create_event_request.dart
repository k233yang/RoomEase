class CreateEventRequest {
  final String name; // eventName
  final String details;
  final String startTime; // from
  final String endTime; // to
  final String dateCreated;
  final String type; // decides background colour
  final String createdByUserId;

  CreateEventRequest({
    required this.name,
    required this.details,
    required this.startTime,
    required this.endTime,
    required this.dateCreated,
    required this.type,
    required this.createdByUserId,
});
}