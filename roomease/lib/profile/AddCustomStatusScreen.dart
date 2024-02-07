import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/colors/ColorConstants.dart';

class AddCustomStatus extends StatefulWidget {
  @override
  State createState() {
    return _AddCustomStatusState();
  }
}

class _AddCustomStatusState extends State<AddCustomStatus> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController newStatusController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Custom Status"),
          backgroundColor: ColorConstants.lightPurple,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Add Status'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text('Enter your new status:')),
                      Form(
                          key: _formKey,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Status",
                            ),
                            controller: newStatusController,
                            maxLines: 1,
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return 'Status cannot be empty';
                              } else if (CurrentUser.getCurrentUserStatusList()
                                  .contains(value)) {
                                return 'Status is already added';
                              }
                              return null;
                            }),
                          )),
                    ]),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      newStatusController.text = "";
                      Navigator.pop(context, 'Cancel');
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (newStatusController.text.isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, 'OK');
                          await DatabaseManager.addStatusToUserStatusList(
                              newStatusController.text,
                              CurrentUser.getCurrentUserId());
                          CurrentUser.addStatusToStatusList(
                              newStatusController.text);
                          setState(() {
                            newStatusController.text = "";
                          });
                        } else {
                          // Duplicate status
                        }
                      } else {
                        // Empty status
                      }
                    },
                    child: const Text('OK'),
                  )
                ],
              ),
            );
          },
          foregroundColor: Colors.white,
          backgroundColor: ColorConstants.lightPurple,
          child: const Icon(Icons.add),
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 40, left: 30, right: 30),
            child: Column(
                children: CurrentUser.getCurrentUserStatusList()
                    .map<Padding>((String status) {
              if (status == CurrentUser.getCurrentUserStatus()) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(children: [
                      Text(
                          style: TextStyle(fontSize: 15),
                          "$status (Current Status)"),
                      Spacer(),
                      IconButton(
                          icon: Image.asset('assets/delete_icon_disabled.png',
                              width: 25, height: 25),
                          onPressed: () async {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text('Cannot Delete Current Status'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ]));
              } else {
                return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(children: [
                      Text(style: TextStyle(fontSize: 15), status),
                      Spacer(),
                      IconButton(
                          icon: Image.asset('assets/delete_icon.png',
                              width: 25, height: 25),
                          onPressed: () async {
                            await DatabaseManager
                                .removeStatusFromUserStatusList(
                                    status, CurrentUser.getCurrentUserId());
                            CurrentUser.removeStatusFromStatusList(status);
                            setState(() {});
                          }),
                    ]));
              }
            }).toList())));
  }
}
