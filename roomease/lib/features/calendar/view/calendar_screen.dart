import 'package:flutter/material.dart';

import 'package:roomease/features/calendar/view/calendar_body.dart';
import 'package:roomease/shared/color_constants.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: CalendarBody(),
      floatingActionButton: _buildAddEventButton( () {
        Navigator.pushNamed(context, "/addEvent");
      }),
    );
  }

  Widget _buildAddEventButton(VoidCallback onPress) {
    return FloatingActionButton(
        foregroundColor: ColorConstants.white,
        backgroundColor: ColorConstants.lightPurple,
        shape: CircleBorder(),
        onPressed: onPress,
        child: const Icon(Icons.add)
    );
  }
}
