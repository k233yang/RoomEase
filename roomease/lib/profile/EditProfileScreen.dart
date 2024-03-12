import 'package:flutter/material.dart';
import 'package:roomease/CurrentHousehold.dart';
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
  bool showWidget = false;
  int selectedIcon = CurrentUser.getCurrentUserIconNumber();
  int initialUserIcon = CurrentUser.getCurrentUserIconNumber();

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
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(children: [
                          Image(
                            image: AssetImage(iconNumberMapping(selectedIcon)),
                            height: 100,
                            width: 100,
                          ),
                          TextButton(
                              onPressed: () => {
                                    setState(() {
                                      showWidget = !showWidget;
                                    })
                                  },
                              child: Text("Change Profile Picture"))
                        ])),
                    Column(children: [
                      showWidget
                          ? Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  smallIcon('assets/user_avatar_C_red.png', 0),
                                  smallIcon(
                                      'assets/user_avatar_C_orange.png', 1),
                                  smallIcon(
                                      'assets/user_avatar_D_yellow.png', 2),
                                  smallIcon(
                                      'assets/user_avatar_A_green.png', 3),
                                  smallIcon('assets/user_avatar_B_blue.png', 4),
                                  smallIcon('assets/user_avatar_B_pink.png', 5),
                                  smallIcon('assets/user_avatar_A_grey.png', 6),
                                ],
                              ))
                          : Container()
                    ]),
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
                                  DatabaseManager.editUserNameInHousehold(
                                      CurrentUser.getCurrentUserId(),
                                      nameController.text);
                                }
                                if (emailController.text != initialEmail) {
                                  user.verifyBeforeUpdateEmail(
                                      emailController.text);
                                }
                                if (initialUserIcon != selectedIcon) {
                                  CurrentUser.setCurrentUserIconNumber(
                                      selectedIcon);
                                  DatabaseManager.setUserCurrentIconNumber(
                                      CurrentUser.getCurrentUserId(),
                                      selectedIcon);
                                }
                                Navigator.pop(context);
                              }
                            }))
                  ])),
        )));
  }

  Widget smallIcon(String imagePath, int iconNumber) {
    if (iconNumber == 6) {
      if (iconNumber == selectedIcon) {
        return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              shape: BoxShape.rectangle,
            ),
            child: IconButton(
                onPressed: () => {setState(() => selectedIcon = iconNumber)},
                icon: Image(
                  image: AssetImage(imagePath),
                  height: 30,
                  width: 30,
                )));
      } else {
        return IconButton(
            onPressed: () => {setState(() => selectedIcon = iconNumber)},
            icon: Image(
              image: AssetImage(imagePath),
              height: 30,
              width: 30,
            ));
      }
    } else {
      if (iconNumber == selectedIcon) {
        return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              shape: BoxShape.rectangle,
            ),
            child: IconButton(
                onPressed: () => {setState(() => selectedIcon = iconNumber)},
                icon: Image(
                  image: AssetImage(imagePath),
                  height: 30,
                  width: 30,
                )));
      } else {
        return IconButton(
            onPressed: () => {setState(() => selectedIcon = iconNumber)},
            icon: Image(
              image: AssetImage(imagePath),
              height: 30,
              width: 30,
            ));
      }
    }
  }
}

String iconNumberMapping(int iconNumber) {
  switch (iconNumber) {
    case 0:
      return 'assets/user_avatar_C_red.png';
    case 1:
      return 'assets/user_avatar_C_orange.png';
    case 2:
      return 'assets/user_avatar_D_yellow.png';
    case 3:
      return 'assets/user_avatar_A_green.png';
    case 4:
      return 'assets/user_avatar_B_blue.png';
    case 5:
      return 'assets/user_avatar_B_pink.png';
    case 6:
      return 'assets/user_avatar_A_grey.png';
    case 100:
      return 'assets/roomeo_user_icon.png';
    default:
      return 'assets/user_avatar_A_grey.png';
  }
}
