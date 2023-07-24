import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import 'User.dart';

class CurrentUser {
  //TODO: persistent storage
  static User user = User("", "");
  static var userNameSubscription =
      Stream<DatabaseEvent>.empty().listen((DatabaseEvent event) {});

  static void setCurrentUserId(String userId) {
    CurrentUser.user.userId = userId;
  }

  static void setCurrentUserName(String userName) {
    CurrentUser.user.name = userName;
  }
}
