import 'package:roomease/shared/model/user.dart';

class Message {
  String text;
  String senderId;
  String senderName;
  DateTime timestamp;

  Message(this.text, this.senderId, this.senderName, this.timestamp);
}
