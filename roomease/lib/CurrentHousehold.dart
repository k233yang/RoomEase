import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'Household.dart';

class CurrentHousehold {
  static Household getCurrentHousehold() {
    String householdId = SharedPreferencesUtility.getString("householdId");
    String householdName = SharedPreferencesUtility.getString("householdName");
    return Household(householdName, householdId, List.empty(), List.empty(), List.empty(), List.empty(), List.empty());
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
