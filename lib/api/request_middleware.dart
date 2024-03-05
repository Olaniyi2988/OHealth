import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kp/globals.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RequestMiddleWare {
  static Future<http.Response> makeRequest(
      {RequestMethod method = RequestMethod.GET,
      String url,
      String body,
      Map<String, String> headers,
      BuildContext context}) async {
    if (context == null) {
      context = globalBuildContext;
    }
    if (Provider.of<AuthProvider>(context, listen: false).authToken == null) {
      Provider.of<AuthProvider>(context, listen: false).logout();
      return http.Response("", 403);
    }
    if (headers == null) {
      headers = {
        "Authorization":
            "Bearer ${Provider.of<AuthProvider>(context, listen: false).authToken}"
      };
    } else {
      headers.putIfAbsent(
          "Authorization",
          () =>
              "Bearer ${Provider.of<AuthProvider>(context, listen: false).authToken}");
    }

    try {
      if (method == RequestMethod.GET) {
        http.Response response = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(Duration(minutes: 1));
        if (response.statusCode == 403) {
          //log user out here because token is expired
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
        return response;
      } else if (method == RequestMethod.POST) {
        http.Response response = await http
            .post(Uri.parse(url), body: body, headers: headers)
            .timeout(Duration(minutes: 1));
        if (response.statusCode == 403) {
          //log user out here because token is expired
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
        print(response.body);
        return response;
      } else if (method == RequestMethod.DELETE) {
        http.Response response = await http
            .delete(Uri.parse(url), body: body, headers: headers)
            .timeout(Duration(minutes: 1));
        if (response.statusCode == 403) {
          //log user out here because token is expired
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
        print(response.body);
        return response;
      } else {
        return null;
      }
    } on TimeoutException catch (err) {
      print(err);
      throw ("Request timeout");
    }
  }
}

enum RequestMethod { GET, POST, DELETE }
