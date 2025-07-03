import 'package:firebase_database/firebase_database.dart';

import 'package:roomease/features/calendar/data/create_event_request.dart';
import 'package:roomease/features/calendar/model/event.dart';

class CalendarRepository {
  final FirebaseDatabase _databaseInstance;
  final String _householdId;

  CalendarRepository(this._databaseInstance, this._householdId);

  Future<List<Event>> fetchEvents() async {
    final eventsRef = _databaseInstance.ref("households/$_householdId/events");
    final snapshot = await eventsRef.get();
    final eventsJson = snapshot.children;

    List<Event> eventsList = <Event>[];

    for (final event in eventsJson) {
      eventsList.add(Event(
          event.child("id").value.toString(),
          event.child("name").value.toString(),
          event.child("details").value.toString(),
          event.child("startTime").value.toString(),
          event.child("endTime").value.toString(),
          event.child("dateCreated").value.toString(),
          event.child("type").value.toString(),
          event.child("createdByUserId").value.toString()));
    }
    return eventsList;
  }

  Future<void> addEvent(CreateEventRequest request) async {
    final newRef = _databaseInstance.ref("households/$_householdId/events").push();
    final newId = newRef.key;
    if (newId == null) {
      throw Exception("Could not generate new event key");
    }

    final newEvent = Event(
      newId,
      request.name,
      request.details,
      request.startTime,
      request.endTime,
      request.dateCreated,
      request.type,
      request.createdByUserId);

    await newRef.set(newEvent.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    final eventsRef = _databaseInstance.ref("households/$_householdId/events/$eventId");
    await eventsRef.remove();
  }
}
