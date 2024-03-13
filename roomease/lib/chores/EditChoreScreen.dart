import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:roomease/Roomeo/Roomeo.dart';
import 'package:roomease/chores/Chore.dart';

class EditChoreScreen extends StatefulWidget {
  const EditChoreScreen(
      {super.key, required this.choreId, required this.onChoreUpdate});
  final String choreId;
  final Function(String, Chore) onChoreUpdate;

  @override
  State<EditChoreScreen> createState() => _EditChoreScreenState();
}

class _EditChoreScreenState extends State<EditChoreScreen> {
  late Future<Chore?> _choreDetails;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _thresholdController = TextEditingController();
  DateTime? _selectedDeadline;
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

    // Fetch chore details to set the initial selected member
    Chore? choreDetails = await DatabaseManager.getChoreFromId(
        widget.choreId, CurrentHousehold.getCurrentHouseholdId());
    if (choreDetails != null) {
      String selectedMember = await DatabaseManager.getUserName(
          choreDetails.assignedUserId ?? 'Unassigned');
      setState(() {
        _selectedMember =
            selectedMember; // Assuming Chore has an 'assignedTo' field with the member's name
      });
    }
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
          _nameController.text = chore?.name ?? '';
          _descriptionController.text = chore?.details ?? '';
          _pointsController.text = chore?.points.toString() ?? '';
          _thresholdController.text = chore?.threshold.toString() ?? '';
          _deadlineController.text = chore?.deadline ??
              ''; // Assume deadline is a String in 'yyyy-MM-dd' format
          //print("CHORE DETAILS: ${chore?.status}");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Chore Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Text("Assigned to:"),
                DropdownButton<String>(
                  value: _selectedMember,
                  icon: const Icon(Icons.arrow_downward),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMember = newValue;
                    });
                  },
                  items: _householdMembers
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _deadlineController,
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Make this field read-only
                  onTap: () => _pickDeadline(context),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _thresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Point increase frequency (days)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                        points: int.tryParse(_pointsController.text),
                        threshold: int.tryParse(_thresholdController.text),
                        assignedUserId: await DatabaseManager.getUserIdByName(
                            _selectedMember!),
                        status:
                            chore!.status, //TODO: add option to change status
                      );
                      // propagate the updated chore to household VDB.
                      // This is done through modifying the original
                      // chore vector with a new add chore vector
                      Map<String, String> newAddChoreParams = {
                        'category': 'Add Chore',
                        'ChoreTitle': _nameController.text,
                        'ChoreDescription': _descriptionController.text,
                        'ChoreDate': _deadlineController.text,
                        'ChorePerson': _selectedMember!
                      };
                      String newAddChoreString =
                          generateFullCommandInput(newAddChoreParams);
                      await updateVector(
                          await getVectorEmbeddingArray(newAddChoreString),
                          CurrentHousehold.getCurrentHouseholdId(),
                          widget.choreId);
                      widget.onChoreUpdate(chore.id, chore);
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
