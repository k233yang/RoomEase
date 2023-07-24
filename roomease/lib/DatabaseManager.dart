import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'Message.dart';
import 'MessageRoom.dart';
import 'User.dart';

class DatabaseManager {
  static FirebaseDatabase _databaseInstance = FirebaseDatabase.instance;

  static void addUser(User user) {
    DatabaseReference usersRef = _databaseInstance.ref("users/${user.userId}");
    usersRef.set({"name": user.name});
  }

  static void addMessageRoom(MessageRoom messageRoom) {
    List<String> userIds = [];
    for (User u in messageRoom.users) {
      userIds.add(u.userId);
    }
    DatabaseReference messageRoomsRef =
        _databaseInstance.ref("messageRooms/${messageRoom.messageRoomId}");
    messageRoomsRef.set({"users": userIds, "messages": <String>[]});
  }

  static void addMessage(String messageRoomId, Message message) async {
    DatabaseReference messagesRef =
        _databaseInstance.ref("messageRooms/$messageRoomId/messages");
    String messageToAdd = "${message.sender.name}: ${message.text}";

    TransactionResult result =
        await messagesRef.runTransaction((Object? messages) {
      if (messages == null) {
        // No messages yet
        return Transaction.success(<String>[messageToAdd]);
      }

      List<String> _messages = List<String>.from(messages as List);
      _messages.add(messageToAdd);
      // Return the new data.
      return Transaction.success(_messages);
    });
  }

  static String getUserName(String userId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    String name = '';
    usersRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      name = data as String;
    });
    return name;
  }

  static StreamBuilder userNameStreamBuilder(String userId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    return StreamBuilder(
        stream: usersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
                'Hello ${(snapshot.data! as DatabaseEvent).snapshot.value as String}!');
          } else {
            return Text("");
          }
        });
  }
}
