import 'Message.dart';
import 'User.dart';

class MessageRoom {
  String messageRoomId;
  List<Message> messages;
  List<User> users;

  MessageRoom(this.messageRoomId, this.messages, this.users);
}
