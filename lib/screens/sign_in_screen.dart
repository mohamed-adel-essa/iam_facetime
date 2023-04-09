// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:face/widgets/FacePainter.dart';
import 'package:face/widgets/camera_header.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../services/camera_services.dart';
import '../services/dep.dart';
import '../services/face_net_services.dart';
import '../services/ml_kit_services.dart';
import '../widgets/auth-action-button.dart';

class FaceSignIn extends StatefulWidget {
  final CameraDescription cameraDescription;

  const FaceSignIn({
    required this.cameraDescription,
  });

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<FaceSignIn> {
  /// Service injection
  final CameraService _cameraService = CameraService();
  final MLKitService _mlKitService = MLKitService();
  final FaceNetService _faceNetService = getIt<FaceNetService>();

  late Future _initializeControllerFuture;

  bool cameraInitializated = false;
  bool _detectingFaces = false;
  bool pictureTaked = false;

  // switchs when the user press the camera
  bool _saving = false;
  bool _bottomSheetVisible = false;

  late String imagePath;
  late Size imageSize;
  Face? faceDetected;

  @override
  void initState() {
    super.initState();

    /// starts the camera & start framing faces
    _start();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    super.dispose();
  }

  /// starts the camera & start framing faces
  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_detectingFaces) return;

      _detectingFaces = true;

      try {
        List<Face> faces = await _mlKitService.getFacesFromImage(image);

        if (faces.isNotEmpty) {
          // preprocessing the image
          setState(() {
            faceDetected = faces[0];
          });

          if (_saving) {
            _saving = false;
            getIt<FaceNetService>().setCurrentPrediction(image, faceDetected!);
          }
        } else {
          setState(() {});
        }

        _detectingFaces = false;
      } catch (e) {
        print(e);
        _detectingFaces = false;
      }
    });
  }

  /// handles the button pressed event
  Future<bool> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );

      return false;
    } else {
      _saving = true;

      await Future.delayed(const Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      XFile file = await _cameraService.takePicture();

      setState(() {
        _bottomSheetVisible = true;
        pictureTaked = true;
        imagePath = file.path;
      });

      return true;
    }
  }

  _reload() {
    setState(() {
      _bottomSheetVisible = false;
      cameraInitializated = false;
      pictureTaked = false;
    });
    _start();
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return !cameraInitializated || faceDetected == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Stack(
              children: [
                FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (pictureTaked) {
                          return SizedBox(
                            width: width,
                            height: height,
                            child: Transform(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image.file(File(imagePath)),
                                ),
                                transform: Matrix4.rotationY(mirror)),
                          );
                        } else {
                          return Transform.scale(
                            scale: 1.0,
                            child: AspectRatio(
                              aspectRatio:
                                  MediaQuery.of(context).size.aspectRatio,
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: SizedBox(
                                    width: width,
                                    height: width *
                                        _cameraService
                                            .cameraController.value.aspectRatio,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        CameraPreview(
                                            _cameraService.cameraController),
                                        if (faceDetected != null)
                                          CustomPaint(
                                            painter: FacePainter(
                                                face: faceDetected!,
                                                imageSize: imageSize),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
                CameraHeader(
                  "LOGIN",
                  onBackPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: !_bottomSheetVisible
                ? AuthActionButton(
                    _initializeControllerFuture,
                    onPressed: onShot,
                    isLogin: true,
                    reload: _reload,
                  )
                : Container(),
          );
  }
}
