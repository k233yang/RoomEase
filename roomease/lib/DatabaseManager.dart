import 'package:firebase_database/firebase_database.dart';
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
}
