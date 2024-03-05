import 'package:flutter/cupertino.dart';
import 'package:kp/models/client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class ClientsDB {
  static Database _db;
  static ClientsDB _instance;

  ClientsDB._();

  Database getDB() {
    return _db;
  }

  static ClientsDB getInstance() {
    if (_instance == null) {
      _instance = ClientsDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/clients.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> addClient(Client clientIntake, BuildContext context) async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      await _db.transaction((transaction) async {
        await store.add(transaction, clientIntake.toDBJson(context));
      });
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<Client> updateClient(String dbIdentifier, Map<String, dynamic> data,
      BuildContext context) async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db,
              finder:
                  Finder(filter: Filter.equals('db_identifier', dbIdentifier)));
      Client updatedClient =
          Client.fromDBJson(await clients.last.ref.update(_db, data));
      return updatedClient;
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<bool> deleteClient(String dbIdentifier) async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db,
              finder:
                  Finder(filter: Filter.equals('db_identifier', dbIdentifier)));
      clients.last.ref.delete(_db);
      return true;
    } catch (e) {
      print(e);
      throw ('Error saving');
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

  Future<List<Client>> getAllClients() async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db, finder: Finder());
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
      getAllClientsSnapshot() async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      var query = store.query(finder: Finder());
      return query.onSnapshots(_db);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Client>> searchClient(String query) async {
    try {
      await init();
      var store = intMapStoreFactory.store('clients');
      List<RecordSnapshot<int, Map<String, dynamic>>> clients =
          await store.find(_db, finder: Finder());
      List<Client> temp = [];
      clients.forEach((recordSnap) {
        print(recordSnap.value);
        temp.add(Client.fromDBJson(recordSnap.value));
      });

      List<Client> matchedClients = [];
      temp.forEach((client) {
        if (client.firstName
            .toLowerCase()
            .contains(query.trim().toLowerCase())) {
          matchedClients.add(client);
          return;
        }

        if (client.surname.toLowerCase().contains(query.toLowerCase())) {
          matchedClients.add(client);
          return;
        }

        if (client.phone.toLowerCase().contains(query.toLowerCase())) {
          matchedClients.add(client);
          return;
        }
      });
      return matchedClients;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
