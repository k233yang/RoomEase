import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';

/// allows user to input a user in their current household
class MissingUserInput extends StatefulWidget {
  const MissingUserInput({super.key, required this.onUserSelect});

  final Function(String) onUserSelect;

  @override
  State<MissingUserInput> createState() => _MissingUserInputState();
}

class _MissingUserInputState extends State<MissingUserInput> {
  late List<String> householdMembers;
  late String dropdownValue;

  Future<void> _loadHouseholdMembers() async {
    householdMembers = await DatabaseManager.getUserNamesFromHousehold(
        CurrentHousehold.getCurrentHouseholdId());
    String currentUserName = CurrentUser.getCurrentUserName();
    int currentUserIndex = householdMembers.indexOf(currentUserName);
    if (currentUserIndex != -1) {
      householdMembers.removeAt(currentUserIndex);
      householdMembers.insert(0, currentUserName);
    }
    if (householdMembers.isNotEmpty) {
      setState(() {
        dropdownValue = householdMembers[0];
      });
    }
  }

  @override
  void initState() {
    _loadHouseholdMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = newValue!;
        });
        widget.onUserSelect(newValue!);
      },
      items: householdMembers.map<DropdownMenuItem<String>>((String userName) {
        return DropdownMenuItem<String>(
          value: userName,
          child: Text(userName),
        );
      }).toList(),
    );
  }
}
