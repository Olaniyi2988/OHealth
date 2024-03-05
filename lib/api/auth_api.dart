import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kp/globals.dart';
import 'package:kp/models/user.dart';

class AuthApi {
  static Future<User> login(String username, String password) async {
    try {
      String url = endPointBaseUrl + '/authenticate';
      http.Response response = await http.post(Uri.parse(url),
          body: JsonEncoder()
              .convert({'username': username, 'password': password}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 15));
      print(response.body);
      if (response.statusCode == 200) {
        Map data = JsonDecoder().convert(response.body);
        print(data);

        if (data['user']['username'] == null ||
            data['user']['userid'] == null) {
          throw ('Error signing you in');
        }

        if (data['user']['loginstatus'] == false) {
          throw ('This user is unauthorized');
        }
        return User.fromJson(data['user'], data['token']);
      }
      throw ("Username or password incorrect");
    } on SocketException catch (err) {
      print(err);
      throw ('Connection Error');
    } on TimeoutException catch (err) {
      print(err);
      throw ('Request Timeout');
    }
  }
}

class LoginResponse {
  User user;
  String authToken;

  LoginResponse({this.authToken, this.user});
}

class KpAuthException implements Exception {
  String cause;
  KpAuthException(this.cause);

  @override
  String toString() {
    return cause;
  }
}
