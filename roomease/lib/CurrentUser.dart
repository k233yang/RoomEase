import 'User.dart';

class CurrentUser {
  static User user = User("", "");

  static void setCurrentUser(User user) {
    CurrentUser.user = user;
  }
}
