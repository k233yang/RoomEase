import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../CurrentHousehold.dart';
import '../Household.dart';
import '../colors/ColorConstants.dart';
import 'Event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreen();
}

class _CalendarScreen extends State<CalendarScreen> {
  late final Household currHousehold;
  late Future<String> calendarEventsLoaded;

  @override
  void initState() {
    super.initState();
    currHousehold = CurrentHousehold.getCurrentHousehold();
    calendarEventsLoaded = currHousehold.updateCalendarEventsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: getCalendar(),
      floatingActionButton: CreateAddEventButton(onButtonPress: () {
        Navigator.pushNamed(context, "/addEvent").then((value) {
          setState(() {
            calendarEventsLoaded = currHousehold.updateCalendarEventsList();
          });
        });
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // FutureBuilder<String> getFutureDataSource() {
  FutureBuilder<String> getCalendar() {
  return FutureBuilder<String>(
        future: calendarEventsLoaded,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot)
  {
    List<Widget> children;
    if (snapshot.hasData) {
      return Scaffold(
        body: SfCalendar(
          view: CalendarView.month,
          allowedViews: [
            CalendarView.day,
            CalendarView.week,
            CalendarView.month,
          ],
          dataSource: EventDataSource(currHousehold.calendarEvents),
          todayHighlightColor: ColorConstants.lightPurple,
          monthViewSettings: MonthViewSettings(showAgenda: true),
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment) {
              // TODO: Implement pop up
              // Navigator.pushNamed(context, "/addEvent");
              }
            },
        )
      );
    } else if (snapshot.hasError) {
      children = <Widget>[
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error: ${snapshot.error}'),
        ),
      ];
    } else {
      children = <Widget>[
        SizedBox(
          width: 60,
          height: 60,
          child:
          CircularProgressIndicator(color: ColorConstants.lightPurple),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Loading calendar...'),
        ),
      ];
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      )
    );
  });
  }
}

class CreateAddEventButton extends StatelessWidget {
  final VoidCallback onButtonPress;

  CreateAddEventButton({Key? key, required this.onButtonPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        foregroundColor: ColorConstants.white,
        backgroundColor: ColorConstants.lightPurple,
        shape: CircleBorder(),
        onPressed: onButtonPress,
        child: const Icon(Icons.add));
  }
}

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
    // TODO: Add if statement to set colour based on event type
    // return appointments![index].background;
    return ColorConstants.lightPurple;
  }

  @override
  bool isAllDay(int index) {
    // TODO: isAllDay is not implemented yet
    // return appointments![index].isAllDay;
    return false;
  }
}
