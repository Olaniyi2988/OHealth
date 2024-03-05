import 'package:flutter/material.dart';
import 'package:kp/api/consultation_api.dart';
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/vitals.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/number_picker.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:async';
import 'dart:convert';

class VitalsTab extends StatefulWidget {
  final Client client;
  final GlobalKey<VitalsTabState> key;
  VitalsTab({this.client, this.key}) : super(key: key);
  @override
  State createState() => VitalsTabState();
}

List<Vitals> savedVitals = [];

class VitalsTabState extends State<VitalsTab> {
  bool fetchingVitals;
  List<Vitals> vitals;

  @override
  void initState() {
    super.initState();
    fetchingVitals = true;
    if (savedVitals.length > 0) {
      vitals = savedVitals;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedVitals.length == 0) {
        getVitals();
      }
    });
  }

  Future<void> getVitals({String lastGameId}) async {
    print('getting vitals');
    setState(() {
      fetchingVitals = true;
    });
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          url: endPointBaseUrl +
              "/listclinicalvitalsigns?client_unique_identifier=${widget.client.hospitalNum}",
          method: RequestMethod.GET);
      print(response.body);
      if (response.statusCode == 200) {
        List vitalsJsons = JsonDecoder().convert(response.body);
        List<Vitals> vitals = vitalsJsons.map((json) {
          return Vitals.fromJson(json);
        }).toList();
        this.vitals = vitals;
        savedVitals = vitals;
      } else if (response.statusCode == 400) {
        this.vitals = [];
      }
      setState(() {
        fetchingVitals = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingVitals = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vitals != null) {
      vitals.sort((a, b) {
        return b.dateOfVital.compareTo(a.dateOfVital);
      });
    }
    return OrientationBuilder(builder: (context, orientation) {
      return ResponsiveBuilder(
        builder: (context, info) {
          return Container(
            color: Colors.grey[100],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SectionHeader(
                            text: 'Vitals',
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  vitals = null;
                                  savedVitals = [];
                                  getVitals();
                                },
                                child: Icon(Icons.refresh),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .resetInactivityTimer();
                                  collectVitals(
                                      context: context,
                                      orientation: orientation,
                                      sizingInfo: info,
                                      client: widget.client);
                                },
                                child: Icon(Icons.add),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      vitals == null && fetchingVitals == true
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : vitals == null && fetchingVitals == false
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: RaisedButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .resetInactivityTimer();
                                        getVitals();
                                      },
                                      child: Text('Retry',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                )
                              : vitals.length == 0
                                  ? Center(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Nothing to see here yet",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: ListView.builder(
                                      itemBuilder: (context, count) {
                                        return Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                child: SectionHeader(
                                                  text: convertDateToString(
                                                      vitals[count]
                                                          .dateOfVital),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                    "Pulse: ${vitals[count].pulse}"
                                                    "\nRespiratory Rate: ${vitals[count].respiratoryRate}"
                                                    "\nTemperature: ${vitals[count].temperature}"
                                                    "\nWeight: ${vitals[count].weight}"
                                                    "\nHeight: ${vitals[count].height}"
                                                    "\nSystolic: ${vitals[count].systolicPressure}"
                                                    "\nDiastolic: ${vitals[count].diastolicPressure}"),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: vitals.length,
                                      physics: BouncingScrollPhysics(),
                                    ))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

void collectVitals(
    {BuildContext context,
    Orientation orientation,
    SizingInformation sizingInfo,
    Client client}) {
  DateTime dateOfVital = DateTime.now();
  int pulse = 0;
  int respiratoryRate = 0;
  int temperature = 0;
  int weight = 0;
  int systolicPressure = 0;
  int diastolicPressure = 0;
  int height = 0;

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: SectionHeader(
            text: 'Add Vitals',
          ),
          insetPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(10),
          content: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListView(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...splitToChunks([
                        CustomDateSelector(
                          initialDate: dateOfVital,
                          title: 'Date of vital signs',
                          onDateChanged: (date) {
                            dateOfVital = date;
                          },
                        ),
                        NumberPicker(
                          text: 'Pulse (bpm)',
                          initialValue: pulse,
                          onChanged: (val) {
                            pulse = val;
                          },
                        ),
                        NumberPicker(
                          text: 'Respiratory Rate (bpm)',
                          initialValue: respiratoryRate,
                          onChanged: (val) {
                            respiratoryRate = val;
                          },
                        ),
                        NumberPicker(
                          text: 'Temperature (c)',
                          initialValue: temperature,
                          onChanged: (val) {
                            temperature = val;
                          },
                        ),
                        NumberPicker(
                          text: 'Weight',
                          initialValue: weight,
                          onChanged: (val) {
                            weight = val;
                          },
                        ),
                        NumberPicker(
                          text: 'Height',
                          initialValue: height,
                          onChanged: (val) {
                            height = val;
                          },
                        ),
                        NumberPicker(
                          text: 'Systolic blood pressure (mm Hg)',
                          initialValue: systolicPressure,
                          onChanged: (val) {
                            systolicPressure = val;
                          },
                        ),
                        NumberPicker(
                          text: 'Diastolic blood pressure (mm Hg)',
                          initialValue: diastolicPressure,
                          onChanged: (val) {
                            diastolicPressure = val;
                          },
                        )
                      ], sizingInfo.isMobile ? 2 : 3)
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: [
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blueAccent,
            ),
            RaisedButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (height == null ||
                    respiratoryRate == null ||
                    pulse == null ||
                    temperature == null ||
                    weight == null ||
                    systolicPressure == null ||
                    diastolicPressure == null ||
                    dateOfVital == null) {
                  return showBasicMessageDialog("Enter empty fields", context);
                }

                showPersistentLoadingIndicator(context);
                ConsultationApi.postClinicalVitals(client, {
                  'height': height,
                  'respiratory_rate': respiratoryRate,
                  'pulse': pulse,
                  'temperature': temperature,
                  'weight': weight,
                  'systolic': systolicPressure,
                  'diastolic': diastolicPressure,
                  'client_unique_identifier': client.hospitalNum,
                  'created_date': dateOfVital.toIso8601String(),
                  'created_by':
                      Provider.of<AuthProvider>(context, listen: false)
                          .serviceProvider
                          .userId,
                }).then((val) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // getDiagnosis();
                  // showBasicMessageDialog("Diagnosis saved", context);
                }).catchError((err) {
                  Navigator.pop(context);
                  showBasicMessageDialog(err.toString(), context);
                });
              },
              child: Text(
                'ADD',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blueAccent,
            ),
          ],
          // contentPadding: EdgeInsets.zero,
        );
      });
}
