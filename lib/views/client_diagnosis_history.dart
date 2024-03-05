import 'package:flutter/material.dart';
import 'package:kp/api/consultation_api.dart';
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

class ClientDiagnosisHistory extends StatefulWidget {
  final Client client;
  ClientDiagnosisHistory(this.client);
  @override
  State createState() => ClientDiagnosisHistoryState();
}

class ClientDiagnosisHistoryState extends State<ClientDiagnosisHistory> {
  List<Diagnosis> diagnosis;
  bool fetchingDiagnosis = false;
  List<String> requiredMetadata = ['severity', 'diagnosisconditions'];

  @override
  void initState() {
    super.initState();
    fetchingDiagnosis = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDiagnosis();
    });
  }

  Future<void> getDiagnosis() async {
    setState(() {
      fetchingDiagnosis = true;
      diagnosis = null;
    });
    try {
      List<Diagnosis> diagnosis =
          await ConsultationApi.lisDiagnosis(widget.client.hospitalNum);
      setState(() {
        this.diagnosis = diagnosis;
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var response = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  insetPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  content: AddDiagnosisDialog(client: widget.client),
                );
              });
          if (response != null) {
            getDiagnosis();
          }
        },
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              height:
                  (MediaQuery.of(context).size.height - kToolbarHeight) * 0.35,
              color: Colors.blueAccent,
              child: SafeArea(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                        ),
                        Text(
                          widget.client.hospitalNum,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
              ),
            ),
            Positioned(
              child: SizedBox(
                height:
                    (MediaQuery.of(context).size.height - kToolbarHeight) * 0.8,
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  children: [
                    Expanded(
                        child: Card(
                            child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            text: "Diagnosis history",
                          ),
                          Expanded(
                              child: (diagnosis == null &&
                                          fetchingDiagnosis == true) ||
                                      checkAllMetaDataAvailable(
                                              requiredMetadata, context) ==
                                          false
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.blueAccent))
                                        ],
                                      ),
                                    )
                                  : diagnosis == null &&
                                          fetchingDiagnosis == false
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                              (states) {
                                                return Colors.blueAccent;
                                              })),
                                              onPressed: () {
                                                getDiagnosis();
                                              },
                                              child: Text('Retry',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: diagnosis.length,
                                          itemBuilder: (context, count) {
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text("OnsetDate"),
                                                      subtitle: Text(
                                                          convertDateToString(
                                                              diagnosis[count]
                                                                  .onsetDate)),
                                                    )),
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text("Severity"),
                                                      subtitle: Text(
                                                          findMetaDataFromId(
                                                                  'severity',
                                                                  diagnosis[
                                                                          count]
                                                                      .severityId,
                                                                  context)
                                                              .name
                                                              .toString()),
                                                    )),
                                                  ],
                                                ),
                                                ListTile(
                                                  title: Text("Condition"),
                                                  subtitle: Text(findMetaDataFromId(
                                                          'diagnosisconditions',
                                                          diagnosis[count]
                                                              .conditionId,
                                                          context)
                                                      .name
                                                      .toString()),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.blueAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 15,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            diagnosis[count]
                                                                        .diagnosisDate ==
                                                                    null
                                                                ? "---"
                                                                : convertDateToString(
                                                                    diagnosis[
                                                                            count]
                                                                        .diagnosisDate),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Divider()
                                              ],
                                            );
                                          }))
                        ],
                      ),
                    )))
                  ],
                ),
              ),
              top: (MediaQuery.of(context).size.height - kToolbarHeight) * 0.15,
              left: MediaQuery.of(context).size.width * 0.15 / 2,
            )
          ],
        ),
      ),
    );
  }
}

class AddDiagnosisDialog extends StatefulWidget {
  final Client client;
  AddDiagnosisDialog({this.client});
  @override
  _AddDiagnosisDialogState createState() => _AddDiagnosisDialogState();
}

class _AddDiagnosisDialogState extends State<AddDiagnosisDialog> {
  DateTime onsetDate;
  KpMetaData condition;
  KpMetaData severity;
  TextEditingController noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider = Provider.of(context, listen: true);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                items:
                    metaProvider.genericMetaData['diagnosisconditions'] == null
                        ? null
                        : metaProvider.genericMetaData['diagnosisconditions']
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
                items: metaProvider.genericMetaData['severity'] == null
                    ? null
                    : metaProvider.genericMetaData['severity'].map((e) {
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
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RaisedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blueAccent,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());

                      if (onsetDate == null ||
                          condition == null ||
                          severity == null ||
                          noteController.text == "") {
                        return showBasicMessageDialog(
                            "Enter empty fields", context);
                      }

                      if (await showBasicConfirmationDialog(
                              "Save diagnosis?", context) ==
                          false) {
                        return;
                      }

                      showPersistentLoadingIndicator(context);
                      ConsultationApi.postClinicalDiagnosis(widget.client, {
                        'onset_date': onsetDate.toIso8601String(),
                        'severity_id': severity.id,
                        'diagnosed_condition_id': condition.id,
                        'clinical_note': noteController.text,
                        'diagnosed_by_id':
                            Provider.of<AuthProvider>(context, listen: false)
                                .serviceProvider
                                .userId,
                        'diagnosed_date': DateTime.now().toIso8601String(),
                        'client_unique_identifier': widget.client.hospitalNum
                      }).then((val) {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
