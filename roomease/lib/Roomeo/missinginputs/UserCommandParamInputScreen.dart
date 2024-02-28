import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/missinginputs/MissingDateInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingStatusInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingUserInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingTextInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingPointInput.dart';
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

  List<String> generateMissingParamList(Map<String, String> currentParams) {
    List<String> missingParams = [];
    currentParams.forEach((key, value) {
      if (value == 'Missing') {
        missingParams.add(key);
      }
    });
    return missingParams;
  }

  Widget generateMissingInputWidgets(String commandCategory) {
    if (commandCategory.contains('Title')) {
      return MissingTextInput(onTextInput: (String userInput) {
        // just update widget.
        widget.commandParams[commandCategory] = userInput;
      });
    } else if (commandCategory.contains('Date')) {
      return MissingDateInput(onDateSelect: (DateTime userInput) {
        widget.commandParams[commandCategory] = userInput.toString();
      });
    } else if (commandCategory.contains('Description')) {
      return MissingTextInput(
        isInputSingleLine: false,
        onTextInput: (String userInput) {
          widget.commandParams[commandCategory] = userInput;
        },
      );
    } else if (commandCategory.contains('Message')) {
      return MissingTextInput(
        isInputSingleLine: false,
        isMessageInput: true,
        onTextInput: (String userInput) {
          widget.commandParams[commandCategory] = userInput;
        },
      );
    } else if (commandCategory.contains('ChorePerson')) {
      return MissingUserInput(
        onUserSelect: (String userInput) {
          widget.commandParams[commandCategory] = userInput;
        },
        placeholder: 'Select a person to assign this chore to:',
      );
    } else if (commandCategory.contains('ViewPerson')) {
      return MissingUserInput(
        onUserSelect: (String userInput) {
          widget.commandParams[commandCategory] = userInput;
        },
        placeholder: "Select a person's status to view:",
      );
    } else if (commandCategory.contains('SendPerson')) {
      return MissingUserInput(
        onUserSelect: (String userInput) {
          widget.commandParams[commandCategory] = userInput;
        },
        placeholder: "Who would you like to message? :",
      );
    } else if (commandCategory.contains('Status')) {
      return MissingStatusInput(onStatusInput: (String userInput) {
        widget.commandParams[commandCategory] = userInput;
      });
    } else if (commandCategory == 'ChorePointsThreshold') {
      return MissingPointInput(
        onPointInput: (int userInput) {
          widget.commandParams[commandCategory] = userInput.toString();
        },
        placeholder: 'Points Threshold',
      );
    } else if (commandCategory == 'ChorePoints') {
      return MissingPointInput(
        onPointInput: (int userInput) {
          widget.commandParams[commandCategory] = userInput.toString();
        },
        placeholder: 'Points',
      );
    } else {
      return Text('You fucked up');
    }
  }

  void onSubmitMissingParams() {
    bool hasMissingNonDescription = widget.commandParams.entries.any(
      (entry) => entry.value == "Missing" && !entry.key.contains("Description"),
    );

    if (hasMissingNonDescription) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Incomplete Information"),
            content:
                Text("Please fill out the missing values before proceeding."),
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
      // TODO: go back to chat screen and do shit with the newly updated params
      print(widget.commandParams);
      Navigator.of(context).pop({
        'exited': false,
        'data': widget.commandParams,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    missingParams = generateMissingParamList(widget.commandParams);
    print("MISSING PARAMS: $missingParams");
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
              'More information needed to ${widget.category.toLowerCase()}:',
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
                  return generateMissingInputWidgets(missingParams[index]);
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