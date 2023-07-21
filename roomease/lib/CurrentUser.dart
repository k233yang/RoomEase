import 'User.dart';

class CurrentUser {
  //TODO: persistent storage
  static User user = User("", "");

  static void setCurrentUser(User user) {
    CurrentUser.user = user;
  }
}
