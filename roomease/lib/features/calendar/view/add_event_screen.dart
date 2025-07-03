import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roomease/features/calendar/data/calendar_repository.dart';
import 'package:roomease/features/calendar/viewmodel/add_event_notifier.dart';
import 'package:roomease/shared/color_constants.dart';
import 'package:roomease/shared/repository/household_repository.dart';

const List<String> typeList = <String>[
  "Common Area Reservation",
  "Location Status",
  "Quiet Time Request",
  "Other"
];

class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final householdId = CurrentHousehold.getCurrentHouseholdId();
    final repository = CalendarRepository(FirebaseDatabase.instance, householdId);

    return ChangeNotifierProvider(
      create: (_) => AddEventNotifier(repository),
      child: _AddEventForm(),
    );
  }
}

class _AddEventForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEventNotifier>();

    final startText = viewModel.startTime != null ? viewModel.format(viewModel.startTime!) : "";
    final endText = viewModel.endTime != null ? viewModel.format(viewModel.endTime!) : "";

    if (_startTimeController.text != startText) {
      _startTimeController.text = startText;
    }

    if (_endTimeController.text != endText) {
      _endTimeController.text = endText;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add an Event"),
        backgroundColor: ColorConstants.lightPurple,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [

            TextFormField(
              decoration: const InputDecoration(labelText: "Title"),
              onChanged: viewModel.setTitle,
              validator: (v) => (v?.isEmpty ?? true) ? "Please enter a title" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              decoration: const InputDecoration(labelText: "Details"),
              onChanged: viewModel.setDetails,
              validator: (v) => (v?.isEmpty ?? true) ? "Please enter details" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _startTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Start Time",
              ),
              onTap: () => viewModel.pickStartTime(context),
              validator: (_) => viewModel.startTime == null ? "Please select a start time" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _endTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "End Time",
              ),
              onTap: () => viewModel.pickEndTime(context),
              validator: (_) => viewModel.endTime == null ? "Please select an end time" : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: viewModel.type,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Event Type",
              ),
              items: typeList
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) {
                if (value != null) viewModel.setType(value);
              },
              validator: (_) => viewModel.type.isEmpty ? "Please select a type" : null,
            ),
            const SizedBox(height: 24),

            if (viewModel.state == AddEventState.error && viewModel.errorMessage != null) ... [
              Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],

            ElevatedButton(
              onPressed: viewModel.state == AddEventState.submitting ? null: () {
                if (_formKey.currentState!.validate()) {
                  viewModel.submit(context).then((success) {
                    if (success) {
                      Navigator.pop(context, true);
                    }
                  });
                }
              },
              child: viewModel.state == AddEventState.submitting ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ) : const Text('Submit'),
            ),
          ],),
        ),
      ),
    );
  }
}
