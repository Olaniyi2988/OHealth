import 'package:flutter/material.dart';
import 'package:kp/api/clinics_api.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/clinical_service.dart';
import 'package:kp/util.dart';
import 'package:kp/views/clinics_home.dart';
import 'package:kp/widgets/section_header.dart';

class ClientVisitHistory extends StatefulWidget {
  final Client client;
  ClientVisitHistory(this.client);
  @override
  State createState() => ClientVisitHistoryState();
}

class ClientVisitHistoryState extends State<ClientVisitHistory> {
  List<ClinicalService> services;
  bool fetchingServices = false;
  List<String> metaDataRequired = [
    'pregnancy',
    'healthstatus',
    'functionalstatus',
    'clinicalstages',
    'opportunisticinfections',
    'levelofadherence'
  ];

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
          await ClinicsAPi.listClinicalServicesByHospitalNumber(
              widget.client.hospitalNum);
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
        child: Icon(Icons.add),
        onPressed: () async {
          var response = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  insetPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  content: ClinicVisit(widget.client),
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
                            text: "Visit History",
                          ),
                          Expanded(
                              child: (services == null &&
                                          fetchingServices == true) ||
                                      checkAllMetaDataAvailable(
                                              metaDataRequired, context) ==
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
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text(
                                                          "Clinical Stage"),
                                                      subtitle: Text(
                                                          findMetaDataFromId(
                                                                  "clinicalstages",
                                                                  services[
                                                                          count]
                                                                      .clinicalStageId,
                                                                  context)
                                                              .name
                                                              .toString()),
                                                    )),
                                                    Expanded(
                                                        child: ListTile(
                                                      title:
                                                          Text("Health status"),
                                                      subtitle: Text(
                                                          findMetaDataFromId(
                                                                  "healthstatus",
                                                                  services[
                                                                          count]
                                                                      .tbStatusId,
                                                                  context)
                                                              .name
                                                              .toString()),
                                                    )),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ListTile(
                                                        title: Text("Height"),
                                                        subtitle: Text(
                                                            services[count]
                                                                .height
                                                                .toString()),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: ListTile(
                                                        title: Text("Weight"),
                                                        subtitle: Text(
                                                            services[count]
                                                                .weight
                                                                .toString()),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ListTile(
                                                        title: Text("Systolic"),
                                                        subtitle: Text(
                                                            services[count]
                                                                .systolic
                                                                .toString()),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: ListTile(
                                                        title:
                                                            Text("Diastolic"),
                                                        subtitle: Text(
                                                            services[count]
                                                                .diastolic
                                                                .toString()),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                ListTile(
                                                  title: Text("Clinical Note"),
                                                  subtitle: Text(services[count]
                                                      .clinicalNote
                                                      .toString()),
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
                                                          fontSize: 12,
                                                          color: Colors.grey),
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
