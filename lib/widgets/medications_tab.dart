import 'package:flutter/material.dart';
import 'package:kp/api/pharmacy.dart';
import 'package:kp/models/client.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:async';
import 'package:kp/models/prescription.dart';
import 'package:kp/views/pharmacy_order.dart';

class MedicationsTab extends StatefulWidget {
  final Client client;
  final GlobalKey<MedicationsTabState> key;
  MedicationsTab({this.client, this.key}) : super(key: key);
  @override
  State createState() => MedicationsTabState();
}

List<Prescription> savedPrescription = [];

class MedicationsTabState extends State<MedicationsTab> {
  bool fetchingPrescriptions;
  List<Prescription> prescriptions;

  @override
  void initState() {
    super.initState();
    fetchingPrescriptions = true;
    if (savedPrescription.length > 0) {
      prescriptions = savedPrescription;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedPrescription.length == 0) {
        getPrescriptions();
      }
    });
  }

  Future<void> getPrescriptions() async {
    print('getting prescriptions');
    setState(() {
      fetchingPrescriptions = true;
    });
    try {
      List<Prescription> prescriptions =
          await PharmacyApi.listDrugPrescriptions(widget.client.hospitalNum);
      this.prescriptions = prescriptions;
      setState(() {
        fetchingPrescriptions = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingPrescriptions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (prescriptions != null) {
      prescriptions.sort((a, b) {
        return b.prescriptionDate.compareTo(a.prescriptionDate);
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
                            text: 'Medications',
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  prescriptions = null;
                                  savedPrescription = [];
                                  getPrescriptions();
                                },
                                child: Icon(Icons.refresh),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PharmacyOrder(
                                                client: widget.client,
                                              )));
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
                      prescriptions == null && fetchingPrescriptions == true
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : prescriptions == null &&
                                  fetchingPrescriptions == false
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: RaisedButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        getPrescriptions();
                                      },
                                      child: Text('Retry',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                )
                              : prescriptions.length == 0
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
                                                      prescriptions[count]
                                                          .prescriptionDate),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(prescriptions[count]
                                                    .drug
                                                    .name),
                                                subtitle: Text(
                                                    'Frequency: ${prescriptions[count].drugFrequency.name}\n'
                                                    'Unit: ${prescriptions[count].drugUnits.name}\n'
                                                    'Dose: ${prescriptions[count].dose.toString()}\n'
                                                    'Note: ${prescriptions[count].note}'),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: prescriptions.length,
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
