// import 'package:kp/models/user.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sembast/sembast.dart';
// import 'package:sembast/sembast_io.dart';
//
// class AuthDB {
//   static Database _db;
//   static AuthDB _instance;
//
//   AuthDB._();
//
//   Database getDB() {
//     return _db;
//   }
//
//   static AuthDB getInstance() {
//     if (_instance == null) {
//       _instance = AuthDB._();
//     }
//     return _instance;
//   }
//
//   Future<void> init() async {
//     if (_db == null) {
//       var dir = await getApplicationDocumentsDirectory();
//       String dbPath = dir.path + '/auth.db';
//       DatabaseFactory dbFactory = databaseFactoryIo;
//       _db = await dbFactory.openDatabase(dbPath);
//     }
//   }
//
//   Future<void> saveUser({User user}) async {
//     try {
//       await init();
//       var store = StoreRef.main();
//       await store.record('userid').put(_db, user.userId);
//       await store.record('user_type_id').put(_db, user.userTypeId);
//       await store.record('username').put(_db, user.username);
//       await store.record('password').put(_db, user.password);
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }
//
//   Future<void> saveAuthToken({String token}) async {
//     try {
//       await init();
//       var store = StoreRef.main();
//       await store.record('authToken').put(_db, token);
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }
//
//   Future<String> getAuthToken() async {
//     try {
//       await init();
//       var store = StoreRef.main();
//       var authToken = await store.record('authToken').get(_db) as String;
//       return authToken;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }
//
//   Future<bool> deleteAuthToken() async {
//     try {
//       await init();
//       var store = StoreRef.main();
//       await store.record('authToken').delete(_db);
//       return true;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }
//
//   Future<User> getSavedUser() async {
//     try {
//       await init();
//       var store = StoreRef.main();
//       var userId = await store.record('userid').get(_db) as int;
//       var userTypeId = await store.record('user_type_id').get(_db) as int;
//       var userName = await store.record('username').get(_db) as String;
//       var password = await store.record('password').get(_db) as String;
//       return User(
//           userId: userId,
//           userTypeId: userTypeId,
//           username: userName == null ? "" : userName,
//           password: password == null ? "" : password);
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }
//
//   Future<bool> deleteSavedUser() async {
//     try {
//       await init();
//       var store = StoreRef.main();
//       await store.record('userid').delete(_db);
//       await store.record('user_type_id').delete(_db);
//       await store.record('username').delete(_db);
//       await store.record('password').delete(_db);
//       return true;
//     } catch (e) {
//       print(e);
//       return false;
//     }
//   }
// }
