import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/missinginputs/MissingDateInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingStatusInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingUserInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingTextInput.dart';
import 'package:roomease/Roomeo/missinginputs/MissingPointInput.dart';
import '../../colors/ColorConstants.dart';

// Search person is used to find another household member, if the user
// specified one in their message
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
        onDateSelect: (String userInput) {
          updateCallback("ChoreDate", userInput);
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
    // case "ChoreDate":
    //   return MissingDateInput(
    //     onDateSelect: (String userInput) {
    //       updateCallback("ChoreDate", userInput);
    //     },
    //     placeHolder: "Search by date (optional)",
    //   );
    // case "ChorePerson":
    //   if (searchPerson == null) {
    //     return MissingUserInput(
    //       onUserSelect: (String userInput) {
    //         updateCallback("ChorePerson", userInput);
    //       },
    //       placeholder: "Who is responsible for the chore?",
    //     );
    //   } else {
    //     print("Got in here. SearchPerson is: $searchPerson");
    //     return MissingUserInput(
    //       onUserSelect: (String userInput) {
    //         updateCallback("ChorePerson", userInput);
    //       },
    //       placeholder: "Who is responsible for the chore?",
    //       searchPerson: searchPerson,
    //     );
    //   }
    // case "ChoreDescription":
    //   return MissingTextInput(
    //     onTextInput: (String userInput) {
    //       updateCallback("ChoreTitle", userInput);
    //     },
    //     placeHolder: "Description of the chore to be updated (optional)",
    //     isInputSingleLine: false,
    //   );
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
        onDateSelect: (String userInput) {
          updateCallback("ChoreDate", userInput);
        },
        placeHolder: "Search by date (optional)",
      );
    default:
      return SizedBox.shrink();
  }
}
