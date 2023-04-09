import 'dart:developer';

import 'package:face/db/db_services.dart';
import 'package:face/screens/profile_screen.dart';
import 'package:face/screens/sign_in_screen.dart';
import 'package:face/screens/sign_up_screen.dart';
import 'package:camera/camera.dart';
import 'package:face/screens/users_screen.dart';
import 'package:face/services/dep.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../services/face_net_services.dart';
import '../services/ml_kit_services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  // Services injection
  final FaceNetService _faceNetService = getIt<FaceNetService>();
  final MLKitService _mlKitService = MLKitService();
  final DataBaseService _dataBaseService = DataBaseService();

  late CameraDescription cameraDescription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  /// 1 Obtain a list of the available cameras on the device.
  /// 2 loads the face net model
  _startUp() async {
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );

    // start the services
    await _faceNetService.loadModel();
    await _dataBaseService.loadDB();
    _mlKitService.initialize();

    _setLoading(false);
  }

  // shows or hides the circular progress indicator
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !loading
          ? SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Alert(
                          context: context,
                          type: AlertType.info,
                          title: "Login By ?",
                          buttons: [
                            DialogButton(
                              color: Color(0xFF0F0BDB),
                              child: Text(
                                "Face Id",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        FaceSignIn(
                                      cameraDescription: cameraDescription,
                                    ),
                                  ),
                                );
                              },
                              width: 120,
                            ),
                            DialogButton(
                              color: Colors.green,
                              child: Text(
                                "user&password",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                signInSheet(context);
                              },
                              width: 120,
                            )
                          ],
                        ).show();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'LOGIN',
                              style: TextStyle(color: Color(0xFF0F0BDB)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.login, color: Color(0xFF0F0BDB))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => SignUp(
                              cameraDescription: cameraDescription,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF0F0BDB),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'SIGN UP',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.person_add, color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Alert(
                          context: context,
                          type: AlertType.error,
                          title: "Delete all user ?",
                          desc: "are you sure ",
                          buttons: [
                            DialogButton(
                              color: Colors.red,
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () {
                                getIt<DataBaseService>().cleanDB();
                                Navigator.pop(context);
                              },
                              width: 120,
                            ),
                            DialogButton(
                              color: Colors.green,
                              child: Text(
                                "no",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              width: 120,
                            )
                          ],
                        ).show();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'clear data',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.person_remove, color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => UsersScreen()));
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.teal,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getIt<DataBaseService>()
                                      .db
                                      .keys
                                      .length
                                      .toString() +
                                  " " +
                                  'Users',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.person, color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  signInSheet(context) {
    TextEditingController _passwordContoller = TextEditingController();
    TextEditingController _userNameContoller = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Alert(
        context: context,
        type: AlertType.info,
        title: "Login",
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _userNameContoller,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "required";
                    } else {
                      return null;
                    }
                  },
                  cursorColor: const Color(0xFF5BC8AA),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: "User name",
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordContoller,
                  cursorColor: const Color(0xFF5BC8AA),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "required";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: "Password",
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            color: Colors.green,
            child: Text(
              'LOGIN',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                log("res ${_passwordContoller.text}");
                var res = await getIt<DataBaseService>().logInByUserAndPassword(
                    user: _userNameContoller.text,
                    password: _passwordContoller.text);
                log("res ${res}");
                if (res) {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return Profile(user: _userNameContoller.text);
                  }));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Wrong User Or Password",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                }
                // User   user = User.fromDB(userAndPass);
              }
            },
          ),
        ]).show();
  }
}
