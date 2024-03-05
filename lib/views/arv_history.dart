import 'package:flutter/material.dart';
import 'package:kp/api/pharmacy.dart';
import 'package:kp/models/client.dart';
import 'package:kp/views/arv.dart';
import 'package:kp/widgets/section_header.dart';

class ArvHistory extends StatefulWidget {
  final Client client;
  ArvHistory({this.client});
  @override
  State createState() => ArvHistoryState();
}

class ArvHistoryState extends State<ArvHistory> {
  List<ArvPayload> arvDispenses;
  bool fetchingPayloads = false;

  @override
  void initState() {
    super.initState();
    fetchingPayloads = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getARV();
    });
  }

  Future<void> getARV() async {
    setState(() {
      fetchingPayloads = true;
    });
    try {
      List<ArvPayload> dispenses =
          await PharmacyApi.listArvDrugDispense(widget.client.hospitalNum);
      setState(() {
        arvDispenses = dispenses;
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var value = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArvDispensing(
                        client: widget.client,
                      )));
          if (value != null) {
            setState(() {
              arvDispenses = null;
            });
            getARV();
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
                  child: arvDispenses == null && fetchingPayloads == true
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent)),
                        )
                      : arvDispenses == null && fetchingPayloads == false
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
                                    getARV();
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
                                    text: "ARV history",
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  ...arvDispenses.map((e) {
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
                                        arvDispenses.length == 1
                                            ? Container()
                                            : Divider(
                                                color: Colors.grey[400],
                                              )
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
