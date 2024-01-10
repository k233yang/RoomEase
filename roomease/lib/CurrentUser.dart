import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'User.dart';

class CurrentUser {
  static var userNameSubscription =
      Stream<DatabaseEvent>.empty().listen((DatabaseEvent event) {});

  static User getCurrentUser() {
    String userId = SharedPreferencesUtility.getString("userId");
    String userName = SharedPreferencesUtility.getString("userName");
    return User(userName, userId);
  }

  static String getCurrentUserId() {
    return SharedPreferencesUtility.getString("userId");
  }

  static String getCurrentUserName() {
    return SharedPreferencesUtility.getString("userName");
  }

  static void setCurrentUserId(String userId) {
    SharedPreferencesUtility.setValue("userId", userId);
  }

  static void setCurrentUserName(String userName) {
    SharedPreferencesUtility.setValue("userName", userName);
  }
}
