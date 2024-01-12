import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secret.dart' show OpenAIApiKey;
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Message.dart';
import 'package:roomease/Roomeo/ChatScreen.dart';

const apiURL = "https://api.openai.com/v1/chat/completions";
// https://platform.openai.com/docs/api-reference/chat/create

Future<String> getChatGPTResponse(String message) async {
  final Map<String, String> requestHeaders = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $OpenAIApiKey"
  };

  List<Map<String, String>> requestDataMessage = [
    {
      "role": "system",
      "content": "You are a helpful assistant named \"Roomeo\""
    }
  ];

  List<Map<String, String>> allMessages =
      await DatabaseManager.getMessages("messageRoomId");

  if (allMessages != []) {
    requestDataMessage.addAll(allMessages);
  }

  requestDataMessage.add({"role": "user", "content": message});

  final Map<String, dynamic> requestData = {
    "model": "gpt-3.5-turbo",
    "messages": requestDataMessage
    // "messages": [
    //   {"role": "system", "content": "You are a helpful assistant"},
    //   {"role": "user", "content": message} //TODO: use actual user messages
    //   //TODO: keep track of the current conversation. Assistant role represents chatGPT
    // ]
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
