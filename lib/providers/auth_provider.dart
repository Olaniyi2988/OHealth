import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:kp/api/auth_api.dart';
import 'package:kp/db/auth2.dart';
import 'package:kp/db/settings.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/user.dart';
import 'package:kp/util.dart';
import 'package:local_auth/local_auth.dart';

class AuthProvider extends ChangeNotifier {
  User serviceProvider;
  bool canCheckBiometrics;
  AuthState authState;
  bool isFetchingCredentials = true;
  Timer inactivityTimer;
  String authToken;
  Timer midTimer;
  BuildContext context;
  AuthProvider() {
    authState = AuthState.LOGGED_OUT;
    AuthDB.getInstance().getLoggedInUser().then((value) async {
      isFetchingCredentials = false;
      var localAuth = LocalAuthentication();
      canCheckBiometrics = await localAuth.canCheckBiometrics;
      if (value != null) {
        this.serviceProvider = value;
        authToken = this.serviceProvider.authToken;
      }
      notifyListeners();
    });
  }

  void logout() async {
    deleteAuthToken();
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil(ModalRoute.withName('home'));
      }
    } catch (err) {}
    serviceProvider = null;
    authState = AuthState.LOGGED_OUT;
    notifyListeners();
  }

  void deleteAuthToken() {
    authToken = null;
    AuthDB.getInstance().deleteUser(this.serviceProvider.username);
    notifyListeners();
  }

  void setContext(BuildContext context) {
    this.context = context;
    globalBuildContext = context;
  }

  void resetInactivityTimer() async {
    Duration durationSettings = await SettingsDB.getInstance().getTimeout();
    if (durationSettings == null) {
      durationSettings = Duration(minutes: 5);
    }
    inactivityTimer?.cancel();
    midTimer?.cancel();
    midTimer =
        Timer(Duration(seconds: durationSettings.inSeconds - 10), () async {
      bool val = await showBasicConfirmationDialog(
          "You have been inactive. Do you want to be logged out?", context);
      if (val == false) {
        inactivityTimer?.cancel();
        midTimer?.cancel();
        resetInactivityTimer();
      }
      if (val == true) {
        if (Navigator.of(context).canPop()) {
          try {
            Navigator.popUntil(context, ModalRoute.withName('home'));
          } catch (err) {
            print(err.toString());
          }
        }
        authState = AuthState.LOGGED_OUT;
        notifyListeners();
        inactivityTimer?.cancel();
        midTimer?.cancel();
      }
    });
    inactivityTimer = Timer(durationSettings, () {
      if (Navigator.of(context).canPop()) {
        try {
          Navigator.popUntil(context, ModalRoute.withName('home'));
        } catch (err) {
          print(err.toString());
        }
      }
      serviceProvider = null;
      authState = AuthState.LOGGED_OUT;
      notifyListeners();
      inactivityTimer?.cancel();
    });
  }

  Future<void> loginWithFingerPrint() async {
    var localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to login');
    if (didAuthenticate) {
      serviceProvider = serviceProvider;
      authState = AuthState.LOGGED_IN;
      notifyListeners();
    }
  }

  bool verifyPassword(String password) {
    if (serviceProvider != null) {
      if (serviceProvider.password == password) {
        return true;
      }
    }
    return false;
  }

  Future<void> login(String username, String password) async {
    await AuthApi.login(username, password).then((user) async {
      if (user != null) {
        user.password = password;
        AuthDB.getInstance().addUser(user);
        serviceProvider = user;
        authState = AuthState.LOGGED_IN;
        authToken = user.authToken;
        notifyListeners();
      }
    }).catchError((err) {
      print(err);
      // no internet connection, use save credential to log user in
      if (err.toString() == 'Connection Error') {
        print('Using offline credential');
        if (serviceProvider == null) {
          throw ('No internet connection');
        }
        if (username.toLowerCase() == serviceProvider.username.toLowerCase() &&
            password == serviceProvider.password) {
          authState = AuthState.LOGGED_IN;
          serviceProvider = serviceProvider;
          notifyListeners();
          return;
        }
        throw ('Username or password incorrect');
      } else if (err.toString() == 'This user is unauthorized') {
        //delete offline credentials if it exists because this user is no longer authorized by the admin
        if (serviceProvider.username.toLowerCase() == username.toLowerCase()) {
          AuthDB.getInstance().deleteUser(serviceProvider.username);
        }
        throw (err);
      } else {
        throw (err);
      }
    });
  }
}

enum AuthState { LOGGED_IN, LOGGED_OUT }
