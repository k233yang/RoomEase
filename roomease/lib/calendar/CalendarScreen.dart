import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../CurrentHousehold.dart';
import '../DatabaseManager.dart';
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
              dynamic appointments = details.appointments;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Expanded( child: AlertDialog(
                      title: Text(appointments[0].name),
                      content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Details", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(appointments[0].details),
                            Text("Event Type", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(appointments[0].type),
                            Text("Begins", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateFormat('yyyy-mm-dd hh:mm a').format(DateTime.parse(appointments[0].startTime))),
                            Text("Ends", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateFormat('yyyy-mm-dd hh:mm a').format(DateTime.parse(appointments[0].endTime))),
                            Text(""),
                            Text("Created By", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(appointments[0].createdByUserId),
                          ]),
                      actions: [TextButton(onPressed: () {
                        // Delete event confirmation message
                        showDialog(context: context, builder: (BuildContext context) {
                          return AlertDialog(title: Text(appointments[0].name),
                              content: Text("Are you sure you would like to delete this event?"),
                              actions: [TextButton(onPressed: () {
                                try{
                                  DatabaseManager.deleteCalendarEvent(appointments[0].id).then((value) {
                                    setState(() { calendarEventsLoaded = currHousehold.updateCalendarEventsList(); });
                                  });
                                } catch (e) { print("Failed to move chore: $e"); }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(duration: const Duration(seconds: 1), content: Text('Event deleted!')));
                                Navigator.pop(context);
                                Navigator.pop(context);
                                },
                                  child: Text("Yes, delete", style: TextStyle(color: Colors.red))
                              ),
                              TextButton(onPressed: () { Navigator.pop(context); },
                                  child: Text("No, return"))
                              ]);
                        });},
                          child: Text("DELETE", style: TextStyle(color: Colors.red))
                      ),
                        TextButton(onPressed: () { Navigator.pop(context); },
                            child: Text('CLOSE')),
                      ]
                  ));
                }
              );
            }
          }
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
    if (appointments![index].type == "Location Status") {
      return Colors.blue;
    } else if (appointments![index].type == "Common Area Reservation") {
      return Colors.orange;
    } else if (appointments![index].type == "Quiet Time Request") {
      return Colors.yellow;
    }
    else {
      return Colors.purple;
    }
  }
}
