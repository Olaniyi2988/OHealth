import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/number_picker.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:kp/models/prescription.dart';

class PharmacyOrder extends StatefulWidget {
  final Client client;
  PharmacyOrder({this.client});
  @override
  State createState() => PharmacyOrderState();
}

class PharmacyOrderState extends State<PharmacyOrder> {
  TextEditingController hospitalNumber = TextEditingController();
  List<Prescription> prescriptions;

  @override
  void initState() {
    if (widget.client != null) {
      hospitalNumber = TextEditingController(text: widget.client.hospitalNum);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                height: (MediaQuery.of(context).size.height - kToolbarHeight) *
                    0.35,
                color: Colors.blueAccent,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Container()
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                child: SizedBox(
                  height:
                      (MediaQuery.of(context).size.height - kToolbarHeight) *
                          0.8,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.all(15),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              text: "Pharmacy Order Form",
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            LabeledTextField(
                              text: 'Hospital Number',
                              readOnly: widget.client != null,
                              controller: hospitalNumber,
                              validator: (val) {
                                if (val.length == 0) {
                                  return "Enter Hospital Number";
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            prescriptions == null || prescriptions.length == 0
                                ? Container()
                                : Column(
                                    children: prescriptions.map((e) {
                                      return ListTile(
                                        title: Text(e.drug.name),
                                        subtitle: Text(
                                            'Frequency: ${e.drugFrequency.name}\n'
                                            'Unit: ${e.drugUnits.name}\n'
                                            'Dose: ${e.dose.toString()}\n'
                                            'Note: ${e.note}'),
                                      );
                                    }).toList(),
                                  ),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: RaisedButton(
                                onPressed: () async {
                                  Prescription prescription = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        MetadataProvider metaProvider =
                                            Provider.of<MetadataProvider>(
                                                context,
                                                listen: true);

                                        int dosage = 1;
                                        KpMetaData selectedDrug;
                                        KpMetaData selectedDrugFrequency;
                                        KpMetaData selectedDrugUnit;
                                        TextEditingController note =
                                            TextEditingController();
                                        GlobalKey<FormState> formKey =
                                            GlobalKey();

                                        return AlertDialog(
                                          actions: [
                                            RaisedButton(
                                              color: Colors.blueAccent,
                                              onPressed: () {
                                                if (selectedDrug == null ||
                                                    selectedDrugFrequency ==
                                                        null ||
                                                    selectedDrugUnit == null ||
                                                    dosage == null ||
                                                    dosage == 0) {
                                                  showBasicMessageDialog(
                                                      "Missing or incorrect details",
                                                      context);
                                                } else {
                                                  Navigator.pop(
                                                      context,
                                                      new Prescription(
                                                          drugFrequency:
                                                              selectedDrugFrequency,
                                                          dose: dosage,
                                                          drugUnits:
                                                              selectedDrugUnit,
                                                          drug: selectedDrug,
                                                          note: note.text,
                                                          prescriptionDate:
                                                              DateTime.now()));
                                                }
                                              },
                                              child: Text(
                                                'Add',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            RaisedButton(
                                              color: Colors.blueAccent,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                          title: SectionHeader(
                                            text: "Prescription",
                                          ),
                                          content: Form(
                                            key: formKey,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                  ),
                                                  CustomFormDropDown<
                                                      KpMetaData>(
                                                    text: 'Drug',
                                                    items: metaProvider
                                                                    .genericMetaData[
                                                                'drugs'] ==
                                                            null
                                                        ? null
                                                        : metaProvider
                                                            .genericMetaData[
                                                                'drugs']
                                                            .map((testType) {
                                                            return DropdownMenuItem<
                                                                KpMetaData>(
                                                              value: testType,
                                                              child: Text(
                                                                  testType
                                                                      .name),
                                                            );
                                                          }).toList(),
                                                    initialValue: selectedDrug,
                                                    onChanged: (value) {
                                                      selectedDrug = value;
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  CustomFormDropDown<
                                                      KpMetaData>(
                                                    text: 'Frequency',
                                                    items: metaProvider
                                                                    .genericMetaData[
                                                                'drugfrequency'] ==
                                                            null
                                                        ? null
                                                        : metaProvider
                                                            .genericMetaData[
                                                                'drugfrequency']
                                                            .map((testType) {
                                                            return DropdownMenuItem<
                                                                KpMetaData>(
                                                              value: testType,
                                                              child: Text(
                                                                  testType
                                                                      .name),
                                                            );
                                                          }).toList(),
                                                    initialValue:
                                                        selectedDrugFrequency,
                                                    onChanged: (value) {
                                                      selectedDrugFrequency =
                                                          value;
                                                    },
                                                  ),
                                                  CustomFormDropDown<
                                                      KpMetaData>(
                                                    text: 'Unit',
                                                    items: metaProvider
                                                                    .genericMetaData[
                                                                'drugunits'] ==
                                                            null
                                                        ? null
                                                        : metaProvider
                                                            .genericMetaData[
                                                                'drugunits']
                                                            .map((testType) {
                                                            return DropdownMenuItem<
                                                                KpMetaData>(
                                                              value: testType,
                                                              child: Text(
                                                                  testType
                                                                      .name),
                                                            );
                                                          }).toList(),
                                                    initialValue:
                                                        selectedDrugUnit,
                                                    onChanged: (value) {
                                                      selectedDrugUnit = value;
                                                    },
                                                  ),
                                                  NumberPicker(
                                                    text: 'Dosage',
                                                    initialValue: dosage,
                                                    onChanged: (val) {
                                                      dosage = val;
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  LabeledTextField(
                                                    text: 'Prescription Note',
                                                    controller: note,
                                                    lines: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                  if (prescriptions == null) {
                                    prescriptions = [];
                                  }
                                  if (prescription != null) {
                                    setState(() {
                                      prescriptions.add(prescription);
                                    });
                                  }
                                },
                                color: Colors.blueAccent,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Add prescriptions",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: SizedBox(
                                  height: 60,
                                  child: RaisedButton(
                                      onPressed: () {
                                        Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .resetInactivityTimer();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Back',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      color: Colors.blueAccent),
                                )),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                    child: SizedBox(
                                  height: 60,
                                  child: RaisedButton(
                                      onPressed: prescriptions == null
                                          ? null
                                          : () async {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .resetInactivityTimer();
                                              bool value =
                                                  await showBasicConfirmationDialog(
                                                      "Do you want to add the prescriptions?",
                                                      context);
                                              if (value) {
                                                try {
                                                  showPersistentLoadingIndicator(
                                                      context);
                                                  List payloadTemp =
                                                      prescriptions.map((e) {
                                                    Map temp = e.toJson();
                                                    temp.putIfAbsent(
                                                        'client_unique_identifier',
                                                        () => hospitalNumber
                                                            .text);
                                                    temp.putIfAbsent(
                                                        'prescribed_by_id',
                                                        () => Provider.of<
                                                                    AuthProvider>(
                                                                context,
                                                                listen: false)
                                                            .serviceProvider
                                                            .userId);
                                                    return temp;
                                                  }).toList();

                                                  String payload = JsonEncoder()
                                                      .convert(payloadTemp);
                                                  print(payload);
                                                  http.Response response =
                                                      await RequestMiddleWare.makeRequest(
                                                          url: endPointBaseUrl +
                                                              '/postclinicaldrugprescription',
                                                          method: RequestMethod.POST,
                                                          body: payload,
                                                          headers: {
                                                        "Content-Type":
                                                            "application/json"
                                                      });
                                                  Navigator.pop(context);
                                                  if (response.statusCode ==
                                                      200) {
                                                    Navigator.pop(
                                                        context, true);
                                                  } else {
                                                    showBasicMessageDialog(
                                                        "Error adding. Check details entered",
                                                        context);
                                                  }
                                                } on SocketException catch (err) {
                                                  print(err);
                                                  showBasicMessageDialog(
                                                      'Connection Error',
                                                      context);
                                                } catch (err) {
                                                  print(err);
                                                  showBasicMessageDialog(
                                                      'Something went wrong',
                                                      context);
                                                }
                                              }
                                            },
                                      child: Text(
                                        'Next',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      color: Colors.blueAccent),
                                ))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )),
                ),
                top: (MediaQuery.of(context).size.height - kToolbarHeight) *
                    0.15,
                left: MediaQuery.of(context).size.width * 0.15 / 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
