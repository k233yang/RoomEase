import 'dart:ffi';

import 'package:roomease/CurrentHousehold.dart';
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

/// list of command categories Roomeo can recognize from an input
const List<String> commandCatList = [
  'Remove Chore',
  'Add Chore',
  'Update Chore',
  'Set Status',
  'View Schedule',
  'View Status',
  'Chore Delegation',
  //'Ask for Advice',
  'Send a Message',
];

/// list of commands that require parsing (i.e. requires specific user input)
const List<String> parseableCommands = [
  'Remove Chore',
  'Add Chore',
  'Update Chore',
  'Set Status',
  'Chore Delegation',
  'Send a Message',
  'View Status'
];

/// determine if a command is parseable
bool isParseableCommand(String category) {
  return parseableCommands.contains(category) ? true : false;
}

/// determine if category is a command
bool isCommand(String category) {
  return commandCatList.contains(category) ? true : false;
}

/// Adds user message to the database. Returns the key/ID for that message
Future<String> addUserInput(String message, DateTime dateTime) async {
  String? userMessageKey;
  try {
    userMessageKey = await DatabaseManager.addMessage(
        CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
        Message(message, CurrentUser.getCurrentUserId(),
            CurrentUser.getCurrentUserName(), dateTime));
  } catch (e) {
    throw Future.error('Error adding to Firebase');
  }
  return userMessageKey;
}

/* Gets Roomeo to categorize a message. The categories are:
‘View/Edit Chore’, ‘View/Set Status’, ‘Chore Delegation’,
‘Ask for Advice’, ‘Send a Message’, and ‘Unknown’ */
Future<String> getCommandCategory(String message) async {
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
          "Given the following user input, determine what category this input falls into. The categories are: 'View Schedule', 'Add Chore', 'Remove Chore', 'Update Chore', 'View Status', 'Set Status', 'Ask for Advice', 'Send a Message'. Categorize the message as 'Unknown' if the user input cannot be categorized or if the input is irrelevant to the previous categories. Your response ONLY contains the values of these categories, and NOTHING ELSE. The user input is: '$message'"
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
    //print('CHATGPT RES: $chatGPTRes');
    return chatGPTRes;
  } else {
    throw Exception(
        "getChatGPTResponse failed. HTTP status: ${res.statusCode}");
  }
}

/*Generate the request object to be sent to determine command parameters */
Map<String, dynamic> generateGetCommandParameterRequestObject(
    String category, String message) {
  String parametersToFindAddendum = "";
  String parameterJSONFormat = "";
  switch (category) {
    case 'Remove Chore':
      DateTime now = DateTime.now();
      parameterJSONFormat =
          "1. ChoreTitle \n 2. ChorePerson \n 3. ChoreDescription \n 4. ChoreDate";
      parametersToFindAddendum =
          "1. The title of the chore to remove \n 2. The name of the person assigned to the chore \n 3. The description of the chore to remove \n 4. The date of the chore that is to be removed, in the format 'YYYY-MM-DD HH:MM'. Use today's date (${now.month} ${now.day}, ${now.year} ${now.hour}:${now.minute}) as reference. If the user didn't provide a date, use the value 'Missing'";
      break;
    case 'Add Chore':
      DateTime now = DateTime.now();
      parameterJSONFormat =
          "1. ChoreTitle \n 2. ChoreDate \n 3. ChoreDescription \n 4. ChorePerson \n 5. ChorePoints \n 6. ChorePointsThreshold";
      parametersToFindAddendum =
          "1. The title of the chore \n 2. The date and time the chore is to be completed by, in the format 'YYYY-MM-DD HH:MM'. Use today's date (${now.month} ${now.day}, ${now.year} ${now.hour}:${now.minute}) as reference. If the user didn't provide a date, use the value 'Missing' \n 3. The description of the chore to be added \n 4. The name of the person assigned to the chore \n 5. How many points the chore is worth when completed \n 6. The threshold of points needed to complete the chore";
      break;
    case 'Update Chore':
      DateTime now = DateTime.now();
      parameterJSONFormat =
          "1. ChoreTitle \n 2. ChoreDate \n 3. ChorePerson \n 4. ChoreDescription";
      parametersToFindAddendum =
          "1. The title of the chore to be updated \n 2. The date of the chore to be updated, in the format 'YYYY-MM-DD HH:MM'. Use today's date (${now.month} ${now.day}, ${now.year} ${now.hour}:${now.minute}) as reference. If the user didn't specify a date in their message, use the value 'Missing' for this field \n 3. The person assigned to the chore that is to be updated \n 4. The description of the chore to be updated";
      break;
    case 'Set Status':
      parameterJSONFormat = "1. Status";
      parametersToFindAddendum = "1. The status that the user wants to set to.";
      break;
    case 'View Status':
      parameterJSONFormat = "1. ViewPerson";
      parametersToFindAddendum =
          "1. The person of the status who should be viewed";
      break;
    case 'Send a Message':
      parameterJSONFormat = "1. SendPerson \n 2. Message";
      parametersToFindAddendum =
          "1. The person that the message should be sent to \n 2. The actual message";
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
          "You are a virtual assistant named 'Roomeo' meant to find command parameters given an input for the following type of command: $category. You are to find and list the following parameters: \n $parametersToFindAddendum \n Output the results in a JSON style string, using the keys: \n $parameterJSONFormat \n for each of the parameters, respectively. If you cannot determine the values of all the parameters from the input, use the value 'Missing' for the respective parameter in the JSON output. Output ONLY the JSON style string."
    },
    {"role": "user", "content": message}
  ];
  final Map<String, dynamic> requestData = {
    "model": "gpt-3.5-turbo",
    "messages": requestDataMessage
  };
  return {"requestHeaders": requestHeaders, "requestData": requestData};
