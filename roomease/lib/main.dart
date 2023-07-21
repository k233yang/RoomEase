import 'package:flutter/material.dart';
import 'package:roomease/HomeScreen.dart';
import 'package:roomease/LoginScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomEase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: ColorConstants.lightPurple),
      ),
      home: Login(),
    );
  }
}
