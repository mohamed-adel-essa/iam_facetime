import 'dart:developer';

import 'package:face/db/db_services.dart';
import 'package:face/screens/home_screen.dart';
import 'package:face/services/camera_services.dart';
import 'package:face/services/face_net_services.dart';
import 'package:face/widgets/app_button.dart';
import 'package:flutter/material.dart';

import '../services/dep.dart';

class SignUpSheet extends StatelessWidget {
  SignUpSheet({required this.cameraService});
  CameraService cameraService;
  GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  final TextEditingController _userTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final FaceNetService _faceNetService = getIt<FaceNetService>();
  final DataBaseService _dataBaseService = DataBaseService();

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    try {
      List predictedData = _faceNetService.predictedData;
      String user = _userTextEditingController.text;
      String password = _passwordTextEditingController.text;

      /// creates a new user in the 'database'
      await _dataBaseService.saveData(
          user, password, cameraService.imagePath, predictedData);

      /// resets the face stored in the face net sevice
      _faceNetService.setPredictedData(null);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height / 2.5,
      child: Form(
        key: _fromKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: _userTextEditingController,
              validator: ((value) {
                if (value!.isEmpty) {
                  return 'required';
                } else {
                  return null;
                }
              }),
              cursorColor: const Color(0xFF5BC8AA),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: "Your name",
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
              controller: _passwordTextEditingController,
              validator: ((value) {
                if (value!.isEmpty) {
                  return 'required';
                } else {
                  return null;
                }
              }),
              cursorColor: const Color(0xFF5BC8AA),
              obscureText: true,
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
            ),
            const Divider(),
            const SizedBox(height: 10),
            AppButton(
              text: 'SIGN UP',
              onPressed: () async {
                if (_fromKey.currentState!.validate()) {
                  _fromKey.currentState!.save();
                  await _signUp(context);
                }
                log("sss");
              },
              icon: const Icon(
                Icons.person_add,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
