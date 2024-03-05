import 'package:flutter/material.dart';
import 'package:kp/custom_plugins/veri_finger.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class FingerCaptureDialog extends StatefulWidget {
  final int index;
  final bool captured;

  FingerCaptureDialog({this.index, this.captured});
  @override
  State createState() => FingerCaptureDialogState();
}

class FingerCaptureDialogState extends State<FingerCaptureDialog> {
  CaptureState captureState = CaptureState.INITIALIZING;
  VeriFingerSDK veriFinger;

  @override
  void initState() {
    capture();
    super.initState();
  }

  void capture() async {
    initializeVeriFingerSdk().then((value) async {
      if (await VeriFingerSDK.checkPermissions()) {
        if (value == true && veriFinger != null) {
          setState(() {
            captureState = CaptureState.WAITING_FOR_FINGER;
          });
          await Future.delayed(Duration(milliseconds: 200), () {
            print('...');
          });
          veriFinger.captureFinger(widget.index, widget.captured).then((path) {
            if (path != null) {
              Navigator.pop(context, path);
            } else {
              setState(() {
                captureState = CaptureState.FAILED_TO_CAPTURE;
              });
            }
          });
        } else {
          setState(() {
            captureState = CaptureState.INITIALIZATION_FAILED;
          });
        }
      }
    });
  }

  Future<bool> initializeVeriFingerSdk() async {
    setState(() {
      captureState = CaptureState.INITIALIZING;
    });
    bool initialised = false;
    try {
      await VeriFingerSDK.init();
      veriFinger = VeriFingerSDK.getInstance();
      if (veriFinger != null) {
        initialised = true;
      } else {
        initialised = false;
      }
    } catch (e) {
      print(e);
      initialised = false;
    }
    await Future.delayed(Duration(milliseconds: 200), () {
      print('...');
    });
    return initialised;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Expanded(
                child: InkWell(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false)
                    .resetInactivityTimer();
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
              ),
            )),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 100,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    captureState == CaptureState.FAILED_TO_CAPTURE ||
                            captureState == CaptureState.INITIALIZATION_FAILED
                        ? RaisedButton(
                            onPressed: () {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .resetInactivityTimer();
                              capture();
                            },
                            child: Text('Retry'),
                          )
                        : Text(captureState == CaptureState.INITIALIZING
                            ? "Initialising"
                            : captureState == CaptureState.WAITING_FOR_FINGER
                                ? "Waiting for finger"
                                : captureState == CaptureState.CAPTURED
                                    ? "Captured"
                                    : "")
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

enum CaptureState {
  INITIALIZING,
  WAITING_FOR_FINGER,
  CAPTURED,
  FAILED_TO_CAPTURE,
  INITIALIZATION_FAILED
}
