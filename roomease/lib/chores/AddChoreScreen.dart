import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import '../colors/ColorConstants.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:intl/intl.dart';

class AddChoreScreen extends StatefulWidget {
  const AddChoreScreen({super.key});

  @override
  State<AddChoreScreen> createState() => _AddChoreScreen();
}

const List<int> pointsList = <int>[1, 2, 3, 4, 5];
const List<int> thresholdList = <int>[1, 2, 3, 4, 5];

class _AddChoreScreen extends State<AddChoreScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  int points = pointsList.first;
  int threshold = thresholdList.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add a Chore'),
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
                            return 'Please enter a title for the chore';
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
                            return 'Please enter details for the chore';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: deadlineController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Deadline",
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
                                    deadlineController.text =
                                        formattedDateTime; //set output date to TextField value.
                                  });
                                }
                              });
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a deadline for the chore';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: DropdownButtonFormField(
                        value: points,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Points",
                          labelText: "Points",
                        ),
                        onChanged: (int? pointsValue) {
                          setState(() {
                            points = pointsValue!;
                          });
                        },
                        items: pointsList.map((int val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val.toString()),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter the number of points for the chore';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: DropdownButtonFormField(
                        value: threshold,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Threshold",
                          labelText: "Threshold",
                        ),
                        onChanged: (int? thresholdValue) {
                          setState(() {
                            thresholdValue = thresholdValue!;
                          });
                        },
                        items: thresholdList.map((int val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val.toString()),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please enter a threshold value for the chore';
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
                              DatabaseManager.addChore(
                                  CurrentHousehold.getCurrentHouseholdId(),
                                  nameController.text,
                                  detailsController.text,
                                  deadlineController.text,
                                  points,
                                  threshold,
                                  CurrentUser.getCurrentUserId());
                            } catch (e) {
                              print('Failed to add chore: $e');
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Chore successfully added!')));
                          }
                        },
                        child: const Text('Submit'),
                      ))
                ]))));
  }
}
