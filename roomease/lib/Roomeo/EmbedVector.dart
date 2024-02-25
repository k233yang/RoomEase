import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secret.dart' show OpenAIApiKey;

const embeddingAPIURL = "https://api.openai.com/v1/embeddings";

// generate the vector embedding of an input using OpenAI ada 2
Future<List<double>> getVectorEmbeddingArray(String input) async {
  final Map<String, String> vectorRequestHeaders = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $OpenAIApiKey"
  };

  final Map<String, String> vectorRequestData = {
    "input": input,
    "model": "text-embedding-3-small"
  };

  try {
    final res = await http.post(Uri.parse(embeddingAPIURL),
        headers: vectorRequestHeaders, body: jsonEncode(vectorRequestData));
    if (res.statusCode == 200) {
      final decodedRes = jsonDecode(res.body);
      final vectorEmbedding = decodedRes["data"][0]["embedding"];
      return List<double>.from(vectorEmbedding);
    } else {
      throw Exception(
          "getVectorEmbeddingArray failed. HTTP status: ${res.statusCode}");
    }
  } catch (e) {
    print('Request failed with error: $e');
    return Future.error('get vector embedding failed');
  }
}
