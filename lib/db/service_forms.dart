import 'package:flutter/cupertino.dart';
import 'package:kp/models/client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class ServiceFormsDB {
  static Database _db;
  static ServiceFormsDB _instance;

  ServiceFormsDB._();

  Database getDB() {
    return _db;
  }

  static ServiceFormsDB getInstance() {
    if (_instance == null) {
      _instance = ServiceFormsDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/service_forms.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> saveFormData(Map data) async {
    try {
      await init();
      var store = intMapStoreFactory.store('forms');
      await _db.transaction((transaction) async {
        await store.add(transaction, data);
      });
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  // Future<ClientIntake> updateClient(String clientCode,
  //     Map<String, dynamic> data, BuildContext context) async {
  //   try {
  //     await init();
  //     var store = intMapStoreFactory.store('clients');
  //     List<RecordSnapshot<int, Map<String, dynamic>>> clients =
  //         await store.find(_db,
  //             finder: Finder(filter: Filter.equals('client_code', clientCode)));
  //     ClientIntake updatedClient =
  //         ClientIntake.fromDBJson(await clients.last.ref.update(_db, data));
  //     return updatedClient;
  //   } catch (e) {
  //     print(e);
  //     throw ('Error saving');
  //   }
  // }

  Future<bool> deleteFormData(String formDataId) async {
    try {
      await init();
      var store = intMapStoreFactory.store('forms');
      List<RecordSnapshot<int, Map<String, dynamic>>> forms = await store.find(
          _db,
          finder: Finder(filter: Filter.equals('formDataId', formDataId)));
      forms.last.ref.delete(_db);
      return true;
    } catch (e) {
      print(e);
      throw ('Error deleting');
    }
  }

  Future<RecordSnapshot<int, Map<String, dynamic>>> getClientSnapshot(
      String clientCode, BuildContext context) async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db,
              finder: Finder(filter: Filter.equals('client_code', clientCode)));
      return clients.last;
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  // Future<List<ClientIntake>> getAllSavedForms() async {
  //   try {
  //     await init();
  //     var store = intMapStoreFactory.store('forms');
  //     List<RecordSnapshot<int, Map<String, dynamic>>> clients =
  //         await store.find(_db, finder: Finder());
  //     List<ClientIntake> temp = [];
  //     clients.forEach((recordSnap) {
  //       print(recordSnap.value);
  //       temp.add(ClientIntake.fromDBJson(recordSnap.value));
  //     });
  //     return temp;
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  Future<List<Client>> getClients(Finder query) async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db, finder: query);
      List<Client> temp = [];
      clients.forEach((recordSnap) {
        print(recordSnap.value);
        temp.add(Client.fromDBJson(recordSnap.value));
      });
      return temp;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Stream<List<RecordSnapshot<int, Map<String, dynamic>>>>>
      getAllFormsSnapshot() async {
    try {
      await init();
      var store = intMapStoreFactory.store('forms');
      var query = store.query(finder: Finder());
      return query.onSnapshots(_db);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
