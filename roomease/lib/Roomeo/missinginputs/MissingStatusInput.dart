import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';

class MissingStatusInput extends StatefulWidget {
  const MissingStatusInput({super.key, required this.onStatusInput});

  final Function(String) onStatusInput;

  @override
  State<MissingStatusInput> createState() => _MissingStatusInputState();
}

class _MissingStatusInputState extends State<MissingStatusInput> {
  late String dropdownValue;
  late List<String> possibleStatuses;

  @override
  void initState() {
    super.initState();
    dropdownValue =
        'Select a status'; // Or CurrentUser.getCurrentUserStatusList().first;
    possibleStatuses = CurrentUser.getCurrentUserStatusList();
    possibleStatuses.insert(0, dropdownValue);
  }

  void pushAddStatus(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/addCustomStatus", (_) => true)
        .then((value) => setState(() {}));
  }

  Widget addCustomUserStatusButton(BuildContext context) {
    return OutlinedButton(
        child: Text("Add Custom Status"),
        onPressed: () {
          pushAddStatus(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: DropdownButton<String>(
            value: dropdownValue,
            items:
                possibleStatuses.map<DropdownMenuItem<String>>((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: status == 'Select a status'
                    ? Text(
                        status,
                        style: TextStyle(color: Colors.grey),
                      )
                    : Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                dropdownValue = value!;
              });
              if (dropdownValue != 'Select a status') {
                widget.onStatusInput(dropdownValue);
              } else {
                widget.onStatusInput('Missing');
              }
            },
          ),
        ),
        addCustomUserStatusButton(context)
      ],
    );
  }
}
