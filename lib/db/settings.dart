import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SettingsDB {
  static Database _db;
  static SettingsDB _instance;

  SettingsDB._();

  Database getDB() {
    return _db;
  }

  static SettingsDB getInstance() {
    if (_instance == null) {
      _instance = SettingsDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/settings.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> saveTimeout(Duration duration) async {
    try {
      await init();
      var store = StoreRef.main();
      await store.record('timeout').put(_db, duration.inSeconds);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> saveFingerprint(bool val) async {
    try {
      await init();
      var store = StoreRef.main();
      await store.record('fingerprint').put(_db, val);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Duration> getTimeout() async {
    try {
      await init();
      var store = StoreRef.main();
      var seconds = await store.record('timeout').get(_db) as int;
      return Duration(seconds: seconds);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> getFingerprint() async {
    try {
      await init();
      var store = StoreRef.main();
      var print = await store.record('fingerprint').get(_db) as bool;
      return print;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
