import 'package:flutter/material.dart';
import 'package:kp/api/clinics_api.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/clinical_service.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/client_search.dart';
import 'package:kp/views/client_visit_history.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/number_picker.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class ClinicsHome extends StatefulWidget {
  @override
  State createState() => ClinicsHomeState();
}

class ClinicsHomeState extends State<ClinicsHome> {
  List<ClinicalService> services;
  bool fetchingServices = false;

  Duration selectedDuration = Duration(days: 30);

  @override
  void initState() {
    super.initState();
    fetchingServices = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getServices();
    });
  }

  Future<void> getServices() async {
    setState(() {
      fetchingServices = true;
      services = null;
    });
    try {
      List<ClinicalService> services =
          await ClinicsAPi.listClinicalServicesByPeriod(
              selectedDuration.inDays);
      setState(() {
        this.services = services;
        fetchingServices = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingServices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () async {
          Client selected = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientSearch(
                        isSelect: true,
                      )));
          if (selected != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClientVisitHistory(selected)));
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
                          "",
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
                    (MediaQuery.of(context).size.height - kToolbarHeight) * 0.9,
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey[300])),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: CustomFormDropDown<Duration>(
                              iconData: Icons.filter_list_outlined,
                              expanded: true,
                              useExternalValue: true,
                              initialValue: selectedDuration,
                              value: selectedDuration,
                              items: [
                                Duration(days: 30),
                                Duration(days: 60),
                                Duration(days: 90),
                                Duration(days: 180),
                                Duration(days: 365)
                              ].map((e) {
                                return DropdownMenuItem<Duration>(
                                  child: e.inDays >= 365
                                      ? Text(
                                          "Last ${e.inDays ~/ 365} year${e.inDays / 365 > 1 ? "s" : ""}")
                                      : Text(
                                          "Last ${e.inDays} day${e.inDays > 1 ? "s" : ""}"),
                                  value: e,
                                );
                              }).toList(),
                              onChanged: (duration) {
                                setState(() {
                                  selectedDuration = duration;
                                });
                                getServices();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Center(
                              child: GestureDetector(
                                onTap: () async {
                                  Client selected = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ClientSearch(
                                                isSelect: true,
                                              )));
                                  if (selected != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ClientVisitHistory(selected)));
                                  }
                                },
                                child: Icon(Icons.search),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                        child: Card(
                            child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            text: "Clinic",
                          ),
                          Expanded(
                              child: (services == null &&
                                          fetchingServices == true) ||
                                      checkAllMetaDataAvailable([
                                            'clinicalstages',
                                            'healthstatus'
                                          ], context) ==
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
                                  : services == null &&
                                          fetchingServices == false
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
                                                getServices();
                                              },
                                              child: Text('Retry',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: services.length,
                                          itemBuilder: (context, count) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ClientVisitHistory(Client(
                                                                hospitalNum: services[
                                                                        count]
                                                                    .clientUniqueIdentifier))));
                                              },
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: Text(services[count]
                                                        .clientUniqueIdentifier),
                                                    trailing: Chip(
                                                      padding: EdgeInsets.zero,
                                                      label: Text(
                                                        "Visits (${services[count].visitHistory.length})",
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    title: Text(findMetaDataFromId(
                                                            "clinicalstages",
                                                            services[count]
                                                                .clinicalStageId,
                                                            context)
                                                        .name),
                                                    subtitle: Text(
                                                        findMetaDataFromId(
                                                                "healthstatus",
                                                                services[count]
                                                                    .tbStatusId,
                                                                context)
                                                            .name),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        convertDateToString(
                                                            services[count]
                                                                .dateOfLastVisit),
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey),
                                                      )
                                                    ],
                                                  ),
                                                  Divider()
                                                ],
                                              ),
                                            );
                                          }))
                        ],
                      ),
                    )))
                  ],
                ),
              ),
              top: (MediaQuery.of(context).size.height - kToolbarHeight) * 0.1,
              left: MediaQuery.of(context).size.width * 0.15 / 2,
            )
          ],
        ),
      ),
    );
  }
}

class ClinicVisit extends StatefulWidget {
  final Client client;
  ClinicVisit(this.client);
  @override
  _ClinicVisitState createState() => _ClinicVisitState();
}

