import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'Roomeo/ChatScreen.dart';
import 'Message.dart';
import 'MessageRoom.dart';
import 'User.dart';
import 'chores/Chore.dart';
import 'chores/ChoreStatus.dart';
import 'package:roomease/chores/Chore.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:intl/intl.dart';

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

  static void getAndStoreUserName(String userId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    CurrentUser.userNameSubscription.cancel();
    CurrentUser.userNameSubscription =
        usersRef.onValue.listen((DatabaseEvent event) {
      CurrentUser.setCurrentUserName(event.snapshot.value as String);
    });
  }

  static Future<String> getUserName(String userId) async {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    DatabaseEvent event = await usersRef.once();
    return event.snapshot.value as String;
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

  static Future<void> addStatusToUserStatusList(
      String status, String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/userStatusList");

    TransactionResult result =
        await usersRef.runTransaction((Object? userStatusList) {
      if (userStatusList == null) {
        // No status list, make new list
        List<String> newUserStatusList = [status];
        CurrentUser.setCurrentMessageRoomIds(newUserStatusList);
        return Transaction.success(newUserStatusList);
      }

      List<String> _userStatusList = List<String>.from(userStatusList as List);
      _userStatusList.add(status);
      // Return the new data.
      return Transaction.success(_userStatusList);
    });
  }

  static void setUserCurrentStatus(String status, String userId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId");
    usersRef.update({"userStatus": status});
  }

  static Future<String> getUserCurrentStatus(String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/userStatus");
    DatabaseEvent event = await usersRef.once();
    return event.snapshot.value as String;
  }

  static Future<List<String>> getUserStatusList(String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/userStatusList");
    DatabaseEvent event = await usersRef.once();
    List<String> userStatusList = [];
    for (DataSnapshot d in event.snapshot.children) {
      userStatusList.add(d.value as String);
    }

    return userStatusList;
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
    // create a vector DB index for the new message room
    // each index will represent one messageroom
    createRoomIndex(messageRoom.messageRoomId);
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
    DatabaseManager.householdUserIdSubscription(householdCode);
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

  static Future<String> getHouseholdName(String householdId) async {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdId/name");
    DatabaseEvent event = await householdRef.once();
    return event.snapshot.value as String;
  }

  static Future<List<String>> getUserIdsFromHousehold(
      String householdId) async {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdId/users");
    DatabaseEvent event = await householdRef.once();
    List<String> userIds = [];
    for (DataSnapshot d in event.snapshot.children) {
      userIds.add(d.value as String);
    }
    return userIds;
  }

  static void householdUserIdSubscription(String householdId) {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdId/users");
    CurrentHousehold.householdUserIdsSubscription.cancel();
    CurrentHousehold.householdUserIdsSubscription =
        householdRef.onValue.listen((DatabaseEvent event) async {
      List<String> userIds = [];
      for (DataSnapshot d in event.snapshot.children) {
        userIds.add(d.value as String);
      }
      Map<String, List<String>> userNameStatusMap = {};
      for (String id in userIds) {
        String name = await DatabaseManager.getUserName(id);
        String status = await DatabaseManager.getUserCurrentStatus(id);
        userNameStatusMap[id] = [name, status];
      }

      CurrentHousehold.householdStatusMap = userNameStatusMap;
    });
  }

  // ------------------------ END HOUSEHOLD OPERATIONS ------------------------

  // ------------------------ CHORE OPERATIONS ------------------------

  static void addChore(
      String householdCode,
      String name,
      String details,
      String deadline,
      int points,
      int threshold,
      String createdByUserId) async {
    DatabaseReference choresRef =
        _databaseInstance.ref("households/$householdCode/choresToDo");

    final choreKey = choresRef.push().key;
    if (choreKey == null) {
      throw Exception('Chore key is null');
    }

    DatabaseReference choreRef =
        _databaseInstance.ref("households/$householdCode/choresToDo/$choreKey");

    String current_date =
        DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());

    choreRef.set({
      "id": choreKey,
      "name": name,
      "details": details,
      "deadline": deadline,
      "dateCreated": current_date,
      "dateLastIncremented": current_date,
      "points": points,
      "threshold": threshold,
      "timesIncremented": 0,
      "daysSinceLastIncremented": 0,
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

  static Future<List<Chore>> getChoresFromDB(
      ChoreStatus status, String householdId) async {
    final choreListRef =
        _databaseInstance.ref("households/$householdId/${status.value}");
    DatabaseEvent event = await choreListRef.once();
    final choresJson = event.snapshot.children;

    List<Chore> choresList = <Chore>[];

    for (final chore in choresJson) {
      choresList.add(Chore(
          chore.child("id").value.toString(),
          chore.child("name").value.toString(),
          chore.child("details").value.toString(),
          chore.child("deadline").value.toString(),
          chore.child("dateCreated").value.toString(),
          chore.child("dateLastIncremented").value.toString(),
          int.parse(chore.child("points").value.toString()),
          int.parse(chore.child("threshold").value.toString()),
          int.parse(chore.child("timesIncremented").value.toString()),
          int.parse(chore.child("daysSinceLastIncremented").value.toString()),
          chore.child("createdByUserId").value.toString(),
          chore.child("assignedUserId").value.toString(),
          chore.child("status").value.toString()));
    }
    return choresList;
  }

  static Future<void> updateChorePoints(String householdCode) async {
    DatabaseReference choresRef =
        _databaseInstance.ref("households/$householdCode/choresToDo");

    List<Chore> choresToDo = await getChoresFromDB(
        ChoreStatus.toDo, CurrentHousehold.getCurrentHouseholdId());

    String choreId;
    DatabaseReference choreRef;
    int daysSinceLastIncremented = 0;

    for (var chore in choresToDo) {
      choreId = chore.id;
      choreRef = _databaseInstance
          .ref("households/$householdCode/choresToDo/$choreId");
      daysSinceLastIncremented = DateTime.now()
              .difference(DateFormat('yyyy-MM-dd hh:mm:ss a')
                  .parse(chore.dateLastIncremented))
              .inDays +
          chore.daysSinceLastIncremented;
      choreRef.update({
        "daysSinceLastIncremented": daysSinceLastIncremented % chore.threshold
      });

      int pointsIncrease = 0;
      if (daysSinceLastIncremented > chore.threshold) {
        pointsIncrease = (daysSinceLastIncremented / chore.threshold).floor();
        await choreRef.update({
          "points": chore.points + pointsIncrease,
          "dateLastIncremented":
              DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
          "timesIncremented": chore.timesIncremented + pointsIncrease,
        });
      }
    }
  }
  // ------------------------ END CHORE OPERATIONS ------------------------
}
