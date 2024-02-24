import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';

/// allows user to input a user in their current household
class MissingUserInput extends StatefulWidget {
  const MissingUserInput(
      {super.key, required this.onUserSelect, required this.placeholder});

  final Function(String) onUserSelect;
  final String placeholder;

  @override
  State<MissingUserInput> createState() => _MissingUserInputState();
}

class _MissingUserInputState extends State<MissingUserInput> {
  List<String> householdMembers = [];
  String dropdownValue = 'Select a user';

  Future<void> _loadHouseholdMembers() async {
    householdMembers = await DatabaseManager.getUserNamesFromHousehold(
        CurrentHousehold.getCurrentHouseholdId());
    householdMembers.insert(0, "Select a user");
    String currentUserName = CurrentUser.getCurrentUserName();

    // make the current user the 2nd item in the dropdown
    int currentUserIndex = householdMembers.indexOf(currentUserName);
    if (currentUserIndex != -1) {
      householdMembers.removeAt(currentUserIndex);
      householdMembers.insert(1, currentUserName);
    }
    if (householdMembers.isNotEmpty) {
      setState(() {
        dropdownValue = householdMembers[0];
      });
    }
  }

  Text renderDropDownListOptions(String userName) {
    if (userName == 'Select a user') {
      return Text(
        userName,
        style: TextStyle(color: Color.fromARGB(255, 160, 160, 160)),
      );
    }
    if (userName == CurrentUser.getCurrentUserName()) {
      return Text('$userName (You)');
    }
    return Text(userName);
  }

  @override
  void initState() {
    _loadHouseholdMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.placeholder),
        DropdownButton<String>(
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
            widget.onUserSelect(
                newValue! == 'Select a user' ? 'Missing' : newValue);
          },
          items:
              householdMembers.map<DropdownMenuItem<String>>((String userName) {
            return DropdownMenuItem<String>(
                value: userName, child: renderDropDownListOptions(userName));
          }).toList(),
        ),
      ],
    );
  }
}
