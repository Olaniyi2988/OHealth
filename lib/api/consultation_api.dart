import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/allergy.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/diagnosis.dart';

class ConsultationApi {
  static Future<List<Diagnosis>> lisDiagnosis(String hospitalNumber) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicaldiagnosis?client_unique_identifier=$hospitalNumber");
      print(response.body);
      if (response.statusCode == 200) {
        List vitalsJsons = JsonDecoder().convert(response.body);
        List<Diagnosis> diagnosis = vitalsJsons.map((json) {
          return Diagnosis.fromJson(json);
        }).toList();
        return diagnosis;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<Allergy>> listAllergies(String hospitalNumber) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicalallergies?client_unique_identifier=$hospitalNumber");
      print(response.body);
      if (response.statusCode == 200) {
        List allergiesJson = JsonDecoder().convert(response.body);
        List<Allergy> allergies = allergiesJson.map((json) {
          return Allergy.fromJson(json);
        }).toList();
        return allergies;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<bool> postClinicalDiagnosis(
      Client client, Map<String, dynamic> data) async {
    print(data);
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: endPointBaseUrl + "/postclinicaldiagnosis",
          body: JsonEncoder().convert([data]),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var data = JsonDecoder().convert(response.body);
        print(data);
        return true;
      } else {
        print(response.body);
        throw ('Error saving data');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<bool> postClinicalVitals(
      Client client, Map<String, dynamic> data) async {
    print(data);
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          url: endPointBaseUrl + "/postclinicalvitalsigns",
          body: JsonEncoder().convert(data),
          headers: {'Content-Type': 'application/json'},
          method: RequestMethod.POST);
      if (response.statusCode == 200) {
        var data = JsonDecoder().convert(response.body);
        print(data);
        return true;
      } else {
        print(response.body);
        throw ('Error saving data');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<bool> postClinicalAllergies(
      Client client, Map<String, dynamic> data) async {
    print(data);
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          url: endPointBaseUrl + "/postclinicalallergies",
          body: JsonEncoder().convert(data),
          headers: {'Content-Type': 'application/json'},
          method: RequestMethod.POST);
      if (response.statusCode == 200) {
        var data = JsonDecoder().convert(response.body);
        print(data);
        return true;
      } else {
        print(response.body);
        throw ('Error saving data');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }
}