class _ClinicVisitState extends State<ClinicVisit> {
  KpMetaData selectedStage;
  KpMetaData selectedPregnancyStatus;
  KpMetaData selectedHealthStatus;
  KpMetaData selectedFunctionalStatus;
  KpMetaData selectedOpportunisticInfection;
  KpMetaData selectedLevelOfAdherence;
  DateTime dateOfFirstVisit;

  TextEditingController note = TextEditingController();

  bool screened = false;

  double height = 0;
  double weight = 0;
  int diastolic = 0;
  int systolic = 0;

  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider =
        Provider.of<MetadataProvider>(context, listen: true);
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              text: "Clinic Visit",
            ),
            SizedBox(
              height: 10,
            ),
            CustomDateSelector(
              title: "Date of first visit",
              futureOnly: true,
              onDateChanged: (date) {
                dateOfFirstVisit = date;
              },
            ),
            SizedBox(
              height: 10,
            ),
            CustomFormDropDown<KpMetaData>(
              text: "Clinical Stage",
              initialValue: selectedStage,
              value: selectedStage,
              useExternalValue: true,
              items: metaProvider.getMetaFromString('clinicalstages') == null
                  ? null
                  : metaProvider.getMetaFromString('clinicalstages').map((e) {
                      return DropdownMenuItem<KpMetaData>(
                        child: Text(e.name),
                        value: e,
                      );
                    }).toList(),
              onChanged: (stage) {
                setState(() {
                  selectedStage = stage;
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            CustomFormDropDown<KpMetaData>(
              text: "Pregnancy status",
              initialValue: selectedPregnancyStatus,
              value: selectedPregnancyStatus,
              useExternalValue: true,
              items: metaProvider.getMetaFromString('pregnancy') == null
                  ? null
                  : metaProvider.getMetaFromString('pregnancy').map((e) {
                      return DropdownMenuItem<KpMetaData>(
                        child: Text(e.name),
                        value: e,
                      );
                    }).toList(),
              onChanged: (status) {
                setState(() {
                  selectedPregnancyStatus = status;
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            CustomFormDropDown<KpMetaData>(
              text: "TB status",
              initialValue: selectedHealthStatus,
              value: selectedHealthStatus,
              useExternalValue: true,
              items: metaProvider.getMetaFromString('healthstatus') == null
                  ? null
                  : metaProvider.getMetaFromString('healthstatus').map((e) {
                      return DropdownMenuItem<KpMetaData>(
                        child: Text(e.name),
                        value: e,
                      );
                    }).toList(),
              onChanged: (status) {
                setState(() {
                  selectedHealthStatus = status;
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            CustomFormDropDown<KpMetaData>(
              text: "Functional Status",
              initialValue: selectedFunctionalStatus,
              value: selectedFunctionalStatus,
              useExternalValue: true,
              items: metaProvider.getMetaFromString('functionalstatus') == null
                  ? null
                  : metaProvider.getMetaFromString('functionalstatus').map((e) {
                      return DropdownMenuItem<KpMetaData>(
                        child: Text(e.name),
                        value: e,
                      );
                    }).toList(),
              onChanged: (status) {
                setState(() {
                  selectedFunctionalStatus = status;
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            CustomFormDropDown<KpMetaData>(
              text: "Opportunistic infections",
              initialValue: selectedOpportunisticInfection,
              value: selectedOpportunisticInfection,
              useExternalValue: true,
              items:
                  metaProvider.getMetaFromString('opportunisticinfections') ==
                          null
                      ? null
                      : metaProvider
                          .getMetaFromString('opportunisticinfections')
                          .map((e) {
                          return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name),
                            value: e,
                          );
                        }).toList(),
              onChanged: (status) {
                setState(() {
                  selectedOpportunisticInfection = status;
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            CustomFormDropDown<KpMetaData>(
              text: "Level of adherence",
              initialValue: selectedLevelOfAdherence,
              value: selectedLevelOfAdherence,
              useExternalValue: true,
              items: metaProvider.getMetaFromString('levelofadherence') == null
                  ? null
                  : metaProvider.getMetaFromString('levelofadherence').map((e) {
                      return DropdownMenuItem<KpMetaData>(
                        child: Text(e.name),
                        value: e,
                      );
                    }).toList(),
              onChanged: (status) {
                setState(() {
                  selectedLevelOfAdherence = status;
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                    child: NumberPicker(
                  useDouble: true,
                  text: "height",
                  initialValue: 0,
                  onChanged: (val) {
                    height = val;
                  },
                )),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: NumberPicker(
                  useDouble: true,
                  text: "weight",
                  initialValue: 0,
                  onChanged: (val) {
                    weight = val;
                  },
                ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(color: Colors.grey[800]),
            SizedBox(
              height: 10,
            ),
            Text("Blodd pressure"),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: NumberPicker(
                  text: "Systolic",
                  initialValue: 0,
                  onChanged: (val) {
                    systolic = val;
                  },
                )),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: NumberPicker(
                  text: "Diastolic",
                  initialValue: 0,
                  onChanged: (val) {
                    diastolic = val;
                  },
                ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(color: Colors.grey[800]),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Checkbox(
                    value: screened,
                    onChanged: (val) {
                      setState(() {
                        screened = val;
                      });
                    }),
                SizedBox(
                  width: 5,
                ),
                Text("Adverse drug reaction screened?")
              ],
            ),
            SizedBox(
              height: 10,
            ),
            LabeledTextField(
              controller: note,
              text: "Clinic Note",
              lines: 8,
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    child: Text("Cancel")),
                SizedBox(
                  width: 15,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (dateOfFirstVisit == null ||
                          selectedStage == null ||
                          selectedPregnancyStatus == null ||
                          selectedHealthStatus == null ||
                          selectedFunctionalStatus == null ||
                          selectedOpportunisticInfection == null ||
                          selectedLevelOfAdherence == null) {
                        return showBasicMessageDialog(
                            "Enter missing details", context);
                      }
                      ClinicVisitPayload payload = ClinicVisitPayload(
                          clinicalStageId: selectedStage.id,
                          functionalStatusId: selectedFunctionalStatus.id,
                          tbStatusId: selectedHealthStatus.id,
                          pregnancyStatusId: selectedPregnancyStatus.id,
                          weight: weight,
                          height: height,
                          systolic: systolic,
                          diastolic: diastolic,
                          adverseReactionScreened: screened,
                          clinicalNote: note.text,
                          hospitalNumber: widget.client.hospitalNum,
                          dateOfFirstVisit: dateOfFirstVisit);
                      showPersistentLoadingIndicator(context);
                      ClinicsAPi.postClinicalService(payload, context)
                          .then((value) {
                        //remove loading modal
                        Navigator.pop(context);
                        // remove add visit dialog
                        Navigator.pop(context, true);
                      }).catchError((err) {
                        Navigator.pop(context);
                        showBasicMessageDialog(err.toString(), context);
                      });
                    },
                    child: Text("Save")),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ClinicVisitPayload {
  int clinicalStageId;
  int functionalStatusId;
  int tbStatusId;
  int pregnancyStatusId;
  double weight;
  double height;
  int systolic;
  int diastolic;
  bool adverseReactionScreened;
  String clinicalNote;
  String hospitalNumber;
  DateTime dateOfFirstVisit;

  ClinicVisitPayload(
      {this.dateOfFirstVisit,
      this.systolic,
      this.diastolic,
      this.hospitalNumber,
      this.adverseReactionScreened,
      this.clinicalNote,
      this.clinicalStageId,
      this.functionalStatusId,
      this.height,
      this.pregnancyStatusId,
      this.tbStatusId,
      this.weight});

  Map<String, dynamic> toJson(BuildContext context) {
    return {
      "date_of_first_visit": dateOfFirstVisit.toIso8601String(),
      "clinical_stages_id": clinicalStageId,
      "functional_status_id": functionalStatusId,
      "tb_status_id": tbStatusId,
      "pregnancy_status_id": pregnancyStatusId,
      "weight": weight,
      "height": height,
      "systolic": systolic,
      "diastolic": diastolic,
      "adverse_reaction_screened": adverseReactionScreened,
      "clinical_note": clinicalNote,
      "created_by": Provider.of<AuthProvider>(context, listen: false)
          .serviceProvider
          .userId,
      "created_date": DateTime.now().millisecondsSinceEpoch,
      "client_unique_identifier": hospitalNumber,
      "date_of_last_visit": dateOfFirstVisit.toIso8601String(),
    };
  }
}
