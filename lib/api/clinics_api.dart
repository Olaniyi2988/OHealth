import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/clinical_service.dart';
import 'package:kp/models/clinical_stage.dart';
import 'package:http/http.dart' as http;
import 'package:kp/models/health_status.dart';
import 'package:kp/models/pregnancy_status.dart';
import 'package:kp/models/vitals.dart';
import 'package:kp/views/clinics_home.dart';

class ClinicsAPi {
  static Future<List<Vitals>> getVitals(String hospitalNumber) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicalvitalsigns?client_unique_identifier=$hospitalNumber");
      if (response.statusCode == 200) {
        List vitalsJsons = JsonDecoder().convert(response.body);
        List<Vitals> vitals = vitalsJsons.map((json) {
          return Vitals.fromJson(json);
        }).toList();
        return vitals;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<ClinicalStage>> listClinicalStages() async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl + "/listclinicalstages");
      if (response.statusCode == 200) {
        List<ClinicalStage> stages = [];
        JsonDecoder().convert(response.body).forEach((e) {
          stages.add(ClinicalStage.fromJson(e));
        });
        return stages;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<ClinicalService>> listClinicalServices() async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl + "/listclinicalservices");
      if (response.statusCode == 200) {
        List<ClinicalService> services = [];
        JsonDecoder().convert(response.body).forEach((e) {
          services.add(ClinicalService.fromJson(e));
        });

        print("fetch ${services.length}");

        Map<String, ClinicalService> groups = {};

        for (var x = 0; x < services.length; x++) {
          var element = services[x];
          if (groups[element.clientUniqueIdentifier] == null) {
            groups[element.clientUniqueIdentifier] = element;
            groups[element.clientUniqueIdentifier].visitHistory.add(element);
          } else {
            groups[element.clientUniqueIdentifier].visitHistory.add(element);
          }
        }

        return groups.values.toList();
      } else {
        throw "Error fetching";
      }
    } catch (err) {
      print(err);
      throw "Error fetching";
    }
  }

  static Future<List<ClinicalService>> listClinicalServicesByHospitalNumber(
      String hospitalNumber) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicalservicesbyclient?client_unique_identifier=$hospitalNumber");
      print(response.body);
      if (response.statusCode == 200) {
        List<ClinicalService> services = [];
        JsonDecoder().convert(response.body).forEach((e) {
          services.add(ClinicalService.fromJson(e));
        });

        return services;
      } else {
        throw "Error fetching";
      }
    } catch (err) {
      print(err);
      throw "Error fetching";
    }
  }

  static Future<List<ClinicalService>> listClinicalServicesByPeriod(
      int days) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicalservicesbyperiod?periodInDays=$days");
      print(response.body);
      if (response.statusCode == 200) {
        List<ClinicalService> services = [];
        JsonDecoder().convert(response.body).forEach((e) {
          services.add(ClinicalService.fromJson(e));
        });

        print("fetch ${services.length}");

        Map<String, ClinicalService> groups = {};

        for (var x = 0; x < services.length; x++) {
          var element = services[x];
          if (groups[element.clientUniqueIdentifier] == null) {
            groups[element.clientUniqueIdentifier] = element;
            groups[element.clientUniqueIdentifier].visitHistory.add(element);
          } else {
            groups[element.clientUniqueIdentifier].visitHistory.add(element);
          }
        }

        return groups.values.toList();
      } else {
        throw "Error fetching";
      }
    } catch (err) {
      print(err);
      throw "Error fetching";
    }
  }

  static Future<bool> postClinicalService(
      ClinicVisitPayload payload, BuildContext context) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: endPointBaseUrl + "/postclinicalservices",
          headers: {"Content-Type": "application/json"},
          body: JsonEncoder().convert([payload.toJson(context)]));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw "Error saving";
      }
    } catch (_) {
      throw "Error saving";
    }
  }

  static Future<List<PregnancyStatus>> listPregnancyStatus() async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET, url: endPointBaseUrl + "/listpregnancy");
      if (response.statusCode == 200) {
        List<PregnancyStatus> status = [];
        JsonDecoder().convert(response.body).forEach((e) {
          status.add(PregnancyStatus.fromJson(e));
        });
        return status;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<HealthStatus>> listHealthStatus() async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl + "/listhealthstatus");
      if (response.statusCode == 200) {
        List<HealthStatus> status = [];
        JsonDecoder().convert(response.body).forEach((e) {
          status.add(HealthStatus.fromJson(e));
        });
        return status;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }
}
