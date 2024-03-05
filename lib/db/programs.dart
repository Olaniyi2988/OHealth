import 'package:kp/models/programs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class ProgramsDB {
  static Database _db;
  static ProgramsDB _instance;

  ProgramsDB._();

  Database getDB() {
    return _db;
  }

  static ProgramsDB getInstance() {
    if (_instance == null) {
      _instance = ProgramsDB._();
    }
    return _instance;
  }

  Future<void> init() async {
    if (_db == null) {
      var dir = await getApplicationDocumentsDirectory();
      String dbPath = dir.path + '/programs.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<void> savePrograms(List programsJson) async {
    try {
      await init();
      var store = StoreRef.main();
      await store.record('programs').put(_db, programsJson);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> saveDynamicColumns(Map columns, String formName) async {
    try {
      await init();
      var store = StoreRef.main();
      await store.record(formName).put(_db, columns);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> getDynamicColumns(String formName) async {
    try {
      await init();
      var store = StoreRef.main();
      var columns = await store.record(formName).get(_db) as Map;
      return columns;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> getPrograms() async {
    try {
      await init();
      var store = StoreRef.main();
      var programs = await store.record('programs').get(_db) as List;
      return programs;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<ProgramStage> getProgramStage(int programId, String formName) async {
    List programs = await getPrograms();
    Map selectedProgram;
    Map selectedStage;
    if (programs != null) {
      programs.forEach((element) {
        if (element['program_id'] == programId) {
          selectedProgram = element;
        }
      });

      if (selectedProgram != null) {
        selectedProgram['programstages'].forEach((element) {
          if (element['form_stage_db_identifier'] == formName) {
            selectedStage = element;
          }
        });
      }
    }

    if (selectedStage != null) {
      return ProgramStage.fromJson(selectedStage);
    }

    return null;
  }
}
