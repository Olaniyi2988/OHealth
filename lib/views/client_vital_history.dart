import 'package:flutter/material.dart';
import 'package:kp/api/clinics_api.dart';
import 'package:kp/api/consultation_api.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/vitals.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/number_picker.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:kp/widgets/vitals_card.dart';
import 'package:provider/provider.dart';

class ClientVitalsHistory extends StatefulWidget {
  final Client client;
  ClientVitalsHistory(this.client);
  @override
  State createState() => ClientVitalsHistoryState();
}

class ClientVitalsHistoryState extends State<ClientVitalsHistory> {
  List<Vitals> vitals;
  bool fetchingVitals = false;

  @override
  void initState() {
    super.initState();
    fetchingVitals = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getServices();
    });
  }

  Future<void> getServices() async {
    setState(() {
      fetchingVitals = true;
      vitals = null;
    });
    try {
      List<Vitals> vitals =
          await ClinicsAPi.getVitals(widget.client.hospitalNum);
      setState(() {
        this.vitals = vitals;
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
                  content: AddVitalsDialog(client: widget.client),
                );
              });
          if (response != null) {
            getServices();
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
                            text: "Vitals",
                          ),
                          Expanded(
                              child: vitals == null && fetchingVitals == true
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
                                  : vitals == null && fetchingVitals == false
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
                                          itemCount: vitals.length,
                                          itemBuilder: (context, count) {
                                            return VitalsCard(
                                              vitals: vitals[count],
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

class AddVitalsDialog extends StatefulWidget {
  final Client client;
  AddVitalsDialog({this.client});
  @override
  _AddVitalsDialogState createState() => _AddVitalsDialogState();
}

class _AddVitalsDialogState extends State<AddVitalsDialog> {
  DateTime dateOfVital;
  int pulse = 0;
  int respiratoryRate = 0;
  int temperature = 0;
  int weight = 0;
  int height = 0;
  int systolicPressure = 0;
  int diastolicPressure = 0;

  @override
  Widget build(BuildContext context) {
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
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  SizedBox(
                    width: 15,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (height == null ||
                          respiratoryRate == null ||
                          pulse == null ||
                          temperature == null ||
                          weight == null ||
                          systolicPressure == null ||
                          diastolicPressure == null ||
                          dateOfVital == null) {
                        return showBasicMessageDialog(
                            "Enter empty fields", context);
                      }

                      if (await showBasicConfirmationDialog(
                              "Save vitals?", context) ==
                          false) {
                        return;
                      }

                      showPersistentLoadingIndicator(context);
                      ConsultationApi.postClinicalVitals(widget.client, {
                        'height': height,
                        'respiratory_rate': respiratoryRate,
                        'pulse': pulse,
                        'temperature': temperature,
                        'weight': weight,
                        'systolic': systolicPressure,
                        'diastolic': diastolicPressure,
                        'client_unique_identifier': widget.client.hospitalNum,
                        'created_date': dateOfVital.toIso8601String(),
                        'created_by':
                            Provider.of<AuthProvider>(context, listen: false)
                                .serviceProvider
                                .userId,
                      }).then((val) {
                        Navigator.pop(context, true);
                        Navigator.pop(context, true);
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
