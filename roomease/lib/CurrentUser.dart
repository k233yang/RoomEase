import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:roomease/Roomeo/RoomeoUser.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'User.dart';

class CurrentUser {
  static var userNameSubscription =
      Stream<DatabaseEvent>.empty().listen((DatabaseEvent event) {});
  static var userMessageRoomValueListener =
      ValueNotifier<Map<String, List<Map<String, String>>>>({});

  static User getCurrentUser() {
    String userId = SharedPreferencesUtility.getString("userId");
    String userName = SharedPreferencesUtility.getString("userName");
    String householdId = SharedPreferencesUtility.getString("householdId");
    String userStatus = SharedPreferencesUtility.getString("userStatus");
    List<String> userStatusList =
        SharedPreferencesUtility.getStringList("userStatusList");
    List<String> messageRoomIds =
        SharedPreferencesUtility.getStringList("messageRoomIds");
    int iconNumber = SharedPreferencesUtility.getInt("iconNumber");
    int totalPoints = SharedPreferencesUtility.getInt("totalPoints");
    
    return User(userName, userId, householdId, userStatus, userStatusList,
        messageRoomIds, iconNumber, totalPoints);
  }

  static String getCurrentUserId() {
    return SharedPreferencesUtility.getString("userId");
  }

  static String getCurrentUserName() {
    return SharedPreferencesUtility.getString("userName");
  }

  static List<String> getCurrentMessageRoomIds() {
    return SharedPreferencesUtility.getStringList("messageRoomIds");
  }

  static String getCurrentRoomeoMessageRoomId() {
    List<String> messageRoomIds =
        SharedPreferencesUtility.getStringList("messageRoomIds");
    for (var id in messageRoomIds) {
      if (id.contains(RoomeoUser.user.userId)) {
        return id;
      }
    }
    return "";
  }

  static String getCurrentUserStatus() {
    return SharedPreferencesUtility.getString("userStatus");
  }

  static List<String> getCurrentUserStatusList() {
    return SharedPreferencesUtility.getStringList("userStatusList");
  }

  static void setCurrentMessageRoomIds(List<String> messageRoomIds) {
    SharedPreferencesUtility.setValue("messageRoomIds", messageRoomIds);
  }

  static void setCurrentUserId(String userId) {
    SharedPreferencesUtility.setValue("userId", userId);
  }

  static void setCurrentUserName(String userName) {
    SharedPreferencesUtility.setValue("userName", userName);
  }

  static void setCurrentUserStatusList(List<String> userStatusList) {
    SharedPreferencesUtility.setValue("userStatusList", userStatusList);
  }

  static void setCurrentUserStatus(String status) {
    SharedPreferencesUtility.setValue("userStatus", status);
  }

  static void addStatusToStatusList(String status) {
    List<String> userStatusList =
        SharedPreferencesUtility.getStringList("userStatusList");
    userStatusList.add(status);
    SharedPreferencesUtility.setValue("userStatusList", userStatusList);
  }

  static void removeStatusFromStatusList(String status) {
    List<String> userStatusList =
        SharedPreferencesUtility.getStringList("userStatusList");
    userStatusList.remove(status);
    SharedPreferencesUtility.setValue("userStatusList", userStatusList);
  }

  static int getCurrentUserIconNumber() {
    return SharedPreferencesUtility.getInt("iconNumber");
  }

  static void setCurrentUserIconNumber(int iconNumber) {
    SharedPreferencesUtility.setValue("iconNumber", iconNumber);
  }

  static int getCurrentUserTotalPoints() {
    return SharedPreferencesUtility.getInt("totalPoints");
  }

  static void setCurrentUserTotalPoints(int points) {
    SharedPreferencesUtility.setValue("totalPoints", points);
  }
}
