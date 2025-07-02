import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomease/features/calendar/view/calendar_body.dart';

import 'package:roomease/shared/repository/household_repository.dart';
import 'package:roomease/shared/color_constants.dart';

import '../data/calendar_repository.dart';
import '../viewmodel/calendar_notifier.dart';

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
        Navigator.pushNamed(context, "/addEvent").then((addSuccessful) {
          if (addSuccessful == true) {
            context.read<CalendarNotifier>().reload();
          }
        });
      }),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final currHousehold = CurrentHousehold.getCurrentHousehold();
  //   final repository = CalendarRepository(
  //       FirebaseDatabase.instance, currHousehold.id);
  //
  //
  //   return ChangeNotifierProvider<CalendarNotifier>(
  //     create: (_) => CalendarNotifier(repository),
  //     child: Scaffold(
  //       appBar: AppBar(
  //         title: const Text("Calendar"),
  //         backgroundColor: ColorConstants.lightPurple,
  //       ),
  //       body: CalendarBody(),
  //       floatingActionButton: _buildAddEventButton( () {
  //         Navigator.pushNamed(context, "/addEvent").then((_) {
  //                 context.read<CalendarNotifier>().reload();
  //         });
  //       }),
  //       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  //     ),
  //   );
  // }

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
