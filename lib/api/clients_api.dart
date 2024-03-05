import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kp/api/request_middleware.dart';
import 'package:kp/db/clients.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/biometrics.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ClientApi {
  static Future<bool> postClinicalRegistration(
      Client client, BuildContext context) async {
    try {
      String url = endPointBaseUrl + '/postclinicalregistration';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url,
          method: RequestMethod.POST,
          body: JsonEncoder().convert([
            client.isRegisteredOnline == true
                ? client.toJsonUpdate(context)
                : client.toJson(context)
          ]),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        print(data);
        if (client.isRegisteredOnline == false) {
          ClientsDB.getInstance().deleteClient(client.localDBIdentifier);
        }
        return true;
      }
      throw ('Error saving data');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<Client>> listClinicalRegistration(int days) async {
    try {
      String url = endPointBaseUrl +
          "/listclinicalregistrationsbydays?periodInDays=$days";
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List clientJsons = JsonDecoder().convert(response.body);
        List<Client> clients = clientJsons.map((json) {
          return Client.formServerJson(json);
        }).toList();
        return clients;
      }
      throw ('Error getting clients');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<Client>> listClinicalRegistrationByHospitalNum(
      String hospitalNumber) async {
    try {
      String url = endPointBaseUrl +
          "/listclinicalregistrationsbyhospitalnum?hospitalNum=$hospitalNumber";
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List clientJsons = JsonDecoder().convert(response.body);
        List<Client> clients = [];
        clientJsons.forEach((element) {
          clients.add(Client.formServerJson(element));
        });
        return clients;
      } else if (response.statusCode == 404) {
        throw ('Client not found');
      }
      throw ('Error getting clients');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<bool> uploadBiometrics(Biometrics biometrics,
      String hospitalNumber, BuildContext context) async {
    try {
      bool matchExists =
          await verifyBiometrics(biometrics.filePath, hospitalNumber, context);
      if (matchExists) {
        throw ("The biometrics provided is linked to another client");
      }
      String url = endPointBaseUrl +
          "/postclientenrollment?client_unique_identifier=$hospitalNumber";
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(
            await http.MultipartFile.fromPath('file', biometrics.filePath));
      request.headers['Authorization'] =
          "Bearer ${Provider.of<AuthProvider>(context, listen: false).authToken}";
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      throw ('Error uploading biometrics');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<bool> verifyBiometrics(
      String filePath, String hospitalNumber, BuildContext context) async {
    try {
      String url =
          endPointBaseUrl + "/verifyclinicalregistrationbyclientsubjectid";
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers['Authorization'] =
          "Bearer ${Provider.of<AuthProvider>(context, listen: false).authToken}";
      var response = await request.send();
      response.stream.bytesToString().then((value) {
        print(value);
      });
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(true);
        return true;
      }

      return false;
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<void> postClinicalRegistrationBulk(
      List<Client> clients, BuildContext context) async {
    print(JsonEncoder().convert(clients.map((e) {
      return e.toJson(context);
    }).toList()));
    try {
      String url = endPointBaseUrl + '/postclinicalregistration';
      http.Response response = await RequestMiddleWare.makeRequest(
          method: RequestMethod.POST,
          url: url,
          body: JsonEncoder().convert(clients.map((e) {
            return e.toJson(context);
          }).toList()),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        List data = JsonDecoder().convert(response.body);
        for (var x = 0; x < clients.length; x++) {
          Map json;
          data.forEach((element) {
            if (clients[x].hospitalNum == element['hospitalNum']) {
              json = element;
            }
          });

          if (json != null) {
            //upload biometrics here
            ClientsDB.getInstance().updateClient(clients[x].localDBIdentifier,
                {'is_registered_online': true}, context);

            try {
              if (clients[x].biometrics != null) {
                await uploadBiometrics(
                    clients[x].biometrics, clients[x].hospitalNum, context);
              }
              await ClientsDB.getInstance()
                  .deleteClient(clients[x].localDBIdentifier);
            } catch (err) {
              ClientsDB.getInstance().updateClient(clients[x].localDBIdentifier,
                  {'biometrics_upload_failed': true}, context);
            }
          }
        }
        return;
      }
      print(response.body);
      print(response.statusCode);
      throw ("Error registering clients");
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }
}
