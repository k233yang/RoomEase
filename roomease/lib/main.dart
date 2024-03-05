import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/HomeScreen.dart';
import 'package:roomease/Roomeo/ChatListScreen.dart';
import 'package:roomease/Roomeo/ChatScreen.dart';
import 'package:roomease/SharedPreferencesUtility.dart';
import 'package:roomease/calendar/CalendarScreen.dart';
import 'package:roomease/chores/ChoreScreen.dart';
import 'package:roomease/chores/AddChoreScreen.dart';
import 'package:roomease/profile/AddCustomStatusScreen.dart';
import 'package:roomease/profile/EditProfileScreen.dart';
import 'package:roomease/profile/ProfileScreen.dart';
import 'package:roomease/welcome/CreateHousehold.dart';
import 'package:roomease/welcome/CreateJoinHouseholdScreen.dart';
import 'package:roomease/welcome/JoinHousehold.dart';
import 'package:roomease/welcome/LoginScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roomease/welcome/WelcomeScreen.dart';
import 'calendar/AddEventScreen.dart';
import 'firebase_options.dart';
import 'welcome/RegisterScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'RoomEase',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesUtility.init();
  bool noHousehold = false;
  if (SharedPreferencesUtility.getBool("isLoggedIn")) {
    String? householdId =
        await DatabaseManager.getUsersHousehold(CurrentUser.getCurrentUserId());
    if (householdId == null) {
      noHousehold = true;
    }
  }
  runApp(MyApp(noHousehold: noHousehold));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.noHousehold});
  final bool noHousehold;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomEase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: ColorConstants.lightPurple),
      ),
      initialRoute: initialScreen(noHousehold),
      routes: {
        '/welcome': (_) => WelcomeScreen(),
        '/login': (_) => Login(),
        '/register': (_) => Register(),
        '/home': (_) => Home(),
        '/createJoinHousehold': (_) => CreateJoinHouseholdScreen(),
        '/createHousehold': (_) => CreateHousehold(),
        '/joinHousehold': (_) => JoinHousehold(),
        '/chores': (_) => ChoreScreen(),
        '/addChore': (_) => AddChoreScreen(),
        '/addEvent': (_) => AddEventScreen(),
        '/profile': (_) => Profile(),
        '/editProfile': (_) => EditProfile(),
        '/addCustomStatus': (_) => AddCustomStatus(),
        '/chatList': (_) => ChatListScreen(),
        '/calendar': (context) => CalendarScreen(),
      },
    );
  }

  String initialScreen(bool noHousehold) {
    if (SharedPreferencesUtility.getBool("isLoggedIn")) {
      if (noHousehold) {
        return '/createJoinHousehold';
      } else {
        return '/home';
      }
    } else {
      return '/welcome';
    }
  }
}
