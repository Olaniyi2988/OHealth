import 'package:flutter/cupertino.dart';
import 'package:kp/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AuthDB {
  static Database _db;
  static AuthDB _instance;

  AuthDB._();

  Database getDB() {
    return _db;
  }

  static AuthDB getInstance() {
    if (_instance == null) {
      _instance = AuthDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/auth2.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> addUser(User user) async {
    try {
      await init();
      var store = intMapStoreFactory.store('users');

      List<RecordSnapshot<int, Map<String, dynamic>>> users =
          await store.find(_db, finder: Finder());

      for (var x = 0; x < users.length; x++) {
        await users[x].ref.delete(_db);
      }

      await _db.transaction((transaction) async {
        await store.add(transaction, user.toJson());
      });
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<User> updateUser(
      String username, Map<String, dynamic> data, BuildContext context) async {
    try {
      await init();
      var store = intMapStoreFactory.store('users');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db,
              finder: Finder(filter: Filter.equals('username', username)));
      User updatedClient =
          User.fromDBJson(await clients.last.ref.update(_db, data));
      return updatedClient;
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<bool> deleteUser(String username) async {
    try {
      await init();
      var store = intMapStoreFactory.store('users');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db,
              finder: Finder(filter: Filter.equals('username', username)));
      clients.last.ref.delete(_db);
      return true;
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<User> getLoggedInUser() async {
    try {
      await init();
      var store = intMapStoreFactory.store('users');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db, finder: Finder());
      if (clients.length == 0) {
        return null;
      }
      return User.fromDBJson(clients.first.value);
    } catch (e) {
      return null;
    }
  }
}
