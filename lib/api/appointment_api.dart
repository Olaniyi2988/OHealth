import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/appointment.dart';

class AppointmentApi {
  static Future<bool> postClinicalAppointment(
      Map<String, dynamic> payload) async {
    try {
      String url = endPointBaseUrl + '/postclinicalappointment';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url,
          method: RequestMethod.POST,
          body: JsonEncoder().convert(payload));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.body);
        throw ('Error making appointment');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<bool> cancelClinicalAppointment(
      Map<String, dynamic> payload) async {
    try {
      String url = endPointBaseUrl + '/postclinicalappointmentcancellation';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url,
          method: RequestMethod.POST,
          body: JsonEncoder().convert(payload));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(response.body);
        throw ('Error cancelling appointment');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<ClientAppointment>> getAppointments(
      int serviceProviderId) async {
    try {
      String url = endPointBaseUrl +
          '/listclinicalappointment?serviceProviderId=$serviceProviderId';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List jsons = JsonDecoder().convert(response.body);
        List<ClientAppointment> appointments = [];

        jsons.forEach((element) {
          appointments.add(ClientAppointment.fromJson(element));
        });

        return appointments;
      } else {
        print(response.body);
        throw ('Error fetching appointment');
      }
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }
}
