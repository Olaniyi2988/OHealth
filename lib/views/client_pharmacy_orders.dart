import 'package:flutter/material.dart';
import 'package:kp/api/pharmacy.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/models/prescription.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/pharmacy_order.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class ClientPharmacyHistory extends StatefulWidget {
  final Client client;
  ClientPharmacyHistory({this.client});
  @override
  State createState() => ClientPharmacyHistoryState();
}

class ClientPharmacyHistoryState extends State<ClientPharmacyHistory> {
  List<Prescription> prescriptions;
  bool fetchingPayloads = false;

  @override
  void initState() {
    super.initState();
    fetchingPayloads = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPrescriptions();
    });
  }

  Future<void> getPrescriptions() async {
    setState(() {
      fetchingPayloads = true;
    });
    try {
      List<Prescription> dispenses =
          await PharmacyApi.listDrugPrescriptions(widget.client.hospitalNum);
      setState(() {
        prescriptions = dispenses;
        fetchingPayloads = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingPayloads = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MetadataProvider metadataProvider =
        Provider.of<MetadataProvider>(context, listen: true);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var value = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PharmacyOrder(
                        client: widget.client,
                      )));
          if (value != null) {
            setState(() {
              prescriptions = null;
            });
            getPrescriptions();
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
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.all(15),
                  child: (prescriptions == null && fetchingPayloads == true) ||
                          (metadataProvider.getMetaFromString("drugunits") ==
                                  null ||
                              metadataProvider
                                      .getMetaFromString("drugfrequency") ==
                                  null)
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent)),
                        )
                      : prescriptions == null && fetchingPayloads == false
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: ElevatedButton(
                                  style: ButtonStyle(backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    return Colors.blueAccent;
                                  })),
                                  onPressed: () {
                                    getPrescriptions();
                                  },
                                  child: Text('Retry',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionHeader(
                                    text: "Pharmacy history",
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  ...prescriptions.map((e) {
                                    KpMetaData drugFrequency;
                                    KpMetaData drugUnit;
                                    KpMetaData drug;

                                    metadataProvider
                                        .getMetaFromString("drugfrequency")
                                        .forEach((element) {
                                      if (element.id == e.drugFrequencyId) {
                                        drugFrequency = element;
                                      }
                                    });

                                    metadataProvider
                                        .getMetaFromString("drugunits")
                                        .forEach((element) {
                                      if (element.id == e.drugUnitId) {
                                        drugUnit = element;
                                      }
                                    });

                                    metadataProvider
                                        .getMetaFromString("drugs")
                                        .forEach((element) {
                                      if (element.id == e.drugId) {
                                        drug = element;
                                      }
                                    });

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ListTile(
                                              title: Text("Drug"),
                                              subtitle: Text(drug.name),
                                            )),
                                            Expanded(
                                                child: ListTile(
                                              title: Text("Unit"),
                                              subtitle: Text(drugUnit.name),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ListTile(
                                              title: Text("Frequency"),
                                              subtitle:
                                                  Text(drugFrequency.name),
                                            )),
                                            Expanded(
                                                child: ListTile(
                                              title: Text("Dose"),
                                              subtitle: Text(e.dose.toString()),
                                            )),
                                          ],
                                        ),
                                        ListTile(
                                          title: Text("Note"),
                                          subtitle: Text(e.note),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    convertDateToString(
                                                        e.prescriptionDate),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Divider()
                                      ],
                                    );
                                  }).toList()
                                ],
                              ),
                            ),
                )),
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
