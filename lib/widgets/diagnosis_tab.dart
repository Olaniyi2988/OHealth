import 'package:flutter/material.dart';
import 'package:kp/api/consultation_api.dart';
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/diagnosis.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:async';
import 'dart:convert';

class DiagnosisTab extends StatefulWidget {
  final Client client;
  final GlobalKey<DiagnosisTabState> key;
  DiagnosisTab({this.client, this.key}) : super(key: key);
  @override
  State createState() => DiagnosisTabState();
}

List<Diagnosis> savedDIagnosis = [];

class DiagnosisTabState extends State<DiagnosisTab> {
  bool fetchingDiagnosis;
  List<Diagnosis> diagnosis;

  @override
  void initState() {
    super.initState();
    fetchingDiagnosis = true;
    if (savedDIagnosis.length > 0) {
      diagnosis = savedDIagnosis;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedDIagnosis.length == 0) {
        getDiagnosis();
      }
    });
  }

  Future<void> getDiagnosis({String lastGameId}) async {
    print('getting diagnosis');
    setState(() {
      fetchingDiagnosis = true;
    });
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          url: endPointBaseUrl +
              "/listclinicaldiagnosis?client_unique_identifier=${widget.client.hospitalNum}",
          method: RequestMethod.GET);
      print(response.body);
      if (response.statusCode == 200) {
        List diagnosisJsons = JsonDecoder().convert(response.body);
        List<Diagnosis> diagnosis = diagnosisJsons.map((json) {
          return Diagnosis.fromJson(json);
        }).toList();
        this.diagnosis = diagnosis;
        savedDIagnosis = diagnosis;
      } else if (response.statusCode == 400) {
        this.diagnosis = [];
      }
      setState(() {
        fetchingDiagnosis = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingDiagnosis = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (diagnosis != null) {
      diagnosis.sort((a, b) {
        return b.diagnosisDate.compareTo(a.diagnosisDate);
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
                            text: 'Diagnosis',
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  diagnosis = null;
                                  savedDIagnosis = [];
                                  getDiagnosis();
                                },
                                child: Icon(Icons.refresh),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await collectDiagnosis(
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
                      diagnosis == null && fetchingDiagnosis == true
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : diagnosis == null && fetchingDiagnosis == false
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: RaisedButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        getDiagnosis();
                                      },
                                      child: Text('Retry',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                )
                              : diagnosis.length == 0
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
                                                      diagnosis[count]
                                                          .diagnosisDate),
                                                ),
                                              ),
                                              // ListTile(
                                              //   title: Text(
                                              //       "${diagnosis[count].condition.name}"),
                                              //   subtitle: Text(
                                              //       "Severity: ${diagnosis[count].severity.name}\nOnset: ${convertDateToString(diagnosis[count].onsetDate)}\n${diagnosis[count].note}"),
                                              // ),
                                              SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: diagnosis.length,
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

Future<dynamic> collectDiagnosis(
    {BuildContext context,
    Orientation orientation,
    SizingInformation sizingInfo,
    Client client}) async {
  DateTime onsetDate;
  KpMetaData condition;
  KpMetaData severity;
  TextEditingController noteController = TextEditingController();
  var val = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: SectionHeader(
            text: 'Diagnosis',
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
                  Consumer<MetadataProvider>(
                    builder: (context, metaProvider, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...splitToChunks([
                            CustomDateSelector(
                              title: "Onset Date",
                              onDateChanged: (date) {
                                onsetDate = date;
                              },
                            ),
                            CustomFormDropDown<KpMetaData>(
                              text: 'Condition',
                              iconData: Icons.family_restroom_outlined,
                              initialValue: condition,
                              items: metaProvider.genericMetaData[
                                          'diagnosisconditions'] ==
                                      null
                                  ? null
                                  : metaProvider
                                      .genericMetaData['diagnosisconditions']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                              onChanged: (value) {
                                condition = value;
                              },
                            ),
                            CustomFormDropDown<KpMetaData>(
                              text: 'Severity',
                              iconData: Icons.family_restroom_outlined,
                              initialValue: severity,
                              items: metaProvider.genericMetaData['severity'] ==
                                      null
                                  ? null
                                  : metaProvider.genericMetaData['severity']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                              onChanged: (value) {
                                severity = value;
                              },
                            ),
                            LabeledTextField(
                              readOnly: false,
                              text: "Note",
                              controller: noteController,
                              lines: 5,
                              onChanged: (val) {},
                            )
                          ], sizingInfo.isMobile ? 1 : 1)
                        ],
                      );
                    },
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

                if (onsetDate == null ||
                    condition == null ||
                    severity == null ||
                    noteController.text == "") {
                  return showBasicMessageDialog("Enter empty fields", context);
                }

                showPersistentLoadingIndicator(context);
                ConsultationApi.postClinicalDiagnosis(client, {
                  'onset_date': onsetDate.toIso8601String(),
                  'severity_id': severity.id,
                  'diagnosed_condition_id': condition.id,
                  'clinical_note': noteController.text,
                  'diagnosed_by_id':
                      Provider.of<AuthProvider>(context, listen: false)
                          .serviceProvider
                          .userId,
                  'diagnosed_date': DateTime.now().toIso8601String(),
                  'client_unique_identifier': client.hospitalNum
                }).then((val) {
                  Navigator.pop(context);
                  // Navigator.pop(
                  //     context,
                  //     Diagnosis(
                  //         onsetDate: onsetDate,
                  //         severity: severity,
                  //         condition: condition,
                  //         diagnosisDate: DateTime.now(),
                  //         note: noteController.text));
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

  return val;
}
