import 'package:flutter/material.dart';
import 'package:roomease/shared/repository/user_repository.dart';
import 'package:roomease/shared/data/database_manager.dart';
import 'package:roomease/features/home/HomeScreen.dart';
import 'package:roomease/features/roomeo/ChatListScreen.dart';
import 'package:roomease/features/roomeo/ChatScreen.dart';
import 'package:roomease/shared/utils/shared_prefs_util.dart';
import 'package:roomease/features/calendar/view/calendar_screen.dart';
import 'package:roomease/features/chores/ChoreScreen.dart';
import 'package:roomease/features/chores/AddChoreScreen.dart';
import 'package:roomease/features/profile/AddCustomStatusScreen.dart';
import 'package:roomease/features/profile/EditProfileScreen.dart';
import 'package:roomease/features/profile/ProfileScreen.dart';
import 'package:roomease/features/auth/CreateHousehold.dart';
import 'package:roomease/features/auth/CreateJoinHouseholdScreen.dart';
import 'package:roomease/features/auth/JoinHousehold.dart';
import 'package:roomease/features/auth/LoginScreen.dart';
import 'package:roomease/shared/color_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roomease/features/auth/WelcomeScreen.dart';
import 'package:roomease/features/calendar/view/add_event_screen.dart';
import 'config/firebase_options.dart';
import 'package:roomease/features/auth/RegisterScreen.dart';

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
        '/auth': (_) => WelcomeScreen(),
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
      return '/auth';
    }
  }
}
