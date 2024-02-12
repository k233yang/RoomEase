import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import '../colors/ColorConstants.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreen();
}

const List<String> typeList = <String>["Location Status", "Common Area Reservation", "Custom Event"];

class _AddEventScreen extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  String type = typeList.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add an Event'),
          backgroundColor: ColorConstants.lightPurple,
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Add title"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title for the event';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: detailsController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Add details",
                          //fillColor: ColorConstants.lighterGray,
                          //filled: true,
                        ),
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter details for the event';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: startTimeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Start time",
                        ),
                        readOnly: true,
                        onTap: () async {
                          await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(3000))
                              .then((deadlineDate) {
                            if (deadlineDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((deadlineTime) {
                                if (deadlineTime != null) {
                                  DateTime deadlineDateTime = DateTime(
                                    deadlineDate.year,
                                    deadlineDate.month,
                                    deadlineDate.day,
                                    deadlineTime.hour,
                                    deadlineTime.minute,
                                  );
                                  String formattedDateTime =
                                  DateFormat('yyyy-MM-dd')
                                      .add_jm()
                                      .format(deadlineDateTime);
                                  setState(() {
                                    startTimeController.text =
                                        formattedDateTime; //set output date to TextField value.
                                  });
                                }
                              });
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a start time for the event';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: endTimeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "End time",
                        ),
                        readOnly: true,
                        onTap: () async {
                          await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(3000))
                              .then((deadlineDate) {
                            if (deadlineDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((deadlineTime) {
                                if (deadlineTime != null) {
                                  DateTime deadlineDateTime = DateTime(
                                    deadlineDate.year,
                                    deadlineDate.month,
                                    deadlineDate.day,
                                    deadlineTime.hour,
                                    deadlineTime.minute,
                                  );
                                  String formattedDateTime =
                                  DateFormat('yyyy-MM-dd')
                                      .add_jm()
                                      .format(deadlineDateTime);
                                  setState(() {
                                    endTimeController.text =
                                        formattedDateTime; //set output date to TextField value.
                                  });
                                }
                              });
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a end time for the event';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select an event type",
                          labelText: "Event type",
                        ),
                        onChanged: (String? typeValue) {
                          setState(() {
                            type = typeValue!;
                          });
                        },
                        items: typeList.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val.toString()),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an event type';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              // DatabaseManager.addChore(
                              //     CurrentHousehold.getCurrentHouseholdId(),
                              //     nameController.text,
                              //     detailsController.text,
                              //     startTimeController.text,
                              //     typeValue,
                              //     threshold,
                              //     0,
                              //     0,
                              //     CurrentUser.getCurrentUserId(),
                              //     null,
                              //     ChoreStatus.toDo.value
                              // );
                            } catch (e) {
                              print('Failed to add event: $e');
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Event successfully added!')));
                          }
                        },
                        child: const Text('Submit'),
                      )
                  )
                ])
            )
        )
    );
  }
}
