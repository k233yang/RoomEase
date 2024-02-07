import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/colors/ColorConstants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  @override
  State createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late User user;
  var initialName = CurrentUser.getCurrentUserName();
  var initialEmail = "";

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      initialEmail = _auth.currentUser?.email as String;
      emailController.text = initialEmail;
      nameController.text = initialName;
      user = _auth.currentUser as User;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
          backgroundColor: ColorConstants.lightPurple,
        ),
        body: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "Name"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name must be non-empty';
                            }
                            return null;
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: "Email"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email must be non-empty';
                            }
                            return null;
                          },
                        )),
                    Center(
                        child: ElevatedButton(
                            child: Text("Save Changes"),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (nameController.text != initialName) {
                                  DatabaseManager.addUser(
                                      CurrentUser.getCurrentUserId(),
                                      nameController.text);
                                  CurrentUser.setCurrentUserName(
                                      nameController.text);
                                }
                                if (emailController.text != initialEmail) {
                                  user.updateEmail(emailController.text);
                                }
                                Navigator.pop(context);
                              }
                            }))
                  ])),
        ));
  }
}
