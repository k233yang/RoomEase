import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/missinginputs/MissingDateInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingStatusInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingUserInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingTextInput.dart';
import '../../colors/ColorConstants.dart';

/// A custom widget that renders if the user has not provided sufficient information
/// to Roomeo about the command they entered. (e.g. if a user has not specified a
/// date to complete a chore by for a task). The widget prompts the user to enter
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
    if (commandCategory.contains('TaskTitle')) {
      return MissingTextInput(onTextInput: (String userInput) {
        // just update widget.
        widget.commandParams[commandCategory] = userInput;
      });
    } else if (commandCategory.contains('TaskDate')) {
      return MissingDateInput(onDateSelect: (DateTime userInput) {
        widget.commandParams[commandCategory] = userInput.toString();
      });
    } else if (commandCategory.contains('TaskDescription')) {
      return MissingTextInput(
        isInputSingleLine: false,
        onTextInput: (String userInput) {
          widget.commandParams[commandCategory] = userInput;
        },
      );
    } else if (commandCategory.contains('TaskPerson')) {
      return MissingUserInput(onUserSelect: (String userInput) {
        widget.commandParams[commandCategory] = userInput;
      });
    } else if (commandCategory.contains('Status')) {
      return MissingStatusInput(onStatusInput: (String userInput) {
        widget.commandParams[commandCategory] = userInput;
      });
    } else {
      return Text('You fucked up');
    }
  }

  void onSubmitMissingParams() {
    // TODO: go back to chat screen and do shit with the newly updated params
    print(widget.commandParams);
  }

  @override
  void initState() {
    super.initState();
    missingParams = generateMissingParamList(widget.commandParams);
    print("MISSING PARAMS: $missingParams");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

// categories are: 'View Schedule', 'Add to Schedule, 'Remove from Schedule', 'Update Schedule',
//'View Status', 'Set Status', 'Chore Delegation', 'Ask for Advice', 'Send a Message'.
// Categorize the message as 'Unknown' if the user input cannot be categorized or if the input
// is irrelevant to the previous categories. Give me only the category of the message, and
// nothing else. The user input is: '$message'"

// checklist:
// done (on my end): add to schedule, view schedule, set status 
// total done: (3/9)