import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import '../Message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secret.dart' show OpenAIApiKey;
import 'package:roomease/Roomeo/ChatGPTAPI.dart';
import 'package:roomease/Roomeo/EmbedVector.dart';
import '../Errors.dart';

/* Adds a message to the chatroom, as well as fetches Roomeo's response
by querying relvant messages in the VDB and adds it to the chatroom as well.*/
Future<void> getRoomeoResponse(String message, DateTime dateTime) async {
  String? userMessageKey;
  try {
    userMessageKey = await DatabaseManager.addMessage(
        CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
        Message(message, CurrentUser.getCurrentUserId(),
            CurrentUser.getCurrentUserName(), dateTime));
  } catch (e) {
    print('Failed to add user message: $e');
  }

  // fetch the user message's generated vector:
  List<double>? userResVector;
  try {
    userResVector = await getVectorEmbeddingArray(message);
    print(userResVector);
  } catch (e) {
    print('Failed to get user vector for input message: $message.');
    print(': $e');
  }
  //Query the vDB, then firebase for most relevant convos, and feed that info to chatGPT as context
  List<Message> contextMessageList = [];
  try {
    if (userResVector != null) {
      List<String> messageIDList = await fetchTopMessages(
          userResVector,
          CurrentUser.getCurrentUserId() +
              RoomeoUser
                  .user.userId); // contains the firebase ID's for the messages
      messageIDList.sort((a, b) => a.compareTo(b));
      for (var i = 0; i < messageIDList.length; i++) {
        Message res = await DatabaseManager.getMessageFromID(
            CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
            messageIDList[i]);
        contextMessageList.add(res);
        print('message $i: ${res.text}');
      }
    } else {
      throw NullObjectError(
          'Querying vector DB failed: null user response vector!');
    }
  } catch (e) {
    print(e);
  }
  print('Fetched firebase stuff');
  // put user message vector to vector DB
  try {
    if (userResVector != null && userMessageKey != null) {
      await insertVector(
          userResVector,
          CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
          userMessageKey);
    } else {
      if (userResVector == null) {
        throw NullObjectError(
            'Insertion into vector DB failed: null user response vector!');
      }
      if (userMessageKey == null) {
        throw NullObjectError(
            'Insertion into vector DB failed: null user message key!');
      }
    }
  } catch (e) {
    print(e);
  }
  // get chatGPT's response to user's message, add response to firebase as well as get response's message key
  String? chatGPTMessageKey;
  String? chatGPTMessage;
  try {
    chatGPTMessage = await getChatGPTResponse(message, contextMessageList);
    try {
      chatGPTMessageKey = await DatabaseManager.addMessage(
          CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
          Message(chatGPTMessage, RoomeoUser.user.userId, RoomeoUser.user.name,
              DateTime.now())); // add chatGPT message to DB
    } catch (e) {
      print('Failed to add chatGPT message to firebase: $e');
    }
  } catch (e) {
    print('failed to get chatGPT response: $e');
  }
  // fetch chatGPT message's generated vector
  List<double>? chatGPTResVector;
  try {
    if (chatGPTMessage != null) {
      chatGPTResVector = await getVectorEmbeddingArray(chatGPTMessage);
      print(chatGPTResVector);
    } else {
      throw NullObjectError('Null gptMessage!');
    }
  } catch (e) {
    print('Failed to get chatGPT vector for input message: $message.');
    print(': $e');
  }
  // put chatGPT vector into DB:
  try {
    if (chatGPTResVector != null && chatGPTMessageKey != null) {
      await insertVector(
          chatGPTResVector,
          CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
          chatGPTMessageKey);
    } else {
      if (userResVector == null) {
        throw NullObjectError(
            'Insertion into vector DB failed: null chatGPT response vector!');
      }
      if (userMessageKey == null) {
        throw NullObjectError(
            'Insertion into vector DB failed: null chatGPT message key!');
      }
    }
  } catch (e) {
    print(e);
  }
}

