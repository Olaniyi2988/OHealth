import 'dart:convert';

import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/dispensepattern.dart';
import 'package:kp/models/medication_line.dart';
import 'package:http/http.dart' as http;
import 'package:kp/models/prescription.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/arv.dart';
import 'package:provider/provider.dart';

class PharmacyApi {
  static Future<List<Prescription>> listDrugPrescriptions(
      String hospitalNumber) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listclinicaldrugprescription?client_unique_identifier=$hospitalNumber");
      print(response.body);
      if (response.statusCode == 200) {
        List prescriptionsJson = JsonDecoder().convert(response.body);
        List<Prescription> prescriptions = prescriptionsJson.map((json) {
          return Prescription.fromJson(json);
        }).toList();
        return prescriptions;
      } else {
        print(response.body);
        throw "Error fetching";
      }
    } catch (e) {
      print(e);
      throw "Error fetching";
    }
  }

  static Future<List<MedicationLine>> listMedicationLine() async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl + "/listmedicationline");
      if (response.statusCode == 200) {
        List<MedicationLine> medLine = [];
        JsonDecoder().convert(response.body).forEach((e) {
          medLine.add(MedicationLine.fromJson(e));
        });
        return medLine;
      } else {
        print(response.body);
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<ArvPayload>> listArvDrugDispense(
      String hospitalNumber) async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl +
              "/listarvdrugdispensebyclient?client_unique_identifier=$hospitalNumber");
      if (response.statusCode == 200) {
        List allDispense = JsonDecoder().convert(response.body);
        List<ArvPayload> payloads = [];
        allDispense.forEach((element) {
          MedicationLine medicationLine;
          Regimen regimen;
          DispensePattern dispensePattern;
          DateTime nextAppointmentDate;
          DateTime pickupDate;

          medicationLine = MedicationLine.fromJson(
              element['regimencombo']['medicationline']);
          regimen = Regimen.fromJson(element['regimencombo']);
          dispensePattern =
              DispensePattern.fromJson(element['drugdispensepattern']);
          nextAppointmentDate =
              convertStringToDateTime(element['arv_next_appointment_date']);
          pickupDate = convertStringToDateTime(element['arv_dispense_date']);

          payloads.add(ArvPayload(
              medicationLine: medicationLine,
              regimen: regimen,
              dispensePattern: dispensePattern,
              nextAppointmentDate: nextAppointmentDate,
              pickupDate: pickupDate));
        });
        return payloads;
      } else {
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<List<DispensePattern>> listDispensePatterns() async {
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.GET,
          url: endPointBaseUrl + "/listdrugdispensepattern");
      if (response.statusCode == 200) {
        List<DispensePattern> patterns = [];
        JsonDecoder().convert(response.body).forEach((e) {
          patterns.add(DispensePattern.fromJson(e));
        });
        return patterns;
      } else {
        print(response.body);
        throw "Error fetching";
      }
    } catch (_) {
      throw "Error fetching";
    }
  }

  static Future<bool> postArvDispense(
      List<ArvPayload> payloads, String clientIdentifier, context) async {
    try {
      List<Map<String, dynamic>> jsonPayloads = [];
      payloads.forEach((element) {
        jsonPayloads.add({
          "next_arv_pick_up_date":
              element.nextAppointmentDate.toIso8601String(),
          "created_by": Provider.of<AuthProvider>(context, listen: false)
              .serviceProvider
              .userId,
          "created_date": DateTime.now().toIso8601String(),
          "client_unique_identifier": clientIdentifier,
          "arv_dispense_date": element.pickupDate.toIso8601String(),
          "medicationline": element.medicationLine.name,
          "regimen": element.regimen.name,
          "regimencombo_id": element.regimen.id,
          "dosage": element.dispensePattern.name,
          "dosage_duration_id": element.dispensePattern.id,
          "arv_next_appointment_date":
              element.nextAppointmentDate.toIso8601String()
        });
      });
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: endPointBaseUrl + "/postarvdrugdispense",
          headers: {"Content-Type": "application/json"},
          body: JsonEncoder().convert(jsonPayloads));
      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        print(response.statusCode);
        throw "Error saving";
      }
    } catch (e) {
      print(e.toString());
      print(e);
      throw "Error saving";
    }
  }
}
