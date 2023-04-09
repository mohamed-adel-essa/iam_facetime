import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:face/modals/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseService {
  // singleton boilerplate
  static final DataBaseService _cameraServiceService =
      DataBaseService._internal();

  factory DataBaseService() {
    return _cameraServiceService;
  }
  // singleton boilerplate
  DataBaseService._internal();

  /// file that stores the data on filesystem
  late File jsonFile;
  static Database? _database;
  String? _path;

  /// Data learned on memory
  Map<String, dynamic> _db = <String, dynamic>{};
  Map<String, dynamic> get db => _db;

  /// loads a simple json file.
  Future loadDB() async {
    var tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir.path + '/emb.json';
    // _database = await openDp();
    jsonFile = File(_embPath);

    if (jsonFile.existsSync()) {
      _db = json.decode(jsonFile.readAsStringSync());
    }
  }

  /// [Name]: name of the new user
  /// [Data]: Face representation for Machine Learning model
  Future saveData(String userName, String password, String imagePath,
      List modelData) async {
    log("imagePath ${imagePath}");
    UserModal userModal =
        UserModal(user: userName, password: password, imagePath: imagePath);
    //insertUser(user: userModal);
    String userAndPass = userName + ':' + password;
    _db[userAndPass] = modelData;
    jsonFile.writeAsStringSync(json.encode(_db));
  }

  /// deletes the created users
  cleanDB() async {
    _db = <String, dynamic>{};
    jsonFile.writeAsStringSync(json.encode({}));
  }

  logInByUserAndPassword(
      {required String user, required String password}) async {
    String userAndPass = user + ':' + password;

    if (_db.containsKey(userAndPass)) {
      return true;
    } else {
      return false;
    }
  }

  deleteUser({required String key}) {
    _db.remove(key);
  }
}
