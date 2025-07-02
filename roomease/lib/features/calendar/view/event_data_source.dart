import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:roomease/features/calendar/model/event.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime.parse(appointments![index].startTime);
  }

  @override
  DateTime getEndTime(int index) {
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
