import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../colors/ColorConstants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreen();
}

class _CalendarScreen extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: SfCalendar(
        view: CalendarView.month,
      ),
    floatingActionButton: CreateAddEventButton(onButtonPress: () {
      Navigator.pushNamed(context, "/addEvent").then((value) {
        setState(() {

        });
      });
    }),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
        backgroundColor: ColorConstants.darkPurple,
        shape: CircleBorder(),
        onPressed: onButtonPress,
        child: const Icon(Icons.add));
  }
}