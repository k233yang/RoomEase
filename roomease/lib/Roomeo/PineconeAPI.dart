import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secret.dart' show PineConeAPIKey;
import 'package:pinecone/pinecone.dart';

const environment = 'gcp-starter';
final client = PineconeClient(apiKey: PineConeAPIKey);

// create a new index for a room, with name = roomID
Future<void> createRoomIndex(String roomID,
    {int dimension = 1536 /*default for ada-2*/}) async {
  var url = Uri.parse('https://api.pinecone.io/indexes');
  var res = await http.post(url,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Api-Key': PineConeAPIKey
      },
      body: jsonEncode(<String, dynamic>{
        'name': roomID
            .toLowerCase(), // vector indices only support lowercase alphanumeric
        'dimension': dimension,
        'metric': 'cosine',
        'spec': {
          'serverless': {'cloud': 'aws', 'region': 'us-west-2'}
        }
      }));
  if (res.statusCode == 201) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    print('Response body: ${res.body}');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception(
        'Failed to make create index request. Status code: ${res.statusCode}');
  }
}

// add a message's vector to a given room's index. Note: message's firebase ID is needed
Future<void> insertVector(List<double> vector, String roomID, String vectorID,
    {Map<String, dynamic> metadata = const {}}) async {
  // get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${roomID.toLowerCase()}');
  var fetchIndexRes = await http.get(fetchIndexUrl, headers: <String, String>{
    'Accept': 'application/json',
    'Api-Key': PineConeAPIKey
  });

  if (fetchIndexRes.statusCode == 200) {
    final decodedFetchIndexRes = jsonDecode(fetchIndexRes.body);
    final String indexEndpoint = decodedFetchIndexRes['host'];
    var insertVectorUrl = Uri.parse('https://${indexEndpoint}/vectors/upsert');

    Map<String, dynamic> requestBody = {
      'vectors': [
        {'id': vectorID, 'values': vector}
      ]
    };
    if (metadata.isNotEmpty) {
      requestBody['vectors'][0]['metadata'] = metadata;
    }

    var insertVectorRes = await http.post(
      insertVectorUrl,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Api-Key': PineConeAPIKey
      },
      body: jsonEncode(requestBody),
    );
    if (insertVectorRes.statusCode != 200) {
      throw Exception(
          'Failed to insert vector into index: ${insertVectorRes.statusCode}');
    }
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}

// fetch the most relevant messages given an input vector. Returns the identifiers for each message
Future<List<String>> fetchTopMessages(List<double> vector, String roomID,
    {int messagesToFetch = 10}) async {
  // get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${roomID.toLowerCase()}');
  var fetchIndexRes = await http.get(fetchIndexUrl, headers: <String, String>{
    'Accept': 'application/json',
    'Api-Key': PineConeAPIKey
  });

  if (fetchIndexRes.statusCode == 200) {
    final decodedFetchIndexRes = jsonDecode(fetchIndexRes.body);
    final String indexEndpoint = decodedFetchIndexRes['host'];
    var queryVectorUrl = Uri.parse('https://$indexEndpoint/query');
    var queryVectorRes = await http.post(queryVectorUrl,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Api-Key': PineConeAPIKey
        },
        body: jsonEncode(
          <String, dynamic>{'topK': messagesToFetch, 'vector': vector},
        ));
    if (queryVectorRes.statusCode == 200) {
      var decodedQueryVectorRes = jsonDecode(queryVectorRes.body);
      List<dynamic> queryVectorResArray = decodedQueryVectorRes['matches'];
      List<String> res = [];
      for (int i = 0; i < queryVectorResArray.length; i++) {
        res.add(queryVectorResArray[i]['id']);
        res.sort();
      }
      print("RES: $res");
      return res;
    } else {
      throw Exception(
          'Failed to insert vector into index: ${queryVectorRes.statusCode}');
    }
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}
