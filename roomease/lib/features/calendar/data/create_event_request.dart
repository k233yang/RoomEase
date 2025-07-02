class CreateEventRequest {
  final String name;
  final String details;
  final String startTime;
  final String endTime;
  final String dateCreated;
  final String type;
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
