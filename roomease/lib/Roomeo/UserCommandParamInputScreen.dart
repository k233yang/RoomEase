import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../colors/ColorConstants.dart';

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
              'I need more information to ${widget.commandParams['category']}'),
          Flexible(
            child: ListView.builder(
              itemCount: missingParams.length,
              itemBuilder: (context, index) {
                return Text(missingParams[index]);
              },
            ),
          ),
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
