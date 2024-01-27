import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'Roomeo/ChatScreen.dart';
import 'Message.dart';
import 'MessageRoom.dart';
import 'User.dart';
import 'chores/ChoreEnums.dart';

class DatabaseManager {
  static FirebaseDatabase _databaseInstance = FirebaseDatabase.instance;

  // ------------------------ USER OPERATIONS ------------------------

  static void addUser(User user) {
    DatabaseReference usersRef = _databaseInstance.ref("users/${user.userId}");
    usersRef.update({"name": user.name});
  }

  // Used when logging in so we can keep track of which household the user belongs to.
  // Otherwise if we login with same user, we can't find the household unless we
  // iterate through all households to find the one the user is a part of
  static void addHouseholdToUser(String userId, String householdId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId");
    usersRef.update({"householdId": householdId});
  }

  static Future<String?> getUsersHousehold(String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/householdId");
    DatabaseEvent event = await usersRef.once();
    return event.snapshot.value as String;
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

  static Future<List<String>?> getUserMessageRoomIds(String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/messageRoomIds");
    DatabaseEvent event = await usersRef.once();
    return event.snapshot.value as List<String>?;
  }

  static void addMessageRoomIdToUser(
      String userId, String messageRoomId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/messageRoomIds");
    TransactionResult result =
        await usersRef.runTransaction((Object? messageRoomIds) {
      if (messageRoomIds == null) {
        // No messageRoomIds, make new list
        List<String> newMessageRoomIds = [messageRoomId];
        CurrentUser.setCurrentMessageRoomIds(newMessageRoomIds);
        return Transaction.success(newMessageRoomIds);
      }

      List<String> _messageRoomIds = List<String>.from(messageRoomIds as List);
      _messageRoomIds.add(messageRoomId);
      CurrentUser.setCurrentMessageRoomIds(_messageRoomIds);
      // Return the new data.
      return Transaction.success(_messageRoomIds);
    });
  }

  // ------------------------ END USER OPERATIONS ------------------------

  // ------------------------ MESSAGE OPERATIONS ------------------------

  static void addMessageRoom(MessageRoom messageRoom) {
    List<String> userIds = [];
    for (User u in messageRoom.users) {
      userIds.add(u.userId);
    }
    DatabaseReference messageRoomsRef =
        _databaseInstance.ref("messageRooms/${messageRoom.messageRoomId}");
    messageRoomsRef.update({"users": userIds, "messages": <String>[]});
  }

  static Future<String> addMessage(
      String messageRoomId, Message message) async {
    DatabaseReference messagesRef =
        _databaseInstance.ref("messageRooms/$messageRoomId/messages");

    final newKey = messagesRef.push().key;
    if (newKey == null) {
      throw Exception('New key is null');
    }
    DatabaseReference messageRef =
        _databaseInstance.ref("messageRooms/$messageRoomId/messages/$newKey");
    messageRef.update({
      'senderName': message.senderName,
      'senderId': message.senderId,
      'timestamp': message.timestamp.toString(),
      'text': message.text
    });

    return newKey;
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

              messageList.add(Message(
                  text!, senderId!, senderName!, DateTime.parse(timestamp!)));
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

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String getRandomString(int length, Random _rnd) {
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static Future<List<Map<String, String>>> getMessages(
      String messageRoomID) async {
    DatabaseReference messageRef =
        _databaseInstance.ref("messageRooms/$messageRoomID/messages");
    List<Map<String, String>> messages = [];
    List<dynamic> content = [];
    DatabaseEvent event = await messageRef.once(DatabaseEventType.value);
    Object? valuesObj = event.snapshot.value;
    if (valuesObj != null) {
      Map<dynamic, dynamic> messageData = valuesObj as Map<dynamic, dynamic>;
      messageData.forEach((key, value) {
        content.add(value);
      });
      content.sort((a, b) {
        DateTime timeStampA = DateTime.parse(a['timestamp']);
        DateTime timeStampB = DateTime.parse(b['timestamp']);
        return timeStampA.compareTo(timeStampB);
      });
      //print(content);
      for (int i = 0; i < content.length; i++) {
        if (content[i]['senderName'] == 'chatgpt') {
          messages.add({"role": "assistant", "content": content[i]['text']});
        } else {
          messages.add({"role": "user", "content": content[i]['text']});
        }
      }
      // print("messages are:");
      // print(messages);
      return messages;
    } else {
      return [];
    }
  }

  static Future<Message> getMessageFromID(
      String messageRoomID, String messageID) async {
    DatabaseReference messageRef = _databaseInstance
        .ref()
        .child("messageRooms/$messageRoomID/messages/$messageID");
    DatabaseEvent event = await messageRef.once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);
      if (data.containsKey('text') && data.containsKey('senderName')) {
        return Message(data['text'], data['senderId'], data['senderName'],
            DateTime.parse(data['timestamp']));
      } else {
        return Future.error('no text field in queried message');
      }
    } else {
      return Future.error('Snapshot value is null');
    }
  }

  // ------------------------ END MESSAGE OPERATIONS ------------------------

  // ------------------------ HOUSEHOLD OPERATIONS ------------------------

  static Future<void> addHousehold(User user, String name) async {
    Random _rnd = Random();
    String householdCode = DatabaseManager.getRandomString(6, _rnd);

    bool householdExists = await checkHouseholdExists(householdCode);

    while (householdExists) {
      _rnd = Random();
      householdCode = DatabaseManager.getRandomString(6, _rnd);
      householdExists = await checkHouseholdExists(householdCode);
    }

    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdCode");
    householdRef.set({
      "users": <String>[user.userId],
      "name": name
    });
    CurrentHousehold.setCurrentHouseholdId(householdCode);
  }

  static void joinHousehold(User user, String householdCode) async {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdCode/users");

    TransactionResult result =
        await householdRef.runTransaction((Object? users) {
      if (users == null) {
        // No household
        return Transaction.success(users);
      }

      List<String> _users = List<String>.from(users as List);
      _users.add(user.userId);
      // Return the new data.
      return Transaction.success(_users);
    });
  }

  static Future<bool> checkHouseholdExists(String householdCode) async {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdCode");
    DatabaseEvent event = await householdRef.once();
    if (event.snapshot.value == null) {
      return false;
    } else {
      return true;
    }
  }

  static void updateHouseholdName(String householdId) {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdId/name");

    householdRef.onValue.listen((DatabaseEvent event) {
      CurrentHousehold.setCurrentHouseholdName(event.snapshot.value as String);
    });
  }

  // ------------------------ END HOUSEHOLD OPERATIONS ------------------------

  // ------------------------ CHORE OPERATIONS ------------------------

  static void addChore(String householdCode, String name, String details, String deadline, int score,
      String createdByUserId) async {
    DatabaseReference choresRef = _databaseInstance.ref("households/$householdCode/choresToDo");

    final choreKey = choresRef.push().key;
    if (choreKey == null) {
      throw Exception('Chore key is null');
    }

    DatabaseReference choreRef = _databaseInstance.ref("households/$householdCode/choresToDo/$choreKey");

    choreRef.set({
      "name": name,
      "details": details,
      "deadline": deadline,
      "score": score,
      "createdByUserId": createdByUserId,
      "assignedUserId": null,
      "status": "toDo"
    }).then((value) {
      print("Successfully added chore");
    }).catchError((value) {
      print(value);
      throw Exception('Could not add chore');
    });
  }
  static Future<String?> getChoreList(ChoreEnums status, String householdCode) async {
    String choreList = "";
    if (status == ChoreEnums.toDo) {
      choreList = "choresToDo";
    } else if (status == ChoreEnums.inProgress) {
      choreList = "choresInProgress";
    } else if (status == ChoreEnums.completed) {
      choreList = "choresCompleted";
    } else if (status == ChoreEnums.archived) {
      choreList = "choresArchived";
    } else {
      throw Exception("Empty or invalid status requested for chore list.");
    }

    DatabaseReference choresRef = _databaseInstance.ref("households/$householdCode/$choreList");
    DatabaseEvent event = await choresRef.once();
    return event.snapshot.children as String;
  }

  // ------------------------ END CHORE OPERATIONS ------------------------
}
