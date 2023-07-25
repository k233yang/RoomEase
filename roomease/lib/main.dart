import 'package:flutter/material.dart';
import 'package:roomease/HomeScreen.dart';
import 'package:roomease/welcome/CreateHousehold.dart';
import 'package:roomease/welcome/CreateJoinHouseholdScreen.dart';
import 'package:roomease/welcome/JoinHousehold.dart';
import 'package:roomease/welcome/LoginScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roomease/welcome/WelcomeScreen.dart';
import 'firebase_options.dart';
import 'welcome/RegisterScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'RoomEase',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => WelcomeScreen(),
        '/login': (_) => Login(),
        '/register': (_) => Register(),
        '/home': (_) => Home(),
        '/createJoinHousehold': (_) => CreateJoinHouseholdScreen(),
        '/createHousehold': (_) => CreateHousehold(),
        '/joinHousehold': (_) => JoinHousehold(),
      },
    );
  }
}
