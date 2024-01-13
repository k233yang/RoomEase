import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secret.dart' show PineConeAPIKey;
import 'package:pinecone/pinecone.dart';

const environment = 'us-central1-gcp-starter';
final client = PineconeClient(apiKey: PineConeAPIKey);

// create a new index for a room, with name = roomID
void createRoomIndex(String roomID,
    {int dimension = 1536 /*default for ada-2*/}) async {
  await client.createIndex(
      environment: environment,
      request: CreateIndexRequest(name: roomID, dimension: dimension));
}

// add a message's vector to a given room's index. Note: message's firebase ID is needed
Future<UpsertResponse> insertVector(
    List<double> vector, String roomID, String vectorID) async {
  // get the index of the room
  final Index index = await client.describeIndex(
    indexName: roomID,
  );
  final indexName = index.name;
  final projectID = index.projectId;

  return await client.upsertVectors(
      indexName: indexName,
      projectId: projectID,
      environment: environment,
      request: UpsertRequest(vectors: [Vector(id: vectorID, values: vector)]));
}

// fetch the most relevant messages given an input vector. Returns the identifiers for each message
Future<List<String>> fetchTopMessages(List<double> vector, String roomID,
    {int messagesToFetch = 10}) async {
  // get the index of the room
  final Index index = await client.describeIndex(
    indexName: roomID,
  );
  final indexName = index.name;
  final projectID = index.projectId;

  QueryResponse queryResponse = await client.queryVectors(
      indexName: indexName,
      projectId: projectID,
      environment: environment,
      request: QueryRequest(vector: vector, topK: messagesToFetch));

  List<VectorMatch> vectorMatches = queryResponse.matches;
  List<String> res = [];

  for (var i = 0; i < vectorMatches.length; i++) {
    res.add(vectorMatches[i].id);
  }

  return res;
}