/*You are a virtual assistant named "Roomeo" meant to find command parameters given a user input for the following type of command: 'Remove from Schedule'. You are to find and list the following parameters: 
1. The description of the chore to remove
Output the results in a JSON style string, using the keys: 
1. ChoreDescription
for each of the parameters. If you cannot determine the values of all the parameters from the input, use the value 'Missing' for the respective parameter in the JSON output. Give me only the JSON style string.
The input is: "Roomeo, remove gardening from my schedule" */
}
//Future<Map<String, String>> getRemoveScheduleTokens(String message) async {}

Future<Map<String, String>> getCommandParameters(
    String category, String message) async {
  // generate the command parameter parsing request object:
  Map<String, dynamic> commandRequestObject =
      generateGetCommandParameterRequestObject(category, message);
  if (commandRequestObject == {}) {
    // TODO: handle empty object instance
  }
  if (!commandRequestObject.containsKey("requestHeaders")) {
    return Future.error("getCommandParameters failed: invalid requestHeader");
  }
  if (!commandRequestObject.containsKey("requestData")) {
    return Future.error("getCommandParameters failed: invalid requestData");
  }
  final res = await http.post(Uri.parse(apiURL),
      headers: commandRequestObject["requestHeaders"],
      body: jsonEncode(commandRequestObject["requestData"]));
  if (res.statusCode != 200) {
    throw Exception(
        "Failed to get command parameters. HTTP status: ${res.statusCode}");
  }
  final decodedRes = jsonDecode(res.body);
  final int lastResponseIndex = decodedRes["choices"].length - 1;
  String commandParamsAsString =
      decodedRes["choices"][lastResponseIndex]["message"]["content"];
  Map<String, dynamic> tempMap = jsonDecode(commandParamsAsString);

  Map<String, String> commandParameters =
      tempMap.map((key, value) => MapEntry(key, value.toString()));
  commandParameters["category"] = category;
  return commandParameters;
}

String generateFullCommandInput(Map<String, String> parameters) {
  switch (parameters['category']) {
    case 'Remove Chore':
      return 'Remove the chore "${parameters['ChoreTitle']}" assigned by ${parameters['ChorePerson']} from the schedule.';
    case 'Add Chore':
      if (parameters['ChoreDescription'] != 'Missing') {
        return 'Add the chore "${parameters['ChoreTitle']}" with the details "${parameters['ChoreDescription']}" to the schedule. The chore is due on ${parameters['ChoreDate']}, and assigned to ${parameters['ChorePerson']}.';
      }
      return 'Add the chore "${parameters['ChoreTitle']}" to the schedule. The chore is due on ${parameters['ChoreDate']}, and assigned to ${parameters['ChorePerson']}.';
    case 'Update Chore':
      return "";
    case 'Set Status':
      return 'Set my status to ${parameters['Status']}';
    case 'View Status':
      return 'What is ${parameters['ViewPerson']}\'s status right now?';
    case 'Send a Message':
      return 'Send "${parameters['Message']}" to ${parameters['SendPerson']}';
    default:
      return "";
  }
}

