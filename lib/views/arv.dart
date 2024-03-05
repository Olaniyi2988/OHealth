import 'package:flutter/material.dart';
import 'package:kp/api/pharmacy.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/dispensepattern.dart';
import 'package:kp/models/medication_line.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class ArvDispensing extends StatefulWidget {
  final Client client;
  ArvDispensing({this.client});
  @override
  State createState() => ArvDispensingState();
}

class ArvDispensingState extends State<ArvDispensing> {
  TextEditingController hospitalNumber = TextEditingController();
  List<ArvPayload> prescriptions = [];

  void deleteArv(ArvPayload arv) {
    int toDelete;
    for (int x = 0; x < prescriptions.length; x++) {
      if (prescriptions[x].toString() == arv.toString()) {
        toDelete = x;
      }
    }

    setState(() {
      prescriptions.removeAt(toDelete);
    });
  }

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
                              text: "ARV Drug dispensing",
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
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: Text(e.regimen.name),
                                            subtitle: Text(
                                                'Pickup Date: ${e.pickupDate.day}/${e.pickupDate.month}/${e.pickupDate.year}\n'
                                                'Drug line: ${e.medicationLine.name}\n'
                                                'Duration: ${e.dispensePattern.name}\n'
                                                'Next appointment: ${e.nextAppointmentDate.day}/${e.nextAppointmentDate.month}/${e.nextAppointmentDate.year}'),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    deleteArv(e);
                                                  },
                                                  icon: Icon(
                                                      Icons.delete_outline))
                                            ],
                                          ),
                                          prescriptions.length == 1
                                              ? Container()
                                              : Divider(
                                                  color: Colors.grey[400],
                                                )
                                        ],
                                      );
                                    }).toList(),
                                  ),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: RaisedButton(
                                onPressed: () async {
                                  ArvPayload arvPayload = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.only(
                                              left: 15, right: 15),
                                          content: AddArvDrug(),
                                        );
                                      });
                                  if (arvPayload != null) {
                                    print(arvPayload.pickupDate.toString());
                                    setState(() {
                                      prescriptions.add(arvPayload);
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
                                              showPersistentLoadingIndicator(
                                                  context);
                                              PharmacyApi.postArvDispense(
                                                      prescriptions,
                                                      widget.client.hospitalNum,
                                                      context)
                                                  .then((value) {
                                                Navigator.pop(context);
                                                setState(() {
                                                  prescriptions = null;
                                                  // showBasicMessageDialog(
                                                  //     "Saved!", context);
                                                });
                                                Navigator.pop(context, true);
                                              }).catchError((err) {
                                                Navigator.pop(context);
                                                showBasicMessageDialog(
                                                    err.toString(), context);
                                              });
                                            },
                                      child: Text(
                                        'Save',
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

class AddArvDrug extends StatefulWidget {
  @override
  _AddArvDrugState createState() => _AddArvDrugState();
}

List<MedicationLine> savedLines;
List<DispensePattern> savedPatterns;

class _AddArvDrugState extends State<AddArvDrug> {
  List<MedicationLine> medicationLines;
  List<DispensePattern> dispensePatterns;
  bool fetchingFields;
  bool fieldsFetched = false;

  MedicationLine selectedLine;
  Regimen selectedRegimen;
  DispensePattern selectedPattern;
  DateTime nextAppointmentDate;
  DateTime pickupDate;

  @override
  void initState() {
    super.initState();
    fetchingFields = true;
    if (savedLines != null) {
      medicationLines = savedLines;
    }
    if (savedPatterns != null) {
      dispensePatterns = savedPatterns;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFields(
          background:
              savedLines != null && savedPatterns != null ? true : false);
    });
  }

  void calculateNextAppointment() {
    if (pickupDate == null || selectedPattern == null) return;
    nextAppointmentDate =
        pickupDate.add(Duration(days: selectedPattern.tabletNumber));
  }

  Future<void> getFields({bool background = false}) async {
    print('getting restaurants');
    if (background == false) {
      setState(() {
        fieldsFetched = false;
        fetchingFields = true;
      });
    } else {
      setState(() {
        fieldsFetched = true;
        fetchingFields = false;
      });
    }
    try {
      List<MedicationLine> lines = await PharmacyApi.listMedicationLine();
      savedLines = lines;

      List<DispensePattern> patterns = await PharmacyApi.listDispensePatterns();
      savedPatterns = patterns;

      if (background == false) {
        setState(() {
          this.medicationLines = lines;
          this.dispensePatterns = patterns;
          fetchingFields = false;
          fieldsFetched = true;
        });
      }
    } catch (e) {
      print(e);
      if (background == false) {
        setState(() {
          fetchingFields = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return fieldsFetched == false && fetchingFields == true
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.blueAccent)),
              )
            ],
          )
        : fieldsFetched == false && fetchingFields == false
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      return Colors.blueAccent;
                    })),
                    onPressed: () {
                      getFields();
                    },
                    child: Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        text: "ARV Drug",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomDateSelector(
                        title: "Pickup Date",
                        futureOnly: true,
                        onDateChanged: (date) {
                          setState(() {
                            pickupDate = date;
                            calculateNextAppointment();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomFormDropDown<MedicationLine>(
                        text: "Medication Line",
                        initialValue: selectedLine,
                        value: selectedLine,
                        useExternalValue: true,
                        items: medicationLines.map((e) {
                          return DropdownMenuItem<MedicationLine>(
                            child: Text(e.name),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (line) {
                          setState(() {
                            selectedLine = line;
                            selectedRegimen = null;
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomFormDropDown<Regimen>(
                        text: "Regimen",
                        initialValue: selectedRegimen,
                        value: selectedRegimen,
                        useExternalValue: true,
                        items: selectedLine == null
                            ? []
                            : selectedLine.regimens.map((e) {
                                return DropdownMenuItem<Regimen>(
                                  child: Text(e.name),
                                  value: e,
                                );
                              }).toList(),
                        onChanged: (regimen) {
                          setState(() {
                            selectedRegimen = regimen;
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomFormDropDown<DispensePattern>(
                        text: "Duration",
                        initialValue: selectedPattern,
                        value: selectedPattern,
                        items: dispensePatterns.map((e) {
                          return DropdownMenuItem<DispensePattern>(
                            child: Text(e.name),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (pattern) {
                          setState(() {
                            selectedPattern = pattern;
                            calculateNextAppointment();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomDateSelector(
                        readOnly: true,
                        initialDate: nextAppointmentDate,
                        value: nextAppointmentDate,
                        useExternalValue: true,
                        title: "Next Appointment Date",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel")),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                if (selectedLine == null ||
                                    selectedRegimen == null ||
                                    selectedPattern == null ||
                                    nextAppointmentDate == null ||
                                    pickupDate == null) {
                                  return showBasicMessageDialog(
                                      "Enter all fields", context);
                                }
                                Navigator.pop(
                                    context,
                                    ArvPayload(
                                      medicationLine: selectedLine,
                                      dispensePattern: selectedPattern,
                                      regimen: selectedRegimen,
                                      nextAppointmentDate: nextAppointmentDate,
                                      pickupDate: pickupDate,
                                    ));
                              },
                              child: Text("Add"))
                        ],
                      )
                    ],
                  ),
                ),
              );
  }
}

class ArvPayload {
  MedicationLine medicationLine;
  Regimen regimen;
  DispensePattern dispensePattern;
  DateTime nextAppointmentDate;
  DateTime pickupDate;

  ArvPayload(
      {this.dispensePattern,
      this.regimen,
      this.medicationLine,
      this.pickupDate,
      this.nextAppointmentDate});

  @override
  String toString() {
    return medicationLine.toString() +
        regimen.toString() +
        pickupDate.toString() +
        nextAppointmentDate.toString();
  }
}
