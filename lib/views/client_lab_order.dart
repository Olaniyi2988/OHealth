import 'package:flutter/material.dart';
import 'package:kp/api/lab.dart';
import 'package:kp/api/laboratory.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/lab_order.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/lab_order.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/number_picker.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class ClientLabOrders extends StatefulWidget {
  final Client client;
  ClientLabOrders(this.client);
  @override
  State createState() => ClientLabOrdersState();
}

class ClientLabOrdersState extends State<ClientLabOrders> {
  List<LaboratoryOrder> orders;
  bool fetchingTests = true;

  @override
  void initState() {
    super.initState();
    fetchingTests = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTests();
    });
  }

  Future<void> getTests() async {
    setState(() {
      fetchingTests = true;
      orders = null;
    });
    try {
      List<LaboratoryOrder> orders = await LabApi.listTestsByHospitalNumber(
          widget.client.hospitalNum, context);
      setState(() {
        this.orders = orders;
        fetchingTests = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingTests = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          bool response = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LabOrder(
                        client: widget.client,
                      )));
          if (response != null) {
            getTests();
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
                            text: "Tests",
                          ),
                          Expanded(
                              child: orders == null && fetchingTests == true
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
                                  : orders == null && fetchingTests == false
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
                                                getTests();
                                              },
                                              child: Text('Retry',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: orders.length,
                                          itemBuilder: (context, count) {
                                            return Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: PopupMenuButton(
                                                      onCanceled: () {
                                                        Provider.of<AuthProvider>(
                                                                context,
                                                                listen: false)
                                                            .resetInactivityTimer();
                                                      },
                                                      child:
                                                          Icon(Icons.more_vert),
                                                      itemBuilder: (context) {
                                                        return [
                                                          PopupMenuItem(
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .remove_red_eye_outlined),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    'Specimen Collection')
                                                              ],
                                                            ),
                                                            value: 'specimen',
                                                          ),
                                                          PopupMenuItem(
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .file_copy_outlined),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    'Report result')
                                                              ],
                                                            ),
                                                            value: 'reporting',
                                                          ),
                                                          PopupMenuItem(
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .verified_outlined),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                    'Result verification')
                                                              ],
                                                            ),
                                                            value:
                                                                'verification',
                                                          ),
                                                        ];
                                                      },
                                                      onSelected:
                                                          (value) async {
                                                        Provider.of<AuthProvider>(
                                                                context,
                                                                listen: false)
                                                            .resetInactivityTimer();
                                                        if (value ==
                                                            'specimen') {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return SpecimenCollection(
                                                                  patient:
                                                                      orders[
                                                                          count],
                                                                );
                                                              });
                                                        } else if (value ==
                                                            'reporting') {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return LabTestResult(
                                                                  patient:
                                                                      orders[
                                                                          count],
                                                                );
                                                              });
                                                        } else if (value ==
                                                            'verification') {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return ResultVerification(
                                                                  patient:
                                                                      orders[
                                                                          count],
                                                                );
                                                              });
                                                        }
                                                      }),
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text("Test"),
                                                      subtitle: Text(
                                                          orders[count]
                                                              .test
                                                              .name),
                                                    )),
                                                    Expanded(
                                                        child: ListTile(
                                                      title:
                                                          Text("Test Status"),
                                                      subtitle: Text(
                                                          orders[count].status),
                                                    )),
                                                  ],
                                                ),
                                                ListTile(
                                                  title: Text("Note"),
                                                  subtitle:
                                                      Text(orders[count].note),
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
                                                            orders[count]
                                                                        .date ==
                                                                    null
                                                                ? "---"
                                                                : convertDateToString(
                                                                    orders[count]
                                                                        .date),
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

class ResultVerification extends StatefulWidget {
  final LaboratoryOrder patient;
  ResultVerification({this.patient});
  @override
  ResultVerificationState createState() => ResultVerificationState();
}

class ResultVerificationState extends State<ResultVerification> {
  TextEditingController note = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: SectionHeader(
        text: "Result Verification",
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              if (note.text.trim() == "") {
                return showBasicMessageDialog("Enter all details", context);
              }
              showPersistentLoadingIndicator(context);
              LaboratoryApi.verifyLabResult({
                "verified_date": DateTime.now().toIso8601String(),
                "verified_by": Provider.of<AuthProvider>(context, listen: false)
                    .serviceProvider
                    .userId,
                // "clinical_lab_test_result_id": ,
                "verification_note": note.text.trim(),
                "result_verified": true
              }).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                showBasicMessageDialog("Result verified", context);
              }).catchError((err) {
                Navigator.pop(context);
                showBasicMessageDialog(err.toString(), context);
              });
            },
            child: Text("Save"))
      ],
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text("Order number"),
                  subtitle: Text(widget.patient.orderNumber.toString()),
                ),
                SizedBox(
                  height: 10,
                ),
                LabeledTextField(
                  text: "Laboratory Note",
                  lines: 3,
                  hintText: "Laboratory  Note",
                  controller: note,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabTestResult extends StatefulWidget {
  final LaboratoryOrder patient;
  LabTestResult({this.patient});
  @override
  LabTestResultState createState() => LabTestResultState();
}

class LabTestResultState extends State<LabTestResult> {
  TextEditingController result = TextEditingController();
  TextEditingController note = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: SectionHeader(
        text: "Lab test result",
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              if (result.text.trim() == "" || note.text.trim() == "") {
                return showBasicMessageDialog("Enter all details", context);
              }
              showPersistentLoadingIndicator(context);
              LaboratoryApi.postLabTestResult({
                "created_date": DateTime.now().toIso8601String(),
                "reported_by": Provider.of<AuthProvider>(context, listen: false)
                    .serviceProvider
                    .userId,
                "clinical_lab_test_id": widget.patient.testId,
                "lab_test_result": result.text.trim(),
                "lab_result_note": note.text.trim()
              }).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                showBasicMessageDialog("Saved", context);
              }).catchError((err) {
                Navigator.pop(context);
                showBasicMessageDialog(err.toString(), context);
              });
            },
            child: Text("Save"))
      ],
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text("Order number"),
                  subtitle: Text(widget.patient.orderNumber.toString()),
                ),
                LabeledTextField(
                  text: "Laboratory Test Result",
                  hintText: "Laboratory Test Result",
                  controller: result,
                ),
                SizedBox(
                  height: 10,
                ),
                LabeledTextField(
                  text: "Laboratory Result Note",
                  lines: 3,
                  hintText: "Laboratory Result Note",
                  controller: note,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpecimenCollection extends StatefulWidget {
  final LaboratoryOrder patient;
  SpecimenCollection({this.patient});
  @override
  _SpecimenCollectionState createState() => _SpecimenCollectionState();
}

class _SpecimenCollectionState extends State<SpecimenCollection> {
  KpMetaData specimenType;
  KpMetaData collectionMode;
  int specimenNumber = 1;
  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider =
        Provider.of<MetadataProvider>(context, listen: true);
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: SectionHeader(
        text: "Specimen Collection",
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              if (collectionMode == null ||
                  specimenType == null ||
                  specimenNumber == null) {
                return showBasicMessageDialog("Enter all details", context);
              }
              showPersistentLoadingIndicator(context);
              LaboratoryApi.postSpecimenCollection({
                "collected_date": DateTime.now().toIso8601String(),
                "collected_by":
                    Provider.of<AuthProvider>(context, listen: false)
                        .serviceProvider
                        .userId,
                "laboratory_test_id": widget.patient.testId,
                "specimen_collection_mode_id": collectionMode.id,
                "specimen_type_id": specimenType.id,
                "specimen_number": specimenNumber
              }).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                showBasicMessageDialog("Saved", context);
              }).catchError((err) {
                Navigator.pop(context);
                showBasicMessageDialog(err.toString(), context);
              });
            },
            child: Text("Save"))
      ],
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text("Order number"),
                  subtitle: Text(widget.patient.orderNumber.toString()),
                ),
                CustomFormDropDown<KpMetaData>(
                  text: 'Specimen Type',
                  initialValue: specimenType,
                  items: metaProvider.genericMetaData['specimentypes'] == null
                      ? null
                      : metaProvider.genericMetaData['specimentypes'].map((e) {
                          return DropdownMenuItem<KpMetaData>(
                              child: Text(e.name), value: e);
                        }).toList(),
                  onChanged: (value) {
                    setState(() {
                      specimenType = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                CustomFormDropDown<KpMetaData>(
                  text: 'Collection Mode',
                  initialValue: collectionMode,
                  items: metaProvider
                              .genericMetaData['specimencollectionmodes'] ==
                          null
                      ? null
                      : metaProvider.genericMetaData['specimencollectionmodes']
                          .map((e) {
                          return DropdownMenuItem<KpMetaData>(
                              child: Text(e.name), value: e);
                        }).toList(),
                  onChanged: (value) {
                    setState(() {
                      collectionMode = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                NumberPicker(
                  initialValue: 1,
                  text: "Specimen Number",
                  onChanged: (number) {
                    specimenNumber = number;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
