import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SearchHistoryDB {
  static Database _db;
  static SearchHistoryDB _instance;

  SearchHistoryDB._();

  Database getDB() {
    return _db;
  }

  static SearchHistoryDB getInstance() {
    if (_instance == null) {
      _instance = SearchHistoryDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/search_history.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> addHistory(String historyText, BuildContext context) async {
    try {
      await init();
      var store = intMapStoreFactory.store('history');
      await _db.transaction((transaction) async {
        await store.add(transaction,
            {"value": historyText, "date": DateTime.now().toIso8601String()});
      });
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<bool> deleteHistory(
      RecordSnapshot<int, Map<String, dynamic>> snapshot) async {
    try {
      await init();
      snapshot.ref.delete(_db);
      return true;
    } catch (e) {
      print(e);
      throw ('Error deleting');
    }
  }

  Future<Stream<List<RecordSnapshot<int, Map<String, dynamic>>>>>
      getAllHistorySnapshot() async {
    try {
      await init();
      var store = intMapStoreFactory.store('history');
      var query = store.query(finder: Finder());
      return query.onSnapshots(_db);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
