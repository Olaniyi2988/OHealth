import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:provider/provider.dart';

class VeriFingerSDK {
  static const _platform = const MethodChannel('kp.centrifugegroup/scanner');

  static VeriFingerSDK _instance;
  static bool _initialized = false;
  VeriFingerSDK._();

  static VeriFingerSDK getInstance() {
    if (_initialized == false) {
      throw ('VeriFingerSDK not initialized');
    }
    if (_instance == null) {
      _instance = VeriFingerSDK._();
    }
    return _instance;
  }

  static Future<bool> obtainLicenses() async {
    bool allLicensesFetched = false;
    try {
      allLicensesFetched = await _platform.invokeMethod('obtainLicenses');
    } on PlatformException catch (e) {
      print(e);
    }
    return allLicensesFetched;
  }

  static Future<void> openLicenseManager(BuildContext context) async {
    Directory neuroTechDirectory =
        Directory('/storage/emulated/0/Neurotechnology/Licenses');
    bool allPermissionsAccepted = await checkPermissions();
    if (allPermissionsAccepted == false) {
      allPermissionsAccepted = await _requestPermission();
    }
    if (allPermissionsAccepted) {
      bool exists = await neuroTechDirectory.exists();
      if (exists == false) {
        await neuroTechDirectory.create(recursive: true);
      }

      if (Provider.of<AuthProvider>(context, listen: false)
                  .serviceProvider
                  .fingerClient ==
              null ||
          Provider.of<AuthProvider>(context, listen: false)
                  .serviceProvider
                  .fingerMatcher ==
              null) {
        return showBasicMessageDialog(
            "Incomplete or no license assigned to your account. Contact support",
            context);
      }

      try {
        await _platform.invokeMethod('licenseManager', {
          // "client": "83A5-A976-58A0-81DC-7CEE-83EC-87C4-CB10",
          "client": Provider.of<AuthProvider>(context, listen: false)
              .serviceProvider
              .fingerClient,
          // "matcher": "5A3D-431F-8E18-AB07-1D65-E3C0-6A8D-7B02",
          "matcher": Provider.of<AuthProvider>(context, listen: false)
              .serviceProvider
              .fingerMatcher,
          "clientpath":
              "/storage/emulated/0/Neurotechnology/Licenses/finger_client.sn",
          "matcherpath":
              "/storage/emulated/0/Neurotechnology/Licenses/finger_matcher.sn"
        });
      } on PlatformException catch (e) {
        print(e);
      }

      // bool add = await showBasicConfirmationDialog("Add license Files", context,
      //     positiveLabel: "Add Files", negativeLabel: "Continue without adding");
      // if (add == true) {
      //   FilePickerResult result = await FilePicker.platform.pickFiles(
      //     allowMultiple: true,
      //     type: FileType.custom,
      //     allowedExtensions: ['sn'],
      //   );
      //   if (result != null) {
      //     bool allValid = true;
      //     result.files.forEach((e) async {
      //       if (e.extension == 'sn') {
      //         File f = File(e.path);l
      //         await f.copy("${neuroTechDirectory.path}/${e.name}");
      //       } else {
      //         allValid = false;
      //       }
      //     });
      //     if (allValid == false) {
      //       return showBasicMessageDialog(
      //           "Invalid license file selected", context);
      //     } else {
      //       try {
      //         await _platform.invokeMethod('licenseManager');
      //       } on PlatformException catch (e) {
      //         print(e);
      //       }
      //     }
      //   } else {
      //     return;
      //   }
      // } else if (add == false) {
      //   try {
      //     await _platform.invokeMethod('licenseManager');
      //   } on PlatformException catch (e) {
      //     print(e);
      //   }
      // }
    } else {
      throw ("This operation requires storage permission");
    }
  }

  static Future<bool> init() async {
    // if (_initialized == true) {
    //   return true;
    // }
    bool allPermissionsAccepted = await checkPermissions();
    if (allPermissionsAccepted == false) {
      allPermissionsAccepted = await _requestPermission();
    }

    bool licenseObtained = await obtainLicenses();
    if (licenseObtained == false) {
      return false;
    }
    // if (allPermissionsAccepted) {
    //   try {
    //     _initialized = await _platform.invokeMethod('initBioTask');
    //   } on PlatformException catch (e) {
    //     print(e);
    //   }
    // }
    if (licenseObtained == true && allPermissionsAccepted == true) {
      _initialized = true;
    }
    return _initialized;
  }

  Future<Uint8List> captureFinger(int index, bool recapture) async {
    Uint8List data;
    try {
      String base64String = await _platform.invokeMethod(
          'fingerCaptureTask', {"index": index, "progress": "recapture"});
      base64String = base64String.split("\n").join();
      data = Base64Decoder().convert(base64String);
    } catch (err) {
      return null;
    }
    return data;
  }

  Future<bool> verifyFinger(List<String> prints, String subject) async {
    try {
      bool verified = await _platform.invokeMethod(
          'verificationTask', {"prints": prints, "subject": subject});
      return verified;
    } catch (err) {
      return null;
    }
  }

  static Future<String> getCaptureTaskTemplateBuffer() async {
    try {
      var s = await _platform.invokeMethod("captureResult");
      print(s);
      return s['filePath'];
    } catch (err) {
      print(err);
    }
  }

  static Future<bool> checkPermissions() async {
    bool allPermissionsGranted = false;
    try {
      allPermissionsGranted =
          await _platform.invokeMethod('bioPermissionCheck');
    } on PlatformException catch (e) {
      print(e);
    }
    return allPermissionsGranted;
  }

  static Future<bool> _requestPermission() async {
    bool permissionRequested = false;
    try {
      permissionRequested =
          await _platform.invokeMethod('bioPermissionRequest');
    } on PlatformException catch (e) {
      print(e);
    }
    return permissionRequested;
  }
}
