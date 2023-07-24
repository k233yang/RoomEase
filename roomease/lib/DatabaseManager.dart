import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:roomease/CurrentUser.dart';
import 'Roomeo/ChatScreen.dart';
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

    final newKey = messagesRef.push().key;
    DatabaseReference messageRef =
        _databaseInstance.ref("messageRooms/$messageRoomId/messages/$newKey");
    messageRef.set({
      'senderName': message.sender.name,
      'senderId': message.sender.userId,
      'timestamp': message.timestamp.toString(),
      'text': message.text
    });
    // TransactionResult result =
    //     await messagesRef.runTransaction((Object? messages) {
    //   if (messages == null) {
    //     // No messages yet
    //     return Transaction.success(<String>[messageToAdd]);
    //   }

    //   List<String> _messages = List<String>.from(messages as List);
    //   _messages.add(messageToAdd);
    //   // Return the new data.
    //   return Transaction.success(_messages);
    // });
  }

  static StreamBuilder messagesStreamBuilder(String messageRoomId) {
    DatabaseReference messagesRef =
        _databaseInstance.ref("messageRooms/$messageRoomId/messages");
    return StreamBuilder(
        stream: messagesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Message> messageList = [];
            var snapshotValue =
                (snapshot.data! as DatabaseEvent).snapshot.value;
            if (snapshotValue == null) {
              return buildListMessage(<Message>[]);
            }
            Map<dynamic, dynamic> messages =
                snapshotValue as Map<dynamic, dynamic>;
            for (MapEntry<dynamic, dynamic> e in messages.entries) {
              Map<dynamic, dynamic> messageJson = e.value;
              String? text = "";
              String? senderName = "";
              String? senderId = "";
              String? timestamp = "";
              if (messageJson['text'] != null) {
                text = messageJson['text'];
              }
              if (messageJson['senderName'] != null) {
                senderName = messageJson['senderName'];
              }
              if (messageJson['senderId'] != null) {
                senderId = messageJson['senderId'];
              }
              if (messageJson['timestamp'] != null) {
                timestamp = messageJson['timestamp'];
              }

              messageList.add(Message(text!, User(senderName!, senderId!),
                  DateTime.parse(timestamp!)));
            }

            messageList.sort((a, b) {
              return a.timestamp
                  .toString()
                  .toLowerCase()
                  .compareTo(b.timestamp.toString().toLowerCase());
            });
            return buildListMessage(messageList);
          } else {
            return buildListMessage(<Message>[]);
          }
        });
  }

  static void getUserName(String userId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    CurrentUser.userNameSubscription.cancel();
    CurrentUser.userNameSubscription =
        usersRef.onValue.listen((DatabaseEvent event) {
      CurrentUser.setCurrentUserName(event.snapshot.value as String);
    });
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
