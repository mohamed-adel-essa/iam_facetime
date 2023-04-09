import 'package:face/screens/home_screen.dart';
import 'package:face/services/dep.dart';
import 'package:face/widgets/app_text_field.dart';
import 'package:face/widgets/signup_sheet.dart';

import '../../screens/Profile_screen.dart';
import '../../widgets/app_button.dart';
import '../modals/user_model.dart';
import '../services/camera_services.dart';
import '../services/face_net_services.dart';
import 'package:flutter/material.dart';

class AuthActionButton extends StatefulWidget {
  const AuthActionButton(this._initializeControllerFuture,
      {required this.onPressed, required this.isLogin, required this.reload});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection

  final CameraService _cameraService = CameraService();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User? predictedUser;

  Future _signIn(context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Profile(
          user: predictedUser!.user,
          //imagePath: _cameraService.imagePath,
        ),
      ),
    );
  }

  String _predictUser() {
    String userAndPass = getIt<FaceNetService>().predictNearset();

    return userAndPass;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          // Ensure that the camera is initialized.
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          bool faceDetected = await widget.onPressed();

          if (faceDetected) {
            if (widget.isLogin) {
              _checkUserToLogin();
            } else {
              _checkUserToSignUp();
            }
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(context) {
    GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome back, ' + predictedUser!.user + '.',
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: const Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  !widget.isLogin
                      ? AppTextField(
                          controller: _userTextEditingController,
                          labelText: "Your Name",
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  widget.isLogin && predictedUser == null
                      ? Container()
                      : AppTextField(
                          controller: _passwordTextEditingController,
                          labelText: "Password",
                          isPassword: true,
                        ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  predictedUser != null
                      ? AppButton(
                          text: 'LOGIN',
                          onPressed: () async {
                            _signIn(context);
                          },
                          icon: const Icon(
                            Icons.login,
                            color: Colors.white,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _checkUserToSignUp() {
    var userAndPass = _predictUser();
    if (userAndPass != "null") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          " user Exisit ,try login ",
          textAlign: TextAlign.center,
        ),
      ));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => HomeScreen()), (route) => false);
    } else {
      if (!widget.isLogin) {
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => SignUpSheet(
                  cameraService: _cameraService,
                ));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      } else {
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));

        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    }
  }

  _checkUserToLogin() {
    var userAndPass = _predictUser();

    if (userAndPass == "null") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "No User Found",
          textAlign: TextAlign.center,
        ),
      ));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => HomeScreen()), (route) => false);
    } else {
      predictedUser = User.fromDB(userAndPass);
      _signIn(context);
      // PersistentBottomSheetController bottomSheetController =
      //     Scaffold.of(context).showBottomSheet((context) => signSheet(context));
      // bottomSheetController.closed.whenComplete(() => widget.reload());
    }
  }
}
