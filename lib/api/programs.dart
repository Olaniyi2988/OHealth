import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kp/api/request_middleware.dart';
import 'package:kp/db/programs.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/programs.dart';

class ProgramsApi {
  static Future<List<Program>> getProgramsHTTP() async {
    print("getting programs");
    try {
      String url = endPointBaseUrl + '/listprograms';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        ProgramsDB.getInstance().savePrograms(data);
        print(data[0]);
        List<Program> programs = data.map((prog) {
          return Program.fromJson(prog);
        }).toList();
        return programs;
      } else {
        throw ('Could not fetch forms');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<Program>> getPrograms({bool returnCache = false}) async {
    List savedPrograms = await ProgramsDB.getInstance().getPrograms();
    if (returnCache == true && savedPrograms != null) {
      getProgramsHTTP().catchError((err) {
        print(err);
      });
      return savedPrograms.map((prog) {
        return Program.fromJson(prog);
      }).toList();
    }
    List<Program> programs;
    try {
      programs = await getProgramsHTTP();
      return programs;
    } catch (err) {
      if (savedPrograms != null) {
        return savedPrograms.map((prog) {
          return Program.fromJson(prog);
        }).toList();
      } else {
        throw (err);
      }
    }
  }

  static Future<bool> insertDynamicTableData(
      Map<String, dynamic> payload) async {
    try {
      String url = endPointBaseUrl + '/insertdynamictabledata';
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: url,
          body: JsonEncoder().convert(payload),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        return true;
      } else {
        throw ("Error saving form");
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List> getDynamicData(String clientId, String formName) async {
    try {
      String url = endPointBaseUrl +
          '/listdynamicdata?clientIdentifier=$clientId&formName=$formName';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        return data;
      } else {
        throw ('Error fetching data');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<Map> listDynamicTableColumnsHTTP(String formName) async {
    print("getting columns: $formName");
    try {
      String url =
          endPointBaseUrl + '/listdynamictablecolumns?formName=$formName';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        ProgramsDB.getInstance().saveDynamicColumns(data, formName);
        return data;
      } else {
        throw ('Error fetching data');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<Map> listDynamicTableColumns(String formName,
      {bool returnCache = false}) async {
    Map savedColumns =
        await ProgramsDB.getInstance().getDynamicColumns(formName);
    if (returnCache == true && savedColumns != null) {
      listDynamicTableColumnsHTTP(formName).catchError((err) {
        print(err);
      });
      return savedColumns;
    }
    Map columns;
    try {
      columns = await listDynamicTableColumnsHTTP(formName);
      return columns;
    } catch (err) {
      if (savedColumns != null) {
        return savedColumns;
      } else {
        throw (err);
      }
    }
  }

  static Future<bool> updateDynamicData(Map<String, dynamic> payload) async {
    try {
      String url = endPointBaseUrl + '/updatedynamictabledata';
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: url,
          body: JsonEncoder().convert(payload),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        throw ('Error updating form');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<bool> removeDynamicTableData(
      Map<String, dynamic> payload) async {
    try {
      String url = endPointBaseUrl + '/removedynamictabledata';
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.DELETE,
          url: url,
          body: JsonEncoder().convert(payload),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        print(response.body);
        throw ('Error deleting form');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }
}
