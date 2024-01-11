import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors/ColorConstants.dart';

class ChoreScreen extends StatefulWidget {
  const ChoreScreen({super.key});

  @override
  State<ChoreScreen> createState() => _ChoreScreen();
}

class _ChoreScreen extends State<ChoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Chore Board'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: Container(
          color: ColorConstants.white,
          child: Column(children: [
          ])));
  }
}