import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../model/event.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    print("Debug: START TIME original is ${appointments![index].startTime}");
    print("Debug: START TIME parsed is ${DateTime.parse(appointments![index].startTime)}");
    print("");
    return DateTime.parse(appointments![index].startTime);
  }

  @override
  DateTime getEndTime(int index) {
    print("Debug: END TIME original is ${appointments![index].endTime}");
    print("Debug: END TIME parsed is ${DateTime.parse(appointments![index].endTime)}");
    print("");
    return DateTime.parse(appointments![index].endTime);
  }

  @override
  String getSubject(int index) {
    return appointments![index].name;
  }

  @override
  Color getColor(int index) {
    if (appointments![index].type == "Location Status") {
      return Colors.blue;
    } else if (appointments![index].type == "Common Area Reservation") {
      return Colors.orange;
    } else if (appointments![index].type == "Quiet Time Request") {
      return Colors.lightGreen;
    }
    else {
      return Colors.purple;
    }
  }
}
