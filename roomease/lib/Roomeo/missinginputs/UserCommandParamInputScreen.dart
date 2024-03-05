import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/missinginputs/MissingCommandHandlers.dart';
import '../../colors/ColorConstants.dart';

/// A custom widget that renders if the user has not provided sufficient information
/// to Roomeo about the command they entered. (e.g. if a user has not specified a
/// date to complete a chore by for a chore). The widget prompts the user to enter
/// any relevant missing information, and adjusts the commandParams parameter
/// with the missing data

class UserCommandParamInputScreen extends StatefulWidget {
  const UserCommandParamInputScreen({
    super.key,
    required this.category,
    required this.commandParams,
    required this.onParamsUpdated,
  });
  final String category;
  final Map<String, String> commandParams;
  final Function(Map<String, String>) onParamsUpdated;

  @override
  State<UserCommandParamInputScreen> createState() =>
      _UserCommandParamInputScreenState();
}

class _UserCommandParamInputScreenState
    extends State<UserCommandParamInputScreen> {
  late List<String> missingParams;
  int currentIndex = 0;

  bool hasMissingMandatoryParameters() {
    switch (widget.category) {
      case "Add Chore":
        List<String> requiredKeys = [
          "ChoreTitle",
          "ChoreDate",
          "ChorePerson",
          "ChorePoints",
          "ChorePointsThreshold"
        ];
        for (String key in requiredKeys) {
          if (!widget.commandParams.containsKey(key) ||
              widget.commandParams[key] == "Missing") {
            return true;
          }
        }
        return false;
      case "Remove Chore":
        List<String> requiredKeys = [
          "ChoreTitle",
        ];
        for (String key in requiredKeys) {
          if (!widget.commandParams.containsKey(key) ||
              widget.commandParams[key] == "Missing") {
            return true;
          }
        }
        return false;
      case "Update Chore":
        List<String> requiredKeys = [
          "ChoreTitle",
        ];
        for (String key in requiredKeys) {
          if (!widget.commandParams.containsKey(key) ||
              widget.commandParams[key] == "Missing") {
            return true;
          }
        }
        return false;
      case "Set Status":
        List<String> requiredKeys = [
          "Status",
        ];
        for (String key in requiredKeys) {
          if (!widget.commandParams.containsKey(key) ||
              widget.commandParams[key] == "Missing") {
            return true;
          }
        }
        return false;
      case "Send a Message":
        List<String> requiredKeys = [
          "SendPerson",
          "Message",
        ];
        for (String key in requiredKeys) {
          if (!widget.commandParams.containsKey(key) ||
              widget.commandParams[key] == "Missing") {
            return true;
          }
        }
        return false;
    }
    return false;
  }

  List<String> generateMissingParamList(Map<String, String> currentParams) {
    List<String> missingParams = [];
    currentParams.forEach((key, value) {
      if (value == 'Missing' || key.contains("Person")) {
        missingParams.add(key);
      }
    });
    return missingParams;
  }

  void updateCommandParams(String key, String value) {
    setState(() {
      widget.commandParams[key] = value;
    });
  }

  Widget generateMissingInputWidgets(
      String missingParameter, String commandCategory,
      {String? chorePerson}) {
    switch (commandCategory) {
      case "Add Chore":
        return handleAddChoreMissingParams(
            missingParameter, updateCommandParams,
            searchPerson: chorePerson);
      case "Update Chore":
        return handleUpdateChoreMissingParams(
            missingParameter, updateCommandParams,
            searchPerson: chorePerson);
      case "Remove Chore":
        return handleRemoveChoreMissingParams(
            missingParameter, updateCommandParams,
            searchPerson: chorePerson);
      default:
        return SizedBox.shrink();
    }
  }

  void onSubmitMissingParams() {
    if (hasMissingMandatoryParameters()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Incomplete Information"),
            content:
                Text("Please fill out the necessary values before proceeding."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop({
        'exited': false,
        'data': widget.commandParams,
      });
    }
  }

  String determineHeaderText(String category) {
    if (category == "Update Chore") {
      return "Tell me the details about the chore you wish to update";
    }
    if (category == "Remove Chore") {
      return "Tell me the details about the chore you wish to remove";
    }
    return "I need more information to ${category.toLowerCase()}";
  }

  @override
  void initState() {
    super.initState();
    missingParams = generateMissingParamList(widget.commandParams);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fill out Missing Info'),
          backgroundColor: ColorConstants.lightPurple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop({
                'exited': true,
                'data': widget.commandParams,
              });
            },
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              determineHeaderText(widget.category),
              style: TextStyle(
                color: Color.fromARGB(255, 160, 160, 160),
                fontSize: 18,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true, // Make ListView as tall as its children
                itemCount: missingParams.length,
                itemBuilder: (context, index) {
                  if (missingParams[index].contains("Person")) {
                    return generateMissingInputWidgets(
                      missingParams[index],
                      widget.category,
                      chorePerson: widget.commandParams[missingParams[index]] ==
                              'Missing'
                          ? null
                          : widget.commandParams[missingParams[index]],
                    );
                  } else {
                    return generateMissingInputWidgets(
                      missingParams[index],
                      widget.category,
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: onSubmitMissingParams,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ColorConstants.lightPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

// categories are: 'View Schedule', 'Add to Schedule, 'Remove from Schedule', 'Update Schedule',
//'View Status', 'Set Status', 'Chore Delegation', 'Ask for Advice', 'Send a Message'.
// Categorize the message as 'Unknown' if the user input cannot be categorized or if the input
// is irrelevant to the previous categories. Give me only the category of the message, and
// nothing else. The user input is: '$message'"

// checklist:
// done (on my end): add to schedule, view schedule, set status, view status
// total done: (4/9)