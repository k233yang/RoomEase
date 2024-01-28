import 'package:flutter/material.dart';
import 'package:roomease/chores/ChoreItem.dart';
import 'package:roomease/chores/ChoreStatus.dart';

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
        title: const Text('Chores'),
        backgroundColor: ColorConstants.lightPurple,
      ),
      body: Container(
        color: ColorConstants.white,
        child: Column(
          children: [ // TODO: Take the list of Chore Items and make that a widget or smth
            //            Or take all chore items and list them
            Center(child: getChoreTile(ChoreStatus.toDo)),
          ]
        )
      ),
      floatingActionButton:  CreateAddChoreButton(
        onButtonPress: () {
          Navigator.pushNamed(context, "/addChore");
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CreateAddChoreButton extends StatelessWidget {
  final VoidCallback onButtonPress;

  CreateAddChoreButton(
    {Key? key, required this.onButtonPress})
    : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: ColorConstants.white,
      backgroundColor: ColorConstants.darkPurple,
      shape: CircleBorder(),
      onPressed: onButtonPress,
      child: const Icon(Icons.add)
    );
  }
}