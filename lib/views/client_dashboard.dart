import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/api/clients_api.dart';
import 'package:kp/custom_plugins/veri_finger.dart';
import 'package:kp/models/biometrics.dart';
import 'package:kp/models/client.dart';
import 'package:kp/util.dart';
import 'package:kp/views/edit_client.dart';
import 'package:kp/widgets/diagnosis_tab.dart';
import 'package:kp/widgets/finger_capture_dialog.dart';
import 'package:kp/widgets/forms/finger_capture.dart';
import 'package:kp/widgets/patient_tile.dart';

class ClientDashboard extends StatefulWidget {
  final Client client;

  ClientDashboard({this.client});
  @override
  State createState() => ClientDashboardState();
}

class ClientDashboardState extends State<ClientDashboard> {
  Client client;
  @override
  void initState() {
    client = widget.client;
    super.initState();
  }

  @override
  void dispose() {
    savedDIagnosis = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('', style: TextStyle(color: Colors.blueAccent)),
        backgroundColor: Colors.white,
        actions: [
          ClientOptions(
            client: client,
            isDashboard: true,
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: NameCard(
            client: client,
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final Client client;

  InfoCard({this.client});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        color: Colors.white,
        height: orientation == Orientation.landscape ? double.infinity : null,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: InfoChip(
                    title: 'Gender',
                    subtitle: client.gender.name,
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: InfoChip(
                    title: 'Date of Birth',
                    subtitle: convertDateToString(client.dob),
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: InfoChip(
                    title: 'Phone Number',
                    subtitle: client.phone,
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: InfoChip(
                    title: 'Address',
                    subtitle: '17A, Lokogoma',
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: InfoChip(
                    title: 'City',
                    subtitle: client.state == null ? "" : client.state,
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: InfoChip(
                    title: 'Registration Date',
                    subtitle: convertDateToString(client.regDate),
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: InfoChip(
                    title: 'Marital Status',
                    subtitle: client.maritalStatus.name,
                  )),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(child: Container()),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}

class InfoChip extends StatelessWidget {
  final String title;
  final String subtitle;
  InfoChip({this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 3, color: Colors.grey[200]))),
      child: Padding(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            SizedBox(
              height: 15,
            ),
            Text(
              subtitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class NameCard extends StatelessWidget {
  final Client client;
  NameCard({this.client});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              '${client.firstName == "" ? "" : client.firstName[0].toUpperCase()}${client.surname == "" ? "" : client.surname[0].toUpperCase()}',
              style: TextStyle(fontSize: 30),
            ),
            radius: 50,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '${client.hospitalNum}',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            client.phone,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditClient(
                            client: client,
                          )));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit/View'),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.edit)
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () async {
              Uint8List data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      elevation: 10,
                      contentPadding: EdgeInsets.zero,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      content: FingerCaptureDialog(
                        index: 0,
                        captured: false,
                      ),
                    );
                  });
              if (data != null) {
                showPersistentLoadingIndicator(context);
                String path =
                    await VeriFingerSDK.getCaptureTaskTemplateBuffer();
                ClientApi.verifyBiometrics(path, client.hospitalNum, context)
                    .then((value) {
                  Navigator.pop(context);
                  if (value == true) {
                    showBasicMessageDialog("Match found", context);
                  } else {
                    showBasicMessageDialog("Match not found", context);
                  }
                }).catchError((err) {
                  print(err);
                  Navigator.pop(context);
                });
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 40,
                ),
                SizedBox(
                  width: 10,
                ),
                Text('Verify Client')
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                            body: FingerCaptureForm(
                              disableSteps: true,
                              client: client,
                              onFinished: (biometrics) async {
                                showPersistentLoadingIndicator(context);
                                ClientApi.uploadBiometrics(
                                        biometrics, client.hospitalNum, context)
                                    .then((value) {
                                  Navigator.pop(context);
                                  // showBasicMessageDialog(
                                  //     "Biometrics enrollment successful",
                                  //     context);
                                  Navigator.pop(context, true);
                                }).catchError((err) {
                                  Navigator.pop(context);
                                  showBasicMessageDialog(
                                      err.toString(), context);
                                });
                              },
                            ),
                          )));
              if (res != null) {
                showBasicMessageDialog("Enrollment successful", context);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 40,
                ),
                SizedBox(
                  width: 10,
                ),
                Text('Capture biometrics')
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300], width: 3),
                    borderRadius: BorderRadius.circular(7)),
                child: Center(
                  child: Text(
                    'Send Message',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
