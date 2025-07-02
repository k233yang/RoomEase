import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roomease/features/calendar/viewmodel/calendar_notifier.dart';
import 'package:roomease/shared/data/database_manager.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';

import '../../../shared/color_constants.dart';
import '../model/event.dart';
import 'event_data_source.dart';

class CalendarBody extends StatelessWidget {
  CalendarBody({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarNotifier>();

    switch (viewModel.state) {
      case ViewState.loading:
        return _buildLoading();
      case ViewState.ready:
        return _buildCalendar(viewModel.events, context);
      case ViewState.error:
        return _buildError(viewModel.error);
    }
  }


  Widget _buildLoading() =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: ColorConstants.lightPurple),
            const SizedBox(height: 12),
            const Text('Loading calendar...'),
          ],
        ),
      );

  Widget _buildError(Object? error) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 8),
            Text("Error: $error"),
          ],
        ),
      );

  Widget _buildCalendar(List<Event> events, BuildContext context) {
    // final events = repository.fetchEvents();

    return SfCalendar(
      view: CalendarView.month,
      allowedViews: [CalendarView.day, CalendarView.week, CalendarView.month],
      dataSource: EventDataSource(events),
      todayHighlightColor: ColorConstants.lightPurple,
      monthViewSettings: MonthViewSettings(showAgenda: true),
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.appointment) {
          final appointment = (details.appointments!).first as Event;
          _showEventDialog(context, appointment);
        }
      },
    );
  }

  void _showEventDialog(BuildContext context, Event appointment) {
    final calendarVm = context.read<CalendarNotifier>();

    showDialog(
      context: context,
      builder: (_) =>
          FutureBuilder<String>(
            future: DatabaseManager.getUserName(appointment.createdByUserId),
            builder: (BuildContext dialogContext, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                    content: Center(child: CircularProgressIndicator())
                );
              } else if (snapshot.hasError) {
                return AlertDialog(
                    title: const Text ("Error"),
                    content: Text("$snapshot.error}")
                );
              } else {
                final userName = snapshot.data!;
                return AlertDialog(
                  title: Text(appointment.name, overflow: TextOverflow.ellipsis),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Details ${appointment.details}"),
                      const SizedBox(height: 8),
                      Text("Type: ${appointment.type}"),
                      const SizedBox(height: 8),
                      Text('Starts: ${DateFormat('yyyy-MM-dd hh:mm a').format(
                          DateTime.parse(appointment.startTime))}'),
                      Text('Ends: ${DateFormat('yyyy-MM-dd hh:mm a').format(
                          DateTime.parse(appointment.endTime))}'),
                      const SizedBox(height: 8),
                      Text('Created by: $userName'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("CLOSE"),
                    ),
                    TextButton(
                      onPressed: () {
                        calendarVm.deleteEvent(appointment.id).then((_) {
                          Navigator.pop(dialogContext);
                          calendarVm.reload();
                          // Navigator.pop(context);
                        }).catchError((error) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text("Delete failed: $error"))
                          );
                        });
                      },
                      child: const Text(
                          "DELETE", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              }
            },
          ),
    );
  }
}
