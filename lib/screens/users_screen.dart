import 'package:face/db/db_services.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../services/dep.dart';

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: 50,
                  child: const Center(child: Icon(Icons.arrow_back)),
                ),
              ),
              Text(
                "Users",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                width: 90,
              )
            ],
          ),
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.teal,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.teal, Colors.transparent],
            ),
          ),
        ),
        preferredSize: Size.fromHeight(80),
      ),
      body: ListView.builder(
        itemCount: getIt<DataBaseService>().db.keys.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(20),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    "${index + 1} :  ${getIt<DataBaseService>().db.keys.toList()[index].split(":")[0]}",
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Alert(
                        context: context,
                        type: AlertType.error,
                        title: "Delete this user ?",
                        desc: "are you sure ",
                        buttons: [
                          DialogButton(
                            color: Colors.red,
                            child: Text(
                              "Delete",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              getIt<DataBaseService>().deleteUser(
                                  key: getIt<DataBaseService>()
                                      .db
                                      .keys
                                      .toList()[index]);

                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            width: 120,
                          ),
                          DialogButton(
                            color: Colors.green,
                            child: Text(
                              "no",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            width: 120,
                          )
                        ],
                      ).show();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
