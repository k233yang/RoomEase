import 'User.dart';

class Message {
  String text;
  User sender;
  DateTime timestamp;

  Message(this.text, this.sender, this.timestamp);
}
