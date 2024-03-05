import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/missinginputs/MissingDateInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingStatusInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingUserInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingTextInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingPointInput.dart';
import '../../colors/ColorConstants.dart';

// TODO: search for a person based on a user input

Widget handleAddChoreMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson}) {
  switch (missingParameter) {
    case "ChoreTitle":
      return MissingTextInput(
        onTextInput: (String userInput) {
          // just update widget.
          updateCallback("ChoreTitle", userInput);
        },
        placeHolder: "Chore name",
      );
    case "ChoreDate":
      return MissingDateInput(
        onDateSelect: (DateTime userInput) {
          updateCallback("ChoreDate", userInput.toString());
        },
        placeHolder: "When should the chore be completed by?",
      );
    case "ChoreDescription":
      return MissingTextInput(
        onTextInput: (String userInput) {
          // just update widget.
          updateCallback("ChoreDescription", userInput);
        },
        placeHolder: "Chore Description (Optional)",
        isInputSingleLine: false,
      );
    // return Text("Hello");
    case "ChorePerson":
      if (searchPerson == null) {
        return MissingUserInput(
          onUserSelect: (String userInput) {
            updateCallback("ChorePerson", userInput);
          },
          placeholder: "Who is responsible for the chore?",
        );
      } else {
        print("Got in here. SearchPerson is: $searchPerson");
        return MissingUserInput(
          onUserSelect: (String userInput) {
            updateCallback("ChorePerson", userInput);
          },
          placeholder: "Who is responsible for the chore?",
          searchPerson: searchPerson,
        );
      }
    // return Text("Hello");
    case "ChorePoints":
      return MissingPointInput(
        onPointInput: (int userInput) {
          updateCallback("ChorePoints", userInput.toString());
        },
        placeholder: "Chore points",
      );
    // return Text("Hello");
    case "ChorePointsThreshold":
      return MissingPointInput(
        onPointInput: (int userInput) {
          updateCallback("ChorePointsThreshold", userInput.toString());
        },
        placeholder: "Chore points threshold",
      );
    // return Text("Hello");
    default:
      return SizedBox.shrink();
  }
}

Widget handleUpdateChoreMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson}) {
  switch (missingParameter) {
    case "ChoreTitle":
      return MissingTextInput(
        onTextInput: (String userInput) {
          updateCallback("ChoreTitle", userInput);
        },
        placeHolder: "Name of the chore to update",
      );
    case "ChoreDate":
      return MissingDateInput(
        onDateSelect: (DateTime userInput) {
          updateCallback("ChoreDate", userInput.toString());
        },
        placeHolder: "Search by date (optional)",
      );
    case "ChorePerson":
      return MissingUserInput(
        onUserSelect: (String userInput) {
          updateCallback("ChorePerson", userInput);
        },
        placeholder: "Who was this chore assigned to? (optional)",
      );
    case "ChoreDescription":
      return MissingTextInput(
        onTextInput: (String userInput) {
          updateCallback("ChoreTitle", userInput);
        },
        placeHolder: "Description of the chore to be updated (optional)",
        isInputSingleLine: false,
      );
    default:
      return SizedBox.shrink();
  }
}

Widget handleRemoveChoreMissingParams(
    String missingParameter, Function(String, String) updateCallback,
    {String? searchPerson}) {
  switch (missingParameter) {
    case "ChoreTitle":
      return MissingTextInput(
        onTextInput: (String userInput) {
          updateCallback("ChoreTitle", userInput);
        },
        placeHolder: "Name of the chore to remove",
      );
    case "ChorePerson":
      return MissingUserInput(
        onUserSelect: (String userInput) {
          updateCallback("ChorePerson", userInput);
        },
        placeholder: "Who was this chore assigned to? (optional)",
      );
    case "ChoreDescription":
      return MissingTextInput(
        onTextInput: (String userInput) {
          updateCallback("ChoreDescription", userInput);
        },
        placeHolder: "Description of the chore to remove (optional)",
        isInputSingleLine: false,
      );
    case "ChoreDate":
      return MissingDateInput(
        onDateSelect: (DateTime userInput) {
          updateCallback("ChoreDate", userInput.toString());
        },
        placeHolder: "Search by date (optional)",
      );
    default:
      return SizedBox.shrink();
  }
}
