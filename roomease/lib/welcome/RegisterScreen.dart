import 'package:flutter/material.dart';
import 'package:roomease/CurrentUser.dart';
import 'package:roomease/DatabaseManager.dart';
import 'package:roomease/HomeScreen.dart';
import 'package:roomease/MessageRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../User.dart' as RUser;

class Register extends StatefulWidget {
  @override
  State createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RoomEase"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Confirm password"),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.compareTo(passwordController.text) != 0) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text);
                          if (newUser != null) {
                            CurrentUser.setCurrentUser(RUser.User(
                              "kenny",
                              newUser.user!.uid,
                            ));
                            DatabaseManager.addUser(
                                CurrentUser.user); //TODO: check if exists
                            DatabaseManager.addMessageRoom(MessageRoom(
                                "messageRoomId", [], <RUser.User>[
                              CurrentUser.user,
                              RUser.User("chatgpt", "useridchatgpt")
                            ]));
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          Widget errorText = Text('Something went wrong');
                          if (e.code == 'email-already-in-use') {
                            errorText = Text(
                                'The account already exists for that email.');
                          } else if (e.code == 'weak-password') {
                            errorText =
                                Text('The password provided is too weak.');
                          }
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: errorText));
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
