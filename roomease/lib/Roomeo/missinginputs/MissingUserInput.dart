import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';

/// allows user to input a user in their current household
class MissingUserInput extends StatefulWidget {
  const MissingUserInput(
      {super.key,
      required this.onUserSelect,
      required this.placeholder,
      this.searchPerson});

  final Function(String) onUserSelect;
  final String placeholder;
  final String? searchPerson;

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
    if (widget.searchPerson != null) {
      try {
        String userId = await searchUserFromChat(
          await getVectorEmbeddingArray(widget.searchPerson!),
          CurrentHousehold.getCurrentHouseholdId(),
        );
        String userName = await DatabaseManager.getUserName(userId);

        // Place the found user's name as the first option and move "Select a user" to the bottom
        householdMembers.removeAt(0);
        householdMembers.remove(userName);
        householdMembers.insert(0, userName);
        householdMembers.add("Select a user");
      } catch (e) {
        print("Error searching for useer: $e");
      }
    }

    if (widget.searchPerson == null) {
      // make the current user the 2nd item in the dropdown
      String currentUserName = CurrentUser.getCurrentUserName();
      int currentUserIndex = householdMembers.indexOf(currentUserName);
      if (currentUserIndex != -1) {
        householdMembers.removeAt(currentUserIndex);
        householdMembers.insert(1, currentUserName);
      }
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
