import 'package:kp/models/country.dart';
import 'package:kp/models/heirachy_unit.dart';
import 'package:kp/models/lab.dart';
import 'package:kp/models/metadata.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class MetaDB {
  Database _db;
  static MetaDB _instance;

  MetaDB._();

  static MetaDB getInstance() {
    if (_instance == null) {
      _instance = MetaDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/metadata.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> addMetadata(String name, List<KpMetaData> metadata) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = metadata.map((e) {
        return e.toJson();
      }).toList();
      store.record(name).put(_db, temp);
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<void> addCountries(String name, List<Country> countries) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = countries.map((e) {
        return e.toJson();
      }).toList();
      store.record(name).put(_db, temp);
    } catch (e) {
      print(e);
      throw ('Error saving');
    }
  }

  Future<void> addHierarchyUnits(String name, List<HierarchyUnit> units) async {
    try {
      await init();
      var store = StoreRef.main();
      List<Map<String, dynamic>> temp = units.map((e) {
        return e.toJson();
      }).toList();
      store.record(name).put(_db, temp);
    } catch (e) {
      print(e.toString() + "??????????????????????????????????????");
      throw ('Error saving');
    }
  }

  Future<void> addLabTestTypes(String name, List<LabTestType> units) async {
    try {
      await init();
      var store = StoreRef.main();
      List<Map<String, dynamic>> temp = units.map((e) {
        return e.toJson();
      }).toList();
      store.record(name).put(_db, temp);
    } catch (e) {
      print(e.toString() + "??????????????????????????????????????");
      throw ('Error saving');
    }
  }

  Future<void> addLabTests(String name, List<LabTest> units) async {
    try {
      await init();
      var store = StoreRef.main();
      List<Map<String, dynamic>> temp = units.map((e) {
        return e.toJson();
      }).toList();
      store.record(name).put(_db, temp);
    } catch (e) {
      print(e.toString() + "??????????????????????????????????????");
      throw ('Error saving');
    }
  }

  Future<List<LabTestType>> getLabTestTypes(String name) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = await store.record(name).get(_db);
      if (temp == null) {
        return <LabTestType>[];
      }
      return temp.map((e) {
        return LabTestType.formJson(e);
      }).toList();
    } catch (e) {
      print(e);
      return <LabTestType>[];
    }
  }

  Future<List<LabTest>> getLabTests(String name) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = await store.record(name).get(_db);
      if (temp == null) {
        return <LabTest>[];
      }
      return temp.map((e) {
        return LabTest.formJson(e);
      }).toList();
    } catch (e) {
      print(e);
      return <LabTest>[];
    }
  }

  Future<List<KpMetaData>> getMetadata(String name) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = await store.record(name).get(_db);
      if (temp == null) {
        return <KpMetaData>[];
      }
      return temp.map((e) {
        return KpMetaData.fromJsonOnly(e);
      }).toList();
    } catch (e) {
      print(e);
      return <KpMetaData>[];
    }
  }

  Future<List<Country>> getCountries(String name) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = await store.record(name).get(_db);
      if (temp == null) {
        return <Country>[];
      }
      return temp.map((e) {
        return Country.fromJson(e);
      }).toList();
    } catch (e) {
      print(e);
      return <Country>[];
    }
  }

  Future<List<HierarchyUnit>> getHierarchyUnits(String name) async {
    try {
      await init();
      var store = StoreRef.main();
      List temp = await store.record(name).get(_db);
      if (temp == null) {
        return <HierarchyUnit>[];
      }
      return temp.map((e) {
        return HierarchyUnit.fromJson(e);
      }).toList();
    } catch (e) {
      print(e);
      return <HierarchyUnit>[];
    }
  }
}
