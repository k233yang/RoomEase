import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/chores/Chore.dart';

class EditChoreFromChoreScreen extends StatefulWidget {
  const EditChoreFromChoreScreen(
      {super.key, required this.choreId, required this.onChoreUpdate});
  final String choreId;
  final Function() onChoreUpdate;

  @override
  State<EditChoreFromChoreScreen> createState() =>
      _EditChoreFromChoreScreenState();
}

class _EditChoreFromChoreScreenState extends State<EditChoreFromChoreScreen> {
  late Future<Chore?> _choreDetails;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _deadlineController = TextEditingController();
  List<String> _householdMembers = [];
  String? _selectedMember;

  @override
  void initState() {
    super.initState();
    _choreDetails = DatabaseManager.getChoreFromId(
      widget.choreId,
      CurrentHousehold.getCurrentHouseholdId(),
    );
    _loadHouseholdMembersAndChoreDetails();
  }

  Future<void> _loadHouseholdMembersAndChoreDetails() async {
    // Fetch household members
    _householdMembers = await DatabaseManager.getUserNamesFromHousehold(
        CurrentHousehold.getCurrentHouseholdId());
    _householdMembers.add('Unassigned');

    // Fetch chore details to set the initial selected member
    Chore? choreDetails = await DatabaseManager.getChoreFromId(
        widget.choreId, CurrentHousehold.getCurrentHouseholdId());
  }

  Future<void> _pickDeadline(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((deadlineDate) {
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
                DateFormat('yyyy-MM-dd hh:mm a').format(deadlineDateTime);
            setState(() {
              _deadlineController.text =
                  formattedDateTime; //set output date to TextField value.
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Chore'),
      ),
      body: FutureBuilder<Chore?>(
        future: _choreDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('Chore not found'));
          }

          // Pre-fill the form fields if the snapshot has data
          final Chore? chore = snapshot.data;
          if (_nameController.text == '') {
            _nameController.text = chore?.name ?? '';
          }
          if (_descriptionController.text == '') {
            _descriptionController.text = chore?.details ?? '';
          }
          if (_deadlineController.text == '') {
            _deadlineController.text = chore?.deadline ?? '';
          } else {}
          ; // Assume deadline is a String in 'yyyy-MM-dd' format
          //print("CHORE DETAILS: ${chore?.status}");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _deadlineController,
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(3000),
                    ).then((deadlineDate) {
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
                                DateFormat('yyyy-MM-dd hh:mm a')
                                    .format(deadlineDateTime);
                            setState(() {
                              _deadlineController.text =
                                  formattedDateTime; //set output date to TextField value.
                            });
                          }
                        });
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // update the chore in FB
                      await DatabaseManager.updateChore(
                        householdCode: CurrentHousehold.getCurrentHouseholdId(),
                        choreId: widget.choreId,
                        name: _nameController.text,
                        details: _descriptionController.text,
                        deadline: _deadlineController.text,
                        status: chore!.status,
                      );
                      widget.onChoreUpdate();
                    },
                    child: const Text('Update Chore'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
