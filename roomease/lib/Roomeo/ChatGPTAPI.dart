import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secret.dart' show apiKey;

const apiURL = "https://api.openai.com/v1/chat/completions";
// https://platform.openai.com/docs/api-reference/chat/create

Future<String> getChatGPTResoponse(String message) async {
  final Map<String, String> requestHeaders = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey"
  };

  final Map<String, dynamic> requestData = {
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant"},
      {"role": "user", "content": "Hello!"} //TODO: use actual user messages
      //TODO: keep track of the current conversation. Assistant role represents chatGPT
    ]
  };

  final res = await http.post(Uri.parse(apiURL),
      headers: requestHeaders, body: jsonEncode(requestData));

  if (res.statusCode == 200) {
    final decodedRes = jsonDecode(res.body);
    final int lastResponseIndex = decodedRes["choices"].length;
    final chatGPTRes =
        decodedRes["choices"][lastResponseIndex]["message"]["content"];
    return chatGPTRes;
  } else {
    throw Exception(
        "getChatGPTResponse failed. HTTP status: ${res.statusCode}");
  }
}
