import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:roomease/shared/utils/shared_prefs_util.dart';
import '../model/household.dart';
import 'package:roomease/features/calendar/model/event.dart';
import 'package:roomease/features/chores/Chore.dart';

class CurrentHousehold {
  static var householdUserIdsSubscription =
      Stream<DatabaseEvent>.empty().listen((DatabaseEvent event) {});
  static var householdStatusValueListener =
      ValueNotifier<Map<String, Map<String, String>>>({});

  static Household getCurrentHousehold() {
    String householdId = SharedPreferencesUtility.getString("householdId");
    String householdName = SharedPreferencesUtility.getString("householdName");
    // Init with empty dynamic lists
    List<Chore> choresToDo = <Chore>[];
    List<Chore> choresInProgress = <Chore>[];
    List<Chore> choresCompleted = <Chore>[];
    List<Chore> choresArchived = <Chore>[];
    List<Event> calendarEvents = <Event>[];
    return Household(householdName, householdId, List.empty(), choresToDo,
        choresInProgress, choresCompleted, choresArchived, calendarEvents);
  }

  static String getCurrentHouseholdId() {
    return SharedPreferencesUtility.getString("householdId");
  }

  static String getCurrentHouseholdName() {
    return SharedPreferencesUtility.getString("householdName");
  }

  static void setCurrentHouseholdId(String householdId) {
    SharedPreferencesUtility.setValue("householdId", householdId);
  }

  static void setCurrentHouseholdName(String householdName) {
    SharedPreferencesUtility.setValue("householdName", householdName);
  }
}