/* Gets Roomeo to categorize a message. The categories are:
‘View/Edit Schedule’, ‘View/Set Status’, ‘Chore Delegation’,
‘Ask for Advice’, ‘Send a Message’, and ‘Unknown’ */
Future<String> selectOption(String message) async {
  final Map<String, String> requestHeaders = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $OpenAIApiKey"
  };

  List<Map<String, String>> requestDataMessage = [
    {
      "role": "system",
      "content": "You are a helpful assistant that categorizes messages."
    },
    {
      "role": "user",
      "content":
          "Given the following user input, determine what category this input falls into. The categories are: 'View Schedule', 'Add to Schedule, 'Remove from Schedule', 'Update Schedule', 'View Status', 'Set Status', 'Chore Delegation', 'Ask for Advice', 'Send a Message'. Categorize the message as 'Unknown' if the user input cannot be categorized or if the input is irrelevant to the previous categories. The user input is: '$message'"
    }
  ];

  final Map<String, dynamic> requestData = {
    "model": "gpt-3.5-turbo",
    "messages": requestDataMessage
  };

  final res = await http.post(Uri.parse(apiURL),
      headers: requestHeaders, body: jsonEncode(requestData));

  if (res.statusCode == 200) {
    final decodedRes = jsonDecode(res.body);
    final int lastResponseIndex = decodedRes["choices"].length - 1;
    final chatGPTRes =
        decodedRes["choices"][lastResponseIndex]["message"]["content"];
    return chatGPTRes;
  } else {
    throw Exception(
        "getChatGPTResponse failed. HTTP status: ${res.statusCode}");
  }
}

Map<String, dynamic> generateGetCommandParameterRequestObject(
    String category, String message) {
  String parametersToFindAddendum = "";
  String parameterJSONFormat = "";
  switch (category) {
    case 'Remove from Schedule':
      parameterJSONFormat = "TaskDescription";
      parametersToFindAddendum = "1. The description of the task to remove";
      break;
    case 'Add to Schedule':
      DateTime now = DateTime.now();
      parametersToFindAddendum =
          "1. The description of the task to be added \n 2. The date and time the task is to be completed by, in the format 'YYYY-MM-DD HH:MM'. Use today's date (${now.month} ${now.day}, ${now.year} ${now.hour}:${now.minute}) to help determine this";
      break;
    case 'Update Schedule':
      DateTime now = DateTime.now();
      parametersToFindAddendum =
          "1. The description of the old task to be updated \n 2. The description of the new task that will replace the old task \n 3. The new date of the updated task, in the format 'YYYY-MM-DD HH:MM'. Use today's date (${now.month} ${now.day}, ${now.year} ${now.hour}:${now.minute}) to help determine this. If the date is not specified, the value of this parameter will be 'None'";
      break;
    case 'Set Status':
      parametersToFindAddendum =
          "1. The status that the user wants to set to. The valid statuses are: Online, Away, Offline";
      break;
    default:
      return {};
  }
  final Map<String, String> requestHeaders = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $OpenAIApiKey"
  };
  List<Map<String, String>> requestDataMessage = [
    {
      "role": "system",
      "content":
          "You are a virtual assistant meant to find command parameters given a user input for the following type of command: $category. You are to find and list the following parameters: \n $parametersToFindAddendum \n Output the results in a JSON style string, using the keys: \n $parameterJSONFormat \n If you cannot determine the values of all the parameters from the input, use the value 'Missing' for the respective parameter in the output."
    },
    {"role": "user", "content": message}
  ];
  return {};
  /*You are a virtual assistant named "Roomeo" meant to find command parameters given a user input for the following type of command: 'Remove from Schedule'. You are to find and list the following parameters: 
1. The description of the task to remove
Output the results in a JSON style string, using the keys: 
1. TaskDescription
for each of the parameters. If you cannot determine the values of all the parameters from the input, use the value 'Missing' for the respective parameter in the JSON output. Give me only the JSON style string.
The input is: "Roomeo, remove gardening from my schedule" */
}

void viewSchedule() {}

void removeTaskFromSchedule(/*scheduleID, taskIDToRemove*/) {}

void addTaskToSchedule(/*scheduleID, taskToAdd*/) {}

void updateSchedule(/*scheduleID, taskToUpdate, newTask*/) {}

void sendMessage(/*userID, message*/) {}

//Future<Map<String, String>> getRemoveScheduleTokens(String message) async {}

void determineCommand(String category, String message) {
  // determine relevant tokens: e.g. if a user wants to add a task to a schedule,
  // determine what strings are needed to build a task object from the message
  // for:
  // REMOVING A TASK FROM A SCHEDULE:

  //  1. need to determine the ID of what task to remove (hard part)
  //      (might need to query a vector DB to properly do this) one potential solution
  //      is to query the top X most relevant task ID's, and have a user select
  //      which task to remove
  //  2. remove it from firebase, as well as the vector DB
  // ADDING A TASK TO A SCHEDULE:
  //  1. generate a task ID
  //  2. vectorize the task and put it into the VDB
  // UPDATING THE SCHEDULE:
  //  1. determine what task needs updating
  //      use an approach similar to determining task ID for removal
  //  2. vectorize the task. modify the vector data for that task in the vdb
  //  3. modify the task in firebase
}
