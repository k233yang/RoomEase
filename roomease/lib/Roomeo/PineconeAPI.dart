import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roomease/Roomeo/EmbedVector.dart';
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

/// add a message's vector to a given room's index. Note: message's firebase ID is needed
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
    print('THis is good so far 1');
    final decodedFetchIndexRes = jsonDecode(fetchIndexRes.body);
    final String indexEndpoint = decodedFetchIndexRes['host'];
    print("INDEX ENDPOINT: $indexEndpoint");
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
    print('THis is good so far 2');
    return;
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}

/// fetch the most relevant messages given an input vector. Returns the identifiers for each message
Future<List<String>> fetchTopMessages(List<double> vector, String indexID,
    {int messagesToFetch = 10}) async {
  // get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${indexID.toLowerCase()}');
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
      // print("RES: $res");
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

/// given a pre-made chat string, find IDs the most relevant
/// of the most relevant chores in the household index in the VDB
Future<List<String>> searchChoresFromChat(
    List<double> queryVector, String householdId,
    {int choresToFind = 5}) async {
  // get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${householdId.toLowerCase()}');
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
          <String, dynamic>{
            'topK': choresToFind,
            'vector': queryVector,
            'filter': {
              'isChore': {'\$eq': true}
            },
            'includeMetadata': true
          },
        ));
    if (queryVectorRes.statusCode == 200) {
      var decodedQueryVectorRes = jsonDecode(queryVectorRes.body);
      List<dynamic> queryVectorResArray = decodedQueryVectorRes['matches'];
      List<String> res = [];
      for (int i = 0; i < queryVectorResArray.length; i++) {
        res.add(queryVectorResArray[i]['id']);
        res.sort();
      }
      return res;
    } else {
      throw Exception(
          'Failed to query vector into index: ${queryVectorRes.statusCode}');
    }
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}

/// given the query vector of a user's name, finds the most similar user
/// in the household and gives us their ID
Future<String> searchUserFromChat(
  List<double> queryVector,
  String householdId,
) async {
  // get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${householdId.toLowerCase()}');
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
          <String, dynamic>{
            'topK': 5,
            'vector': queryVector,
            'filter': {
              'isPerson': {'\$eq': true}
            },
          },
        ));
    if (queryVectorRes.statusCode == 200) {
      var decodedQueryVectorRes = jsonDecode(queryVectorRes.body);
      List<dynamic> queryVectorResArray = decodedQueryVectorRes['matches'];
      Map<dynamic, dynamic> vectorWithHighestScore = queryVectorResArray.reduce(
          (currentMax, next) =>
              next['score'] > currentMax['score'] ? next : currentMax);
      print("HERE IS THE HIGHEST SCORE'S ID: ${vectorWithHighestScore['id']}");
      return vectorWithHighestScore['id'];
    } else {
      throw Exception(
          'Failed to query vector into index: ${queryVectorRes.statusCode}');
    }
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}

/// replace a vector in the DB with another vector, and any updated metadata
Future<void> updateVector(
  List<double> vector,
  String indexID,
  String vectorID, {
  Map<String, dynamic> metadata = const {},
}) async {
  // get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${indexID.toLowerCase()}');
  var fetchIndexRes = await http.get(fetchIndexUrl, headers: <String, String>{
    'Accept': 'application/json',
    'Api-Key': PineConeAPIKey
  });

  if (fetchIndexRes.statusCode == 200) {
    final decodedFetchIndexRes = jsonDecode(fetchIndexRes.body);
    final String indexEndpoint = decodedFetchIndexRes['host'];
    //print("INDEX ENDPOINT: $indexEndpoint");
    var insertVectorUrl = Uri.parse('https://${indexEndpoint}/vectors/update');

    Map<String, dynamic> requestBody = {
      'id': vectorID,
      'values': vector,
    };
    if (metadata.isNotEmpty) {
      requestBody['setMetadata'] = metadata;
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
    return;
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}

/// delete a vector in the DB
Future<void> deleteVector(String indexID, String vectorID) async {
// get the index of the room
  var fetchIndexUrl =
      Uri.parse('https://api.pinecone.io/indexes/${indexID.toLowerCase()}');
  var fetchIndexRes = await http.get(fetchIndexUrl, headers: <String, String>{
    'Accept': 'application/json',
    'Api-Key': PineConeAPIKey
  });

  if (fetchIndexRes.statusCode == 200) {
    final decodedFetchIndexRes = jsonDecode(fetchIndexRes.body);
    final String indexEndpoint = decodedFetchIndexRes['host'];
    //print("INDEX ENDPOINT: $indexEndpoint");
    var insertVectorUrl = Uri.parse('https://$indexEndpoint/vectors/delete');

    Map<String, dynamic> requestBody = {
      'ids': [vectorID]
    };

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
    return;
  } else {
    throw Exception(
        'Failed to fetch index info. Status code: ${fetchIndexRes.statusCode}');
  }
}
