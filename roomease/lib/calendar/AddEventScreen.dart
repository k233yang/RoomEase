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

const List<String> typeList = <String>["Common Area Reservation", "Location Status", "Quiet Time Request", "Other"];

class _AddEventScreen extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  String startTimeFormattedForParsing = "";
  String endTimeFormattedForParsing = "";

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
                              .then((startDate) {
                            if (startDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((startTime) {
                                if (startTime != null) {
                                  DateTime startDateTime = DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day,
                                    startTime.hour,
                                    startTime.minute,
                                  );
                                  startTimeFormattedForParsing = startDateTime.toString();
                                  String formattedDateTime =
                                  DateFormat('yyyy-MM-dd')
                                      .add_jm()
                                      .format(startDateTime);
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
                              .then((endDate) {
                            if (endDate != null) {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((endTime) {
                                if (endTime != null) {
                                  DateTime endDateTime = DateTime(
                                    endDate.year,
                                    endDate.month,
                                    endDate.day,
                                    endTime.hour,
                                    endTime.minute,
                                  );
                                  endTimeFormattedForParsing = endDateTime.toString();
                                  String formattedDateTime =
                                  DateFormat('yyyy-MM-dd')
                                      .add_jm()
                                      .format(endDateTime);
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
                              DatabaseManager.addEvent(
                                CurrentHousehold.getCurrentHouseholdId(),
                                nameController.text,
                                detailsController.text,
                                startTimeFormattedForParsing,
                                endTimeFormattedForParsing,
                                DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
                                type,
                                CurrentUser.getCurrentUserId(),
                              );
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
