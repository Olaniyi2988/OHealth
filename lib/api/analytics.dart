import 'dart:convert';
import 'dart:io';

import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/programs.dart';
import 'package:http/http.dart' as http;

class AnalyticsApi {
  static Future<List<Program>> getProgramsAnalytics() async {
    try {
      String url = endPointBaseUrl + "/listprograms";
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        print(response.body);
        print(response.statusCode);
        List programsJsons = JsonDecoder().convert(response.body);
        List<Program> programs = [];
        programsJsons.forEach((json) {
          programs.add(Program.fromJson(json));
        });

        List<ClinicalClientProgram> clientPrograms =
            await listClinicalClientProgram();
        programs.forEach((program) {
          clientPrograms.forEach((clientProgram) {
            if (program.code == clientProgram.program.code) {
              program.enrolled++;
            }
          });
        });
        return programs;
      }
      throw ('Error getting programs');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<ClinicalClientProgram>> listClinicalClientProgram() async {
    try {
      String url = endPointBaseUrl + "/listclinicalclientprograms";
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        List programsJsons = JsonDecoder().convert(response.body);
        List<ClinicalClientProgram> programs = [];
        programsJsons.forEach((json) {
          programs.add(ClinicalClientProgram.fromJson(json));
        });
        return programs;
      }
      throw ('Error getting programs');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }
}
