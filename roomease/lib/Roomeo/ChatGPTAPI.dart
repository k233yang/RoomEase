import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secret.dart' show OpenAIApiKey;
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/Message.dart';
import 'package:roomease/Roomeo/ChatScreen.dart';

const apiURL = "https://api.openai.com/v1/chat/completions";
// https://platform.openai.com/docs/api-reference/chat/create

/*gets chatGPT's response based on provided context*/
Future<String> getChatGPTResponse(String message, List<Message> context) async {
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

  List<Map<String, String>> contextMessages = [];
  for (var i = 0; i < context.length; i++) {
    print(context[i].text);
    contextMessages.add({
      "role": context[i].senderName == "chatgpt" ? "system" : "user",
      "content": context[i].text
    });
  }
  requestDataMessage.addAll(contextMessages);
  requestDataMessage.add({"role": "user", "content": message});

  print(context.length);

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
