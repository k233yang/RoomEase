import 'package:flutter/material.dart';
import '../colors/ColorConstants.dart';

class AddChoreScreen extends StatefulWidget {
  const AddChoreScreen({super.key});

  @override
  State<AddChoreScreen> createState() => _ChoreScreen();
}

class _ChoreScreen extends State<AddChoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Add Chore'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: Container(
          color: ColorConstants.white,
          child: Column(children: [
          ])));
  }
}