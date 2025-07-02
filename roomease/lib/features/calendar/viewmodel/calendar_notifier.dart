import 'package:flutter/foundation.dart';
import 'package:roomease/features/calendar/data/calendar_repository.dart';
import 'package:roomease/features/calendar/model/event.dart';

import '../data/create_event_request.dart';

enum ViewState { loading, ready, error }

class CalendarNotifier extends ChangeNotifier {
  final CalendarRepository repository;
  ViewState state = ViewState.loading;
  List<Event> events = [];
  Object? error;

  CalendarNotifier(this.repository) {
    _load();
  }

  Future<void> _load() async {
    state = ViewState.loading;
    notifyListeners();

    try {
      events = await repository.fetchEvents();
      state = ViewState.ready;
    } catch (e) {
      error = e;
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> reload() => _load();
  //
  // Future<void> addEvent(CreateEventRequest request) async {
  //   try {
  //     await repository.addEvent(request);
  //     await _load();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> deleteEvent(String eventId) async {
    try {
      await repository.deleteCalendarEvent(eventId);
      await _load();
    } catch (e) {
      rethrow;
    }
  }
}