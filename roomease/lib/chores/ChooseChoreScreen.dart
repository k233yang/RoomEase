import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:roomease/CurrentHousehold.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/chores/Chore.dart';
import 'package:roomease/colors/ColorConstants.dart';

// TODO: FINISH THIS NEXT
class ChooseChoreScreen extends StatefulWidget {
  final List<String> choreIds;
  const ChooseChoreScreen({
    super.key,
    required this.choreIds,
  });

  @override
  State<ChooseChoreScreen> createState() => _ChooseChoreScreenState();
}

class _ChooseChoreScreenState extends State<ChooseChoreScreen> {
  Future<List<Chore>> fetchChores() async {
    final choresFutures = widget.choreIds.map((choreId) =>
        DatabaseManager.getChoreFromId(
            choreId, CurrentHousehold.getCurrentHouseholdId()));
    final chores = await Future.wait(choresFutures);
    return chores.whereType<Chore>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fill out Missing Info'),
          backgroundColor: ColorConstants.lightPurple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {},
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.choreIds.map((choreId) => Text(choreId)).toList(),
        ),
      ),
    );
  }
}
