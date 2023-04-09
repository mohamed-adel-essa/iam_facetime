import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({
    required this.user,
  });
  //required this.imagePath});

  final String user;
//  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(),
            // Container(
            //   width: MediaQuery.of(context).size.width / 1.5,
            //   height: MediaQuery.of(context).size.height / 2,
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       color: Colors.lightBlueAccent,
            //       width: 2,
            //     ),
            //     shape: BoxShape.circle,
            //     image: DecorationImage(
            //       fit: BoxFit.fill,
            //       image: AssetImage(imagePath),
            //     ),
            //   ),
            // ),
            Text(
              "Welcome back  $user",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
