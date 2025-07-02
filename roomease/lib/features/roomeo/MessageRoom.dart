import 'package:roomease/features/roomeo/Message.dart';
import '../../shared/model/user.dart';

class MessageRoom {
  String messageRoomId;
  List<Message> messages;
  List<User> users;

  MessageRoom(this.messageRoomId, this.messages, this.users);
}
