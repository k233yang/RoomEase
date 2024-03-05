import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/Roomeo/Roomeo.dart';
import 'package:roomease/HomeScreen.dart';
import 'Roomeo/ChatScreen.dart';
import 'Message.dart';
import 'MessageRoom.dart';
import 'User.dart';
import 'calendar/Event.dart';
import 'chores/Chore.dart';
import 'chores/ChoreStatus.dart';
import 'package:roomease/chores/Chore.dart';
import 'package:roomease/Roomeo/PineconeAPI.dart';
import 'package:intl/intl.dart';

class DatabaseManager {
  static FirebaseDatabase _databaseInstance = FirebaseDatabase.instance;

  // ------------------------ USER OPERATIONS ------------------------

  static void addUser(String userId, String userName) {
    DatabaseReference usersRef = _databaseInstance.ref("users/${userId}");
    usersRef.update({"name": userName});
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

  static Future<String> getUserName(String? userId) async {
    if (userId == null) {
      throw Exception("Cannot retrieve user name, user id is null");
    }
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    DatabaseEvent event = await usersRef.once();
    if (event.snapshot.value == null) {
      return "";
    } else {
      return event.snapshot.value as String;
    }
  }

  static Future<String?> getUserIdByName(String userName) async {
    DatabaseReference usersRef = _databaseInstance.ref("users");
    DatabaseEvent event = await usersRef.once();
    for (DataSnapshot user in event.snapshot.children) {
      if (user.child("name").value == userName) {
        return user.key;
      }
    }
    return null; // Return null if userName not found
  }

  static StreamBuilder userNameStreamBuilder(String userId) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId/name");
    return StreamBuilder(
        stream: usersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
                style: TextStyle(fontSize: 20),
                'Hello ${(snapshot.data! as DatabaseEvent).snapshot.value as String}!');
          } else {
            return Text("");
          }
        });
  }

  static Future<List<String>> getUserMessageRoomIds(String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/messageRoomIds");
    DatabaseEvent event = await usersRef.once();
    List<String> messageRoomIds = [];
    for (DataSnapshot d in event.snapshot.children) {
      messageRoomIds.add(d.value as String);
    }
    return messageRoomIds;
  }

  static Future<void> addMessageRoomIdToUser(
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

  static Future<void> removeStatusFromUserStatusList(
      String status, String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/userStatusList");

    TransactionResult result =
        await usersRef.runTransaction((Object? userStatusList) {
      if (userStatusList == null) {
        // No status list, make new list
        List<String> newUserStatusList = [];
        CurrentUser.setCurrentMessageRoomIds(newUserStatusList);
        return Transaction.success(newUserStatusList);
      }

      List<String> _userStatusList = List<String>.from(userStatusList as List);
      _userStatusList.remove(status);
      // Return the new data.
      return Transaction.success(_userStatusList);
    });
  }

  static void setUserCurrentStatus(String status, String userId) async {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId");
    usersRef.update({"userStatus": status});
    DatabaseReference householdRef = _databaseInstance.ref(
        "households/${CurrentHousehold.getCurrentHouseholdId()}/users/$userId");
    await householdRef.update({"status": status});
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

  static void setUserCurrentIconNumber(String userId, int iconNumber) {
    DatabaseReference usersRef = _databaseInstance.ref("users/$userId");
    usersRef.update({"iconNumber": iconNumber});
  }

  static Future<int> getUserCurrentIconNumber(String userId) async {
    DatabaseReference usersRef =
        _databaseInstance.ref("users/$userId/iconNumber");
    if (userId == "RoomeoId") return 100;
    DatabaseEvent event = await usersRef.once();
    if (event.snapshot.value == null) {
      DatabaseReference updateRef = _databaseInstance.ref("users/$userId");
      updateRef.update({"iconNumber": 1});
      return 1;
    }
    return event.snapshot.value as int;
  }

  // ------------------------ END USER OPERATIONS ------------------------

  // ------------------------ MESSAGE OPERATIONS ------------------------

  // Create a message room, with a vector database index
  static void addMessageRoom(MessageRoom messageRoom) async {
    List<String> userIds = [];
    for (User u in messageRoom.users) {
      userIds.add(u.userId);
    }
    DatabaseReference messageRoomsRef =
        _databaseInstance.ref("messageRooms/${messageRoom.messageRoomId}");
    messageRoomsRef.update({"users": userIds, "messages": <String>[]});
    // create a vector DB index for the new message room
    // each index will represent one messageroom
    await createRoomIndex(messageRoom.messageRoomId);
  }

  // Alternative method for adding message room that doesn't require entire User objects
  static Future<void> addMessageRoomWithList(List<String> userIds) async {
    DatabaseReference messageRoomsRef =
        _databaseInstance.ref("messageRooms/${userIds.join()}");
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
  }

  static Future<void> removeMessageFromID(
      String messageRoomID, String messageID) async {
    DatabaseReference messageRef = _databaseInstance
        .ref()
        .child("messageRooms/$messageRoomID/messages/$messageID");
    try {
      await messageRef.remove();
    } catch (e) {
      return Future.error('Failed to remove message: $e');
    }
  }

  static Future<void> replaceMessage(
      String messageRoomID, String messageID, String newMessage) async {
    DatabaseReference messageRef = _databaseInstance
        .ref()
        .child("messageRooms/$messageRoomID/messages/$messageID");
    try {
      await Future.delayed(const Duration(seconds: 2));
      await messageRef.update({'text': newMessage});
    } catch (e) {
      return Future.error('Failed to remove message: $e');
    }
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
              Message msg = Message(
                  text!, senderId!, senderName!, DateTime.parse(timestamp!));

              messageList.add(msg);
            }

            messageList.sort((a, b) {
              return a.timestamp.compareTo(b.timestamp);
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

  static void userMessageRoomSubscription(String currentUserId) async {
    // Excludes current user by default since this is used for displaying
    // all message rooms in the chatListScreen
    DatabaseReference userRef =
        _databaseInstance.ref().child("users/$currentUserId/messageRoomIds");
    List<String> messageRoomIdList = [];
    DatabaseEvent userEvent = await userRef.once();
    for (DataSnapshot d in userEvent.snapshot.children) {
      messageRoomIdList.add(d.value as String);
    }
    Map<String, List<Map<String, String>>> messageRoomMapping = {};
    // Format is messageRoomid: List<Map<userid:username>>
    for (String messageRoomID in messageRoomIdList) {
      DatabaseReference messageRef =
          _databaseInstance.ref().child("messageRooms/$messageRoomID/users");
      DatabaseEvent event = await messageRef.once();
      if (event.snapshot.value != null) {
        // event.snapshot.value is a list of the users in this specific msg room
        //[EZ5ZkiFsVZMySudqICUIhmskgXw1, RoomeoId]
        List<Map<String, String>> userNameIdMapping = [];
        for (DataSnapshot d in event.snapshot.children) {
          String userid = d.value as String;
          if (CurrentUser.getCurrentUserId() != userid) {
            String username = await DatabaseManager.getUserName(userid);
            if (userid == "RoomeoId") username = "Roomeo";
            userNameIdMapping.add({"id": userid, "name": username});
          }
        }
        messageRoomMapping[messageRoomID] = userNameIdMapping;
      }
    }
    CurrentUser.userMessageRoomValueListener.value = messageRoomMapping;
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
    householdRef.update({"name": name});
    DatabaseReference householdUserRef =
        _databaseInstance.ref("households/$householdCode/users/${user.userId}");
    householdUserRef
        .update({"name": user.name, "status": "Home", "totalPoints": 0});
    CurrentHousehold.setCurrentHouseholdId(householdCode);
  }

  static void joinHousehold(User user, String householdCode) async {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdCode/users/${user.userId}");

    householdRef
        .update({"name": user.name, "status": "Home", "totalPoints": 0});
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
      userIds.add(d.key as String);
    }
    return userIds;
  }

  static Future<List<String>> getUserNamesFromHousehold(
      String householdId) async {
    List<String> householdUserIds = await getUserIdsFromHousehold(householdId);
    List<Future<String>> userNameFutures = [];
    for (String userId in householdUserIds) {
      Future<String> userNameFuture = getUserName(userId);
      userNameFutures.add(userNameFuture);
    }
    // make concurrent requests for all user names
    return await Future.wait(userNameFutures);
  }

  static void householdUserIdSubscription(String householdId) {
    DatabaseReference householdRef =
        _databaseInstance.ref("households/$householdId/users");
    CurrentHousehold.householdUserIdsSubscription.cancel();
    CurrentHousehold.householdUserIdsSubscription =
        householdRef.onValue.listen((DatabaseEvent event) async {
      Map<String, Map<String, String>> users = {};
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        for (MapEntry<dynamic, dynamic> e in userMap.entries) {
          String userId = e.key;
          Map<dynamic, dynamic> userInfo = e.value as Map<dynamic, dynamic>;
          String name = userInfo['name'];
          String status = userInfo['status'];
          int totalPoints = userInfo['totalPoints'] ?? 0;
          users[userId] = {
            "name": name,
            "status": status,
            "totalPoints": totalPoints.toString()
          };
        }
      }

      CurrentHousehold.householdStatusValueListener.value = users;
    });
  }

  // ------------------------ END HOUSEHOLD OPERATIONS ------------------------

  // ------------------------ CHORE OPERATIONS ------------------------
  /// adds a chore to firebase, and returns the chore's ID
  static Future<String> addChore(
      String householdCode,
      String name,
      String details,
      String deadline,
      String dateCreated,
      String dateLastIncremented,
      int points,
      int threshold,
      int timesIncremented,
      int daysSinceLastIncremented,
      String createdByUserId,
      String? assignedUserId,
      String status) async {
    DatabaseReference choresRef =
        _databaseInstance.ref("households/$householdCode/$status");

    final choreKey = choresRef.push().key;
    print('CHOREKEY IS: $choreKey');
    if (choreKey == null) {
      throw Exception('Chore key is null');
    }

    DatabaseReference choreRef =
        _databaseInstance.ref("households/$householdCode/$status/$choreKey");

    choreRef.update({
      "id": choreKey,
      "name": name,
      "details": details,
      "deadline": deadline,
      "dateCreated": dateCreated,
      "dateLastIncremented": dateLastIncremented,
      "points": points,
      "threshold": threshold,
      "timesIncremented": timesIncremented,
      "daysSinceLastIncremented": daysSinceLastIncremented,
      "createdByUserId": createdByUserId,
      "assignedUserId": assignedUserId,
      "status": status
    }).then((value) {
      print("Successfully added chore!");
    }).catchError((value) {
      print(value);
      throw Exception('Could not add chore');
    });
    return choreKey;
  }

  static Future<void> updateChore({
    required String householdCode,
    required String choreId,
    String? name,
    String? details,
    String? deadline,
    String? dateCreated,
    String? dateLastIncremented,
    int? points,
    int? threshold,
    int? timesIncremented,
    int? daysSinceLastIncremented,
    String? createdByUserId,
    String? assignedUserId,
    String? status,
  }) async {
    DatabaseReference choreRef =
        _databaseInstance.ref("households/$householdCode/$status/$choreId");

    // Build the update map with only the fields that are not null
    Map<String, dynamic> updateMap = {};
    if (name != null) {
      updateMap['name'] = name;
    }
    if (details != null) {
      updateMap['details'] = details;
    }
    if (deadline != null) {
      updateMap['deadline'] = deadline;
    }
    if (dateCreated != null) {
      updateMap['dateCreated'] = dateCreated;
    }
    if (dateLastIncremented != null) {
      updateMap['dateLastIncremented'] = dateLastIncremented;
    }
    if (points != null) {
      updateMap['points'] = points;
    }
    if (threshold != null) {
      updateMap['threshold'] = threshold;
    }
    if (timesIncremented != null) {
      updateMap['timesIncremented'] = timesIncremented;
    }
    if (daysSinceLastIncremented != null) {
      updateMap['daysSinceLastIncremented'] = daysSinceLastIncremented;
    }
    if (createdByUserId != null) {
      updateMap['createdByUserId'] = createdByUserId;
    }
    if (assignedUserId != null) {
      updateMap['assignedUserId'] = assignedUserId;
    }
    if (status != null) {
      updateMap['status'] = status;
    }

    await choreRef.update(updateMap).then((value) {
      print("Successfully updated chore!");
    }).catchError((error) {
      print(error);
      throw Exception('Could not update chore');
    });
  }

  static Future<Chore?> getChoreFromId(
      String choreId, String householdId) async {
    Chore? foundChore;

    // Iterate over all possible ChoreStatus values
    for (ChoreStatus status in ChoreStatus.values) {
      DatabaseReference choreRef = _databaseInstance
          .ref("households/$householdId/${status.value}/$choreId");

      // Fetch the chore data
      DatabaseEvent event = await choreRef.once();

      // Check if the snapshot exists and contains data
      if (event.snapshot.exists) {
        // Assuming you have a Chore model with a fromMap constructor
        Map<String, dynamic> data =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        foundChore = Chore.buildChoreFromMap(data);
        break; // Exit the loop if the chore is found
      }
    }

    return foundChore;
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
    List<Chore> choresInProgress = await getChoresFromDB(
        ChoreStatus.inProgress, CurrentHousehold.getCurrentHouseholdId());
    List<Chore> choresCompleted = await getChoresFromDB(
        ChoreStatus.completed, CurrentHousehold.getCurrentHouseholdId());

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

    for (var chore in choresInProgress) {
      choreId = chore.id;
      choreRef = _databaseInstance
          .ref("households/$householdCode/choresInProgress/$choreId");
      choreRef.update({
        "daysSinceLastIncremented": 0,
        "dateLastIncremented":
            DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
      });
    }

    for (var chore in choresCompleted) {
      choreId = chore.id;
      choreRef = _databaseInstance
          .ref("households/$householdCode/choresCompleted/$choreId");
      choreRef.update({
        "daysSinceLastIncremented": 0,
        "dateLastIncremented":
            DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
      });
    }
  }

  static Future<void> deleteChore(String choreId, ChoreStatus status) async {
    String householdCode = CurrentHousehold.getCurrentHouseholdId();
    DatabaseReference choreRef = _databaseInstance
        .ref("households/$householdCode/${status.value}/$choreId");
    await choreRef.remove();
  }

  static Future<void> updateUserPoints(int points, bool increase) async {
    String userId = CurrentUser.getCurrentUserId();

    DatabaseReference userRef = _databaseInstance.ref("users/${userId}");
    DatabaseReference userPointsRef =
        _databaseInstance.ref("users/${userId}/totalPoints");

    DatabaseReference householdRef = _databaseInstance.ref(
        "households/${CurrentHousehold.getCurrentHouseholdId()}/users/$userId");

    DatabaseEvent userPointsEvent = await userPointsRef.once();

    if (userPointsEvent.snapshot.exists) {
      int userPoints = userPointsEvent.snapshot.value as int;
      if (increase == true) {
        await userRef.update({"totalPoints": userPoints + points});
        await householdRef.update({"totalPoints": userPoints + points});
        CurrentUser.setCurrentUserTotalPoints(userPoints + points);
      } else {
        await userRef.update({"totalPoints": userPoints - points});
        await householdRef.update({"totalPoints": userPoints - points});
        CurrentUser.setCurrentUserTotalPoints(userPoints - points);
      }
    } else {
      if (increase == true) {
        await userRef.update({"totalPoints": points});
        await householdRef.update({"totalPoints": points});
        CurrentUser.setCurrentUserTotalPoints(points);
      } else {
        await userRef.update({"totalPoints": 0});
        await householdRef.update({"totalPoints": 0});
        CurrentUser.setCurrentUserTotalPoints(0);
      }
    }
  }

  static Future<void> deleteChoreFromStringStatus(
      String choreId, String status) async {
    String householdCode = CurrentHousehold.getCurrentHouseholdId();
    DatabaseReference choreRef =
        _databaseInstance.ref("households/$householdCode/$status/$choreId");
    await choreRef.remove();
  }

  static Future<void> updateChoreStatus(String? assignedUserId, String choreId,
      ChoreStatus choreStatus, ChoreStatus newChoreStatus) async {
    String householdCode = CurrentHousehold.getCurrentHouseholdId();

    DatabaseReference choreRef = _databaseInstance
        .ref("households/$householdCode/${choreStatus.value}/$choreId");

    DatabaseEvent event = await choreRef.once();

    final choreJson = event.snapshot.child;

    if (newChoreStatus == ChoreStatus.toDo) {
      assignedUserId = null;
    }

    addChore(
      householdCode,
      choreJson("name").value.toString(),
      choreJson("details").value.toString(),
      choreJson("deadline").value.toString(),
      choreJson("dateCreated").value.toString(),
      choreJson("dateLastIncremented").value.toString(),
      int.parse(choreJson("points").value.toString()),
      int.parse(choreJson("threshold").value.toString()),
      int.parse(choreJson("timesIncremented").value.toString()),
      int.parse(choreJson("daysSinceLastIncremented").value.toString()),
      choreJson("createdByUserId").value.toString(),
      assignedUserId,
      newChoreStatus.value,
    );

    if (newChoreStatus == ChoreStatus.completed) {
      updateUserPoints(int.parse(choreJson("points").value.toString()), true);
    } else if (choreStatus == ChoreStatus.completed &&
        newChoreStatus == ChoreStatus.inProgress) {
      updateUserPoints(int.parse(choreJson("points").value.toString()), false);
    }

    await choreRef.remove();
  }
  // ------------------------ END CHORE OPERATIONS ------------------------

  // ------------------------ CALENDAR OPERATIONS ------------------------

  static void addEvent(
    String householdCode,
    String name,
    String details,
    String startTime,
    String endTime,
    String dateCreated,
    String type,
    String createdByUserId,
  ) async {
    DatabaseReference eventsRef =
        _databaseInstance.ref("households/$householdCode/events");

    final eventKey = eventsRef.push().key;
    if (eventKey == null) {
      throw Exception('Event key is null');
    }

    DatabaseReference eventRef =
        _databaseInstance.ref("households/$householdCode/events/$eventKey");

    eventRef.update({
      "id": eventKey,
      "name": name,
      "details": details,
      "startTime": startTime,
      "endTime": endTime,
      "dateCreated": dateCreated,
      "type": type,
      "createdByUserId": createdByUserId,
    }).then((value) {
      print("Successfully added event!");
    }).catchError((value) {
      print(value);
      throw Exception('Could not add event');
    });
  }

  static Future<List<Event>> getCalendarEventsFromDB(String householdId) async {
    final eventListRef =
        _databaseInstance.ref("households/$householdId/events");
    DatabaseEvent event = await eventListRef.once();
    final eventsJson = event.snapshot.children;

    List<Event> eventsList = <Event>[];

    for (final event in eventsJson) {
      eventsList.add(Event(
          event.child("id").value.toString(),
          event.child("name").value.toString(),
          event.child("details").value.toString(),
          event.child("startTime").value.toString(),
          event.child("endTime").value.toString(),
          event.child("dateCreated").value.toString(),
          event.child("type").value.toString(),
          event.child("createdByUserId").value.toString()));
    }
    return eventsList;
  }
  // ------------------------ END CALENDAR OPERATIONS ------------------------
}
