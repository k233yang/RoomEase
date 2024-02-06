import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../colors/ColorConstants.dart';

/// A custom widget that renders if the user has not provided sufficient information
/// to Roomeo about the command they entered. (e.g. if a user has not specified a
/// date to complete a chore by for a task). The widget prompts the user to enter
/// any relevant missing information, and adjusts the commandParams parameter
/// with the missing data

class ChatScreenOptions extends StatefulWidget {
  const ChatScreenOptions(
      {super.key, required this.category, required this.commandParams});
  final String category;
  final Map<String, String> commandParams;

  @override
  State<ChatScreenOptions> createState() => _ChatScreenOptionsState();
}

class _ChatScreenOptionsState extends State<ChatScreenOptions> {
  late List<String> missingParams;
  int currentIndex = 0;

  List<String> generateMissingParamList(Map<String, String> currentParams) {
    List<String> missingParams = [];
    currentParams.forEach((key, value) {
      //TODO: might have to tweak this conditional:
      if (value.toLowerCase() == 'unknown') {
        missingParams.add(key);
      }
    });
    return missingParams;
  }

  void goToNextParam() {
    if (currentIndex < missingParams.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // unmount the widget after the last element
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    missingParams = generateMissingParamList(widget.commandParams);
  }

  @override
  Widget build(BuildContext context) {
    // if (missingParams.isEmpty) {
    //   // If there are no missing params, unmount the widget immediately
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context).pop();
    //   });
    // }

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Card(
          color: ColorConstants.lighterGray,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(missingParams[currentIndex]),
                ElevatedButton(
                  onPressed: goToNextParam,
                  child: Text('Next'),
                ),
              ],
            ),
          ),
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
