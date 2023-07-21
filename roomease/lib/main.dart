import 'package:flutter/material.dart';
import 'package:roomease/HomeScreen.dart';
import 'package:roomease/LoginScreen.dart';
import 'package:roomease/colors/ColorConstants.dart';

void main() {
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
