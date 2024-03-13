import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/missinginputs/MissingDateInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingStatusInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingUserInput.dart';
import 'package:roomease/Roomeo/missinginputs/CommandTextInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingPointInput.dart';

// Search person is used to find another household member, if the user
// specified one in their message
Widget handleAddChoreMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson, String? data}) {
  switch (missingParameter) {
    case "ChoreTitle":
      if (data != null) {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Chore name",
          message: data,
        );
      } else {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Chore name",
        );
      }
    case "ChoreDate":
      if (data != null) {
        return MissingDateInput(
          onDateSelect: (String userInput) {
            updateCallback("ChoreDate", userInput);
          },
          placeHolder: "When should the chore be completed by?",
          date: data,
        );
      } else {
        return MissingDateInput(
          onDateSelect: (String userInput) {
            updateCallback("ChoreDate", userInput);
          },
          placeHolder: "When should the chore be completed by?",
        );
      }
    case "ChoreDescription":
      if (data != null) {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreDescription", userInput);
          },
          placeHolder: "Chore Description (Optional)",
          message: data,
        );
      } else {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Chore Description (Optional)",
        );
      }
    // return Text("Hello");
    case "ChorePoints":
      if (data != null) {
        return MissingPointInput(
          onPointInput: (int userInput) {
            updateCallback("ChorePoints", userInput.toString());
          },
          placeholder: "Chore points",
          points: data,
        );
      } else {
        return MissingPointInput(
          onPointInput: (int userInput) {
            updateCallback("ChorePoints", userInput.toString());
          },
          placeholder: "Chore points",
        );
      }
    default:
      return SizedBox.shrink();
  }
}

Widget handleUpdateChoreMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson, String? data}) {
  switch (missingParameter) {
    case "ChoreTitle":
      if (data != null) {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Name of the Chore to Update",
          message: data,
        );
      } else {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Name of the Chore to Update",
        );
      }
    default:
      return SizedBox.shrink();
  }
}

Widget handleSetStatusMissingParams(
  String missingParameter,
  Function(String, String) updateCallback,
) {
  switch (missingParameter) {
    case "Status":
      return MissingStatusInput(
        onStatusInput: (String userInput) {
          updateCallback("Status", userInput);
        },
      );
    default:
      return SizedBox.shrink();
  }
}

Widget handleSendMessageMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson, String? message}) {
  switch (missingParameter) {
    case "SendPerson":
      if (searchPerson == null) {
        return MissingUserInput(
          onUserSelect: (String userInput) {
            updateCallback("SendPerson", userInput);
          },
          placeholder: "Who do you want to message?",
        );
      } else {
        print("Got in here. SearchPerson is: $searchPerson");
        return MissingUserInput(
          onUserSelect: (String userInput) {
            updateCallback("SendPerson", userInput);
          },
          placeholder: "Who Who do you want to message?",
          searchPerson: searchPerson,
        );
      }
    case "Message":
      if (message == null) {
        return CommandTextInput(
          onTextInput: (String userInput) {
            updateCallback("Message", userInput);
          },
          placeHolder: "What do you want to send?",
        );
      } else {
        return CommandTextInput(
          onTextInput: (String userInput) {
            updateCallback("Message", userInput);
          },
          placeHolder: "What do you want to send?",
          message: message,
        );
      }
    default:
      return SizedBox.shrink();
  }
}

Widget handleViewStatusMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson}) {
  switch (missingParameter) {
    case "ViewPerson":
      if (searchPerson == null) {
        return MissingUserInput(
          onUserSelect: (String userInput) {
            updateCallback("ViewPerson", userInput);
          },
          placeholder: "Whose status do you want to view?",
        );
      } else {
        print("Got in here. SearchPerson is: $searchPerson");
        return MissingUserInput(
          onUserSelect: (String userInput) {
            updateCallback("ViewPerson", userInput);
          },
          placeholder: "Whose status do you want to view?",
          searchPerson: searchPerson,
        );
      }
    default:
      return SizedBox.shrink();
  }
}

Widget handleRemoveChoreMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson, String? data}) {
  switch (missingParameter) {
    case "ChoreTitle":
      if (data != null) {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Name of the Chore to Remove",
          message: data,
        );
      } else {
        return CommandTextInput(
          onTextInput: (String userInput) {
            // just update widget.
            updateCallback("ChoreTitle", userInput);
          },
          placeHolder: "Name of the Chore to Remove",
        );
      }
    default:
      return SizedBox.shrink();
  }
}