/* Fetches Roomeo's response by querying relvant messages in the VDB and adds it to the chatroom as well.*/
Future<void> getRoomeoResponse(String message, String messageKey,
    {bool isChore = false,
    String choreId = "",
    bool shouldQueryHouseholdsInstead = false}) async {
  // fetch the user message's generated vector concurrently with other operations:

  List<double> userResVector = await getVectorEmbeddingArray(message);

  // Query the vDB, then firebase for most relevant convos, and feed that info to chatGPT as context
  List<Message> contextMessageList = [];
  List<String>? messageIDList;
  final fetchTopMessagesFuture = shouldQueryHouseholdsInstead
      ? fetchTopMessages(userResVector,
          CurrentUser.getCurrentUserId() + RoomeoUser.user.userId)
      : fetchTopMessages(
          userResVector, CurrentHousehold.getCurrentHouseholdId());
  try {
    messageIDList = await fetchTopMessagesFuture;
    messageIDList.sort((a, b) => a.compareTo(b));
    var fetchMessagesFutures = messageIDList
        .map((messageID) => DatabaseManager.getMessageFromID(
            CurrentUser.getCurrentUserId() + RoomeoUser.user.userId, messageID))
        .toList();

    var fetchedMessages = await Future.wait(fetchMessagesFutures);
    contextMessageList.addAll(fetchedMessages);
    for (var i = 0; i < fetchedMessages.length; i++) {
      print('message $i: ${fetchedMessages[i].text}');
    }
  } catch (e) {
    print(e);
  }

  if (isChore) {
    await insertVector(
      userResVector,
      CurrentHousehold.getCurrentHouseholdId(),
      messageKey,
      metadata: {'isChore': isChore, 'choreId': choreId},
    );
    await insertVector(
      userResVector,
      CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
      messageKey,
      metadata: {'isChore': isChore, 'choreId': choreId},
    );
  } else {
    print("getting in here");
    print(CurrentUser.getCurrentUserId() + RoomeoUser.user.userId);
    await insertVector(
      userResVector,
      CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
      messageKey,
    );
  }

  // Get chatGPT's response to user's message, add response to firebase as well as get response's message key
  String? chatGPTMessage;
  final chatGPTResponseFuture = getChatGPTResponse(message, contextMessageList);

  try {
    chatGPTMessage = await chatGPTResponseFuture;
    String? chatGPTMessageKey;
    try {
      chatGPTMessageKey = await DatabaseManager.addMessage(
          CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
          Message(chatGPTMessage, RoomeoUser.user.userId, RoomeoUser.user.name,
              DateTime.now())); // add chatGPT message to DB
    } catch (e) {
      print('Failed to add chatGPT message to firebase: $e');
    }

    // Fetch chatGPT message's generated vector and put it into DB
    final chatGPTResVectorFuture = getVectorEmbeddingArray(chatGPTMessage);
    List<double>? chatGPTResVector;
    try {
      chatGPTResVector = await chatGPTResVectorFuture;
      print("GPT VECTOR: $chatGPTResVector");
      if (chatGPTMessageKey != null) {
        await insertVector(
            chatGPTResVector,
            CurrentUser.getCurrentUserId() + RoomeoUser.user.userId,
            chatGPTMessageKey);
      } else {
        throw NullObjectError(
            'Insertion into vector DB failed: null chatGPT response vector or message key!');
      }
    } catch (e) {
      print('Failed to get chatGPT vector for input message: $message.');
      print(': $e');
    }
  } catch (e) {
    print('failed to get chatGPT response: $e');
  }
}

Future<List<String>> queryChores(String choreTitle,
    {DateTime? choreDate,
    String? chorePerson,
    String? choreDescription,
    int choresToFind = 5}) async {
  String queryString = "Find the $choreTitle chore.";
  if (chorePerson != null) {
    queryString += " It is assigned to $chorePerson.";
  }
  if (choreDate != null) {
    queryString += " It is due on ${choreDate.toString()}.";
  }
  if (choreDescription != null) {
    queryString += " It has the description '$choreDescription'.";
  }
  // vectorize the query string
  List<double> queryStringVector = await getVectorEmbeddingArray(queryString);
  // use the query vector to find most similar chores
  List<String> topChores = await searchChoreFromChat(queryStringVector,
      CurrentHousehold.getCurrentHouseholdId().toLowerCase());
  return topChores;
}

String generateUpdateCommandInput(
    Map<String, String> oldParameters, Map<String, String> newParameters) {
  String res =
      "Update the chore ${oldParameters['ChoreTitle']} to the following: ";

  newParameters.forEach((key, value) {
    if (key == "ChoreTitle") {
      res +=
          "\n - Change the name of the chore from ${oldParameters['ChoreTitle']} to ${newParameters['ChoreTitle']}";
    } else if (key == "ChorePerson") {
      res +=
          "\n - The chore is now assigned to ${newParameters['ChorePerson']}";
    } else if (key == "ChoreDescription") {
      res +=
          "\n - Change the description of the chore to ${newParameters['ChoreDescription']}";
    } else if (key == "ChoreDate") {
      res += "\n - The chore is now due on ${newParameters['ChoreDate']}";
    } else if (key == "ChorePoints") {
      res +=
          "\n - Change the chore points from ${oldParameters['ChorePoints']} to ${newParameters['ChorePoints']}";
    } else if (key == "ChorePointsThreshold") {
      res +=
          "\n - Change the chore points threshold from ${oldParameters['ChorePointsThreshold']} to ${newParameters['ChorePointsThreshold']}";
    }
  });
  return res;
}
