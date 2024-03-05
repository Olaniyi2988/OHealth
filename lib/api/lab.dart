import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:http/http.dart' as http;
import 'package:kp/models/lab.dart';
import 'package:kp/models/lab_order.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:provider/provider.dart';

class LabApi {
  static Future<bool> postClinicalLabTests(
      Map<String, dynamic> payload, BuildContext context) async {
    print(payload);
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: endPointBaseUrl + "/postclinicallabtests",
          headers: {"Content-Type": "application/json"},
          body: JsonEncoder().convert([payload]));
      if (response.statusCode == 200) {
        return true;
      } else {
        throw "Error saving";
      }
    } catch (e) {
      print(e);
      throw "Error saving";
    }
  }

  static Future<List<LaboratoryOrder>> listTests(BuildContext context) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listtestsordered?userId=${Provider.of<AuthProvider>(context, listen: false).serviceProvider.userId}");
      if (response.statusCode == 200) {
        print(response.body);
        List clientJsons = JsonDecoder().convert(response.body);
        List<LabTest> labTests =
            Provider.of<MetadataProvider>(context, listen: false).tests;
        List<LaboratoryOrder> tests = clientJsons.map((json) {
          LaboratoryOrder order = LaboratoryOrder.fromJson(json);
          if (labTests != null) {
            labTests.forEach((element) {
              if (element.labTestId == order.testId) {
                order.test = element;
              }
            });
          }
          return order;
        }).toList();
        return tests;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<LaboratoryOrder>> listTestsByHospitalNumber(
      String hospitalNumber, BuildContext context) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicallabtests?client_unique_identifier=$hospitalNumber");
      if (response.statusCode == 200) {
        print(response.body);
        List clientJsons = JsonDecoder().convert(response.body);
        List<LabTest> labTests =
            Provider.of<MetadataProvider>(context, listen: false).tests;
        List<LaboratoryOrder> tests = clientJsons.map((json) {
          LaboratoryOrder order = LaboratoryOrder.fromJson(json);
          if (labTests != null) {
            labTests.forEach((element) {
              if (element.labTestId == order.testId) {
                order.test = element;
              }
            });
          }
          return order;
        }).toList();
        return tests;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }
}
