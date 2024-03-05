import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/custom_plugins/veri_finger.dart';
import 'package:kp/db/settings.dart';
import 'package:kp/models/biometrics.dart';
import 'package:kp/models/client.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/finger_capture_dialog.dart';
import 'package:kp/widgets/forms/form_template.dart';

class FingerCaptureForm extends StatefulWidget {
  final void Function(Biometrics biometrics) onFinished;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final Client client;
  final VoidCallback onBack;
  final bool disableSteps;
  FingerCaptureForm(
      {this.stepIndex,
      this.onFinished,
      this.numberOfSteps,
      this.onBack,
      this.disableBackButton,
      this.disableForwardButton,
      this.client,
      this.disableSteps = false}) {
    assert(client != null);
  }

  @override
  State createState() => FingerCaptureFormState();
}

class FingerCaptureFormState extends State<FingerCaptureForm> {
  Uint8List leftThumb;
  Uint8List rightThumb;
  Uint8List leftIndex;
  Uint8List rightIndex;
  Uint8List leftMid;
  Uint8List rightMid;

  List<String> prints = [null, null, null, null, null, null];

  int indexTracker = -1;

  @override
  void initState() {
    if (widget.client.biometrics != null) {
      leftThumb = Base64Decoder().convert(widget.client.biometrics.leftThumb);
      rightThumb = Base64Decoder().convert(widget.client.biometrics.rightThumb);
      rightIndex = Base64Decoder().convert(widget.client.biometrics.rightIndex);
      leftIndex = Base64Decoder().convert(widget.client.biometrics.leftIndex);
      rightMid = Base64Decoder().convert(widget.client.biometrics.rightMid);
      leftMid = Base64Decoder().convert(widget.client.biometrics.leftMid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormTemplate(
      disableProgressStep: widget.disableSteps,
      onFinished: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        bool fingerprint = await SettingsDB.getInstance().getFingerprint();

        // //temprarily diasbale finger capture
        // return widget.onFinished(Biometrics());

        if (widget.onFinished != null) {
          if ((leftThumb == null ||
                  rightThumb == null ||
                  leftIndex == null ||
                  rightIndex == null ||
                  leftMid == null ||
                  rightMid == null) &&
              fingerprint == true) {
            showBasicMessageDialog("Finger Capture incomplete", context);
          } else {
            try {
              String filePath =
                  await VeriFingerSDK.getCaptureTaskTemplateBuffer();
              Biometrics biometrics = Biometrics(
                  leftThumb: Base64Encoder().convert(leftThumb),
                  rightThumb: Base64Encoder().convert(rightThumb),
                  leftMid: Base64Encoder().convert(leftMid),
                  rightMid: Base64Encoder().convert(rightMid),
                  leftIndex: Base64Encoder().convert(leftIndex),
                  rightIndex: Base64Encoder().convert(rightIndex),
                  filePath: filePath);
              widget.onFinished(biometrics);
            } catch (err) {
              widget.onFinished(null);
            }
          }
        }
      },
      stepIndex: widget.stepIndex,
      numberOfSteps: widget.numberOfSteps,
      disableBackButton: widget.disableBackButton,
      disableForwardButton: widget.disableForwardButton,
      onBack: widget.onBack,
      nextIsSave: false,
      title: "Fingerprint Capture",
      children: [
        Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Expanded(
                      child: FittedBox(
                    child: Finger(
                      prints:
                          prints.where((element) => element != null).toList(),
                      globalIndex: indexTracker,
                      value: leftThumb,
                      label: "Left Thumb",
                      onCaptured: (path, increaseIndex) {
                        if (path == null || increaseIndex == null) {
                          return showBasicMessageDialog(
                              "This finger has already been captured", context);
                        }
                        setState(() {
                          prints[0] = Base64Encoder().convert(path);
                          leftThumb = path;
                          if (increaseIndex) {
                            indexTracker++;
                          }
                        });
                      },
                    ),
                    fit: BoxFit.fitWidth,
                  )),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: FittedBox(
                    child: Finger(
                      prints:
                          prints.where((element) => element != null).toList(),
                      globalIndex: indexTracker,
                      value: rightThumb,
                      label: "Right Thumb",
                      onCaptured: (path, increaseIndex) {
                        if (path == null || increaseIndex == null) {
                          return showBasicMessageDialog(
                              "This finger has already been captured", context);
                        }
                        setState(() {
                          rightThumb = path;
                          prints[1] = Base64Encoder().convert(path);
                          if (increaseIndex) {
                            indexTracker++;
                          }
                        });
                      },
                    ),
                    fit: BoxFit.fitWidth,
                  )),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(child: Container()),
                  Expanded(
                      child: FittedBox(
                    child: Finger(
                      prints:
                          prints.where((element) => element != null).toList(),
                      globalIndex: indexTracker,
                      value: leftIndex,
                      label: "Left Index",
                      onCaptured: (path, increaseIndex) {
                        if (path == null || increaseIndex == null) {
                          return showBasicMessageDialog(
                              "This finger has already been captured", context);
                        }
                        setState(() {
                          prints[2] = Base64Encoder().convert(path);
                          leftIndex = path;
                          if (increaseIndex) {
                            indexTracker++;
                          }
                        });
                      },
                    ),
                    fit: BoxFit.fitWidth,
                  )),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Expanded(
                      child: FittedBox(
                    child: Finger(
                      prints:
                          prints.where((element) => element != null).toList(),
                      globalIndex: indexTracker,
                      value: rightIndex,
                      label: "Right Index",
                      onCaptured: (path, increaseIndex) {
                        if (path == null || increaseIndex == null) {
                          return showBasicMessageDialog(
                              "This finger has already been captured", context);
                        }
                        setState(() {
                          prints[3] = Base64Encoder().convert(path);
                          rightIndex = path;
                          if (increaseIndex) {
                            indexTracker++;
                          }
                        });
                      },
                    ),
                    fit: BoxFit.fitWidth,
                  )),
                  Expanded(child: Container()),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: FittedBox(
                    child: Finger(
                      prints:
                          prints.where((element) => element != null).toList(),
                      globalIndex: indexTracker,
                      value: leftMid,
                      label: "Left Mid",
                      onCaptured: (path, increaseIndex) {
                        if (path == null || increaseIndex == null) {
                          return showBasicMessageDialog(
                              "This finger has already been captured", context);
                        }
                        setState(() {
                          prints[4] = Base64Encoder().convert(path);
                          leftMid = path;
                          if (increaseIndex) {
                            indexTracker++;
                          }
                        });
                      },
                    ),
                    fit: BoxFit.fitWidth,
                  )),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Expanded(
                      child: FittedBox(
                    child: Finger(
                      prints:
                          prints.where((element) => element != null).toList(),
                      globalIndex: indexTracker,
                      value: rightMid,
                      label: "Right Mid",
                      onCaptured: (path, increaseIndex) {
                        if (path == null || increaseIndex == null) {
                          return showBasicMessageDialog(
                              "This finger has already been captured", context);
                        }
                        setState(() {
                          prints[5] = Base64Encoder().convert(path);
                          rightMid = path;
                          if (increaseIndex) {
                            indexTracker++;
                          }
                        });
                      },
                    ),
                    fit: BoxFit.fitWidth,
                  ))
                ],
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Finger extends StatefulWidget {
  final Function(Uint8List data, bool increaseIndex) onCaptured;
  final Uint8List value;
  final String label;
  final int globalIndex;
  final List<String> prints;
  Finger(
      {this.onCaptured, this.value, this.label, this.globalIndex, this.prints});
  @override
  State createState() => FingerState();
}

class FingerState extends State<Finger> {
  bool captured = false;
  int index;

  Future<Uint8List> captureFinger() async {
    bool capture = true;
    if (widget.value != null) {
      capture = await showBasicConfirmationDialog(
          "Already captured this finger. Do you want to recapture?", context);
    }
    if (capture) {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              elevation: 10,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              content: FingerCaptureDialog(
                index: index != null ? index : widget.globalIndex + 1,
                captured: captured,
              ),
            );
          });
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Uint8List data = await captureFinger();
        String dat = Base64Encoder().convert(data);
        bool exists = false;
        showPersistentLoadingIndicator(context);
        try {
          if (widget.prints.length != 0) {
            exists = await VeriFingerSDK.getInstance()
                .verifyFinger(widget.prints, dat);
          }
          Navigator.pop(context);
        } catch (err) {
          Navigator.pop(context);
          return widget.onCaptured(null, null);
        }
        if (data != null && exists == false) {
          if (widget.onCaptured != null) {
            widget.onCaptured(data, index == null);
            index = widget.globalIndex + 1;
            captured = true;
          }
        } else if (exists == true) {
          widget.onCaptured(null, null);
        }
      },
      child: Container(
        height: 150,
        width: 150,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 3)),
        child: widget.value != null
            ? Image.memory(widget.value)
            : Center(
                child: Text(
                  widget.label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
      ),
    );
  }
}
