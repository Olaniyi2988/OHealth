import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kp/api/lab.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/lab.dart';
import 'package:kp/models/lab_order.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/client_lab_order.dart';
import 'package:kp/views/client_search.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class LabHome extends StatefulWidget {
  @override
  State createState() => LabHomeState();
}

class LabHomeState extends State<LabHome> {
  List<LaboratoryOrder> clients;
  bool fetchingClients;
  Timer timer;

  Duration selectedDuration = Duration(days: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // getClients();
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (clients == null &&
            (fetchingClients == null || fetchingClients == false)) {
          if (Provider.of<MetadataProvider>(context, listen: false).tests !=
              null) {
            getClients();
          }
        } else if (clients != null) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> getClients() async {
    print('getting clients');
    setState(() {
      fetchingClients = true;
    });
    try {
      clients = await LabApi.listTests(context);
      setState(() {
        fetchingClients = false;
      });
    } catch (e) {
      setState(() {
        fetchingClients = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
                    builder: (context) => ClientLabOrders(selected)));
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
                            child: LabeledTextField(
                              readOnly: true,
                              hintText: "Search client",
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
                                              ClientLabOrders(selected)));
                                }
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
                                                ClientLabOrders(selected)));
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
                            text: "Lab",
                          ),
                          Expanded(
                              child: clients == null &&
                                      (fetchingClients == true ||
                                          fetchingClients == null)
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
                                  : clients == null && fetchingClients == false
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
                                                getClients();
                                              },
                                              child: Text('Retry',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: clients.length,
                                          itemBuilder: (context, count) {
                                            return InkWell(
                                              onTap: () {},
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: Text(clients[count]
                                                        .hospitalNumber),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: ListTile(
                                                        title: Text("Test"),
                                                        subtitle: Text(
                                                            clients[count]
                                                                .test
                                                                .name),
                                                      )),
                                                      Expanded(
                                                          child: ListTile(
                                                        title:
                                                            Text("Test Status"),
                                                        subtitle: Text(
                                                            clients[count]
                                                                .status),
                                                      )),
                                                    ],
                                                  ),
                                                  ListTile(
                                                    title: Text("Note"),
                                                    subtitle: Text(
                                                        clients[count].note),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        clients[count].date ==
                                                                null
                                                            ? ""
                                                            : convertDateToString(
                                                                clients[count]
                                                                    .date),
                                                        style: TextStyle(
                                                            fontSize: 12,
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
