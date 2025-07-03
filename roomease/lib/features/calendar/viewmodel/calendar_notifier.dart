import 'package:flutter/foundation.dart';

import 'package:roomease/features/calendar/data/calendar_repository.dart';
import 'package:roomease/features/calendar/data/create_event_request.dart';
import 'package:roomease/features/calendar/model/event.dart';

enum CalendarViewState { loading, ready, error }

class CalendarNotifier extends ChangeNotifier {
  final CalendarRepository repository;
  CalendarViewState state = CalendarViewState.loading;
  List<Event> events = [];
  Object? error;

  CalendarNotifier(this.repository) {
    _load();
  }

  Future<void> _load() async {
    state = CalendarViewState.loading;
    notifyListeners();

    try {
      events = await repository.fetchEvents();
      state = CalendarViewState.ready;
    } catch (e) {
      error = e;
      state = CalendarViewState.error;
    }
    notifyListeners();
  }

  Future<void> addCalendarEvent(CreateEventRequest request) async {
    try {
      await repository.addEvent(request);
      await _load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    try {
      await repository.deleteEvent(eventId);
      await _load();
    } catch (e) {
      rethrow;
    }
  }
}