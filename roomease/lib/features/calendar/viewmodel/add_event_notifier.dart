import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:roomease/shared/repository/user_repository.dart';
import 'package:roomease/features/calendar/data/calendar_repository.dart';
import 'package:roomease/features/calendar/data/create_event_request.dart';
import 'package:roomease/features/calendar/viewmodel/calendar_notifier.dart';

enum AddEventState { idle, submitting, success, error }

class AddEventNotifier extends ChangeNotifier {
  late final CalendarRepository repository;
  AddEventState state = AddEventState.idle;
  String? errorMessage;

  // Form inputs
  String title = "";
  String details = "";
  DateTime? startTime;
  DateTime? endTime;
  String type = "Common Area Reservation";

  AddEventNotifier(this.repository);

  void setTitle(String t) {
    title = t;
  }

  void setDetails(String d) {
    details = d;
  }

  void setType(String t) {
    type = t;
  }

  Future<void> pickStartTime(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
    ).then((date) {
      if (date == null) return;

      showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startTime ?? DateTime.now()),
      ).then((time) {
        if (time == null) return;

        startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        notifyListeners();
      });
    });
  }

  Future<void> pickEndTime(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: startTime ?? DateTime.now(),
      firstDate: startTime ?? DateTime.now(),
      lastDate: DateTime(3000),
    ).then((date) {
      if (date == null) return;

      showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startTime ?? DateTime.now()),
      ).then((time) {
        if (time == null) return;

        endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        notifyListeners();
      });
    });
  }

  String format(DateTime dt) => DateFormat("yyyy-MM-dd hh:mm a").format(dt);

  Future<bool> submit(BuildContext context) async {
    if (endTime!.isBefore(startTime!)) {
      state = AddEventState.error;
      errorMessage = "The event's start time must be before the end time";
      notifyListeners();
      return false;
    }

    state = AddEventState.submitting;
    notifyListeners();

    final request = CreateEventRequest(
      name: title,
      details: details,
      startTime: startTime!.toIso8601String(),
      endTime: endTime!.toIso8601String(),
      dateCreated: DateTime.now().toIso8601String(),
      type: type,
      createdByUserId: CurrentUser.getCurrentUserId(),
    );

    final future = context.read<CalendarNotifier>().addCalendarEvent(request)
        .then((_) {
          state = AddEventState.success;
          notifyListeners();
          return true;
        })
        .catchError((error) {
          state = AddEventState.error;
          errorMessage = error.toString();
          notifyListeners();
          return false;
        });

    return future;
  }
}