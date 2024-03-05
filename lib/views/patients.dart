import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kp/api/clients_api.dart';
import 'package:kp/db/clients.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/client_search.dart';
import 'package:kp/widgets/client_portal_view_holder.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/patient_tile.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';

class PatientsView extends StatefulWidget {
  @override
  State createState() => PatientsViewState();
}

class PatientsViewState extends State<PatientsView> {
  List<Client> offlineClients;
  StreamSubscription subscription;
  bool showSearchingModal = false;
  TextEditingController controller = new TextEditingController();
  String selectedView = "online";
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      Provider.of<AuthProvider>(context, listen: false).resetInactivityTimer();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ClientsDB.getInstance().getAllClientsSnapshot().then((value) {
        if (value != null) {
          subscription = value.listen((event) {
            List<RecordSnapshot<int, Map<String, dynamic>>> clients = event;
            List<Client> temp = [];
            clients.forEach((recordSnap) {
              temp.add(Client.fromDBJson(recordSnap.value));
            });
            setState(() {
              this.offlineClients = temp;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        color: Colors.white,
        height: constraint.maxHeight,
        width: constraint.maxWidth,
        child: DefaultTabController(
          length: 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: DropdownButton<String>(
                            underline: Container(),
                            items: [
                              DropdownMenuItem(
                                  child: Text('Online Clients',
                                      style:
                                          TextStyle(color: Colors.blueAccent)),
                                  value: 'online'),
                              DropdownMenuItem(
                                child: Text('Pending Client Uploads',
                                    style: TextStyle(color: Colors.blueAccent)),
                                value: 'offline',
                              ),
                            ],
                            onChanged: (selected) {
                              if (selectedView == selected) {
                                return;
                              }
                              setState(() {
                                selectedView = selected;
                              });
                            },
                            value: selectedView,
                            // dropdownColor: Colors.blueAccent,
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                selectedView == "online"
                    ? Expanded(child: OnlinePatients())
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RaisedButton(
                              onPressed: offlineClients == null
                                  ? null
                                  : offlineClients.length == 0
                                      ? null
                                      : () async {
                                          bool val =
                                              await showBasicConfirmationDialog(
                                                  "Are you sure you want to upload all registrations?",
                                                  context);
                                          if (val == true) {
                                            showPersistentLoadingIndicator(
                                                context);
                                            List<
                                                Client> clients = await ClientsDB
                                                    .getInstance()
                                                .getClients(Finder(
                                                    filter: Filter.equals(
                                                        'is_registered_online',
                                                        false)));
                                            print(
                                                "uploading ${clients.length} clients");
                                            ClientApi
                                                    .postClinicalRegistrationBulk(
                                                        clients, context)
                                                .then((value) {
                                              Navigator.pop(context);
                                            }).catchError((err) {
                                              Navigator.pop(context);
                                              showBasicMessageDialog(
                                                  err.toString(), context);
                                            });
                                          }
                                        },
                              child: Text(
                                'Register All',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.blueAccent,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                                child: offlineClients == null
                                    ? Center(
                                        child: SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : offlineClients.length == 0 &&
                                            controller.text.trim().length == 0
                                        ? Center(
                                            child:
                                                Text('Nothing to see here yet'),
                                          )
                                        : offlineClients.length == 0 &&
                                                controller.text.trim().length >
                                                    0
                                            ? Center(
                                                child: Text(
                                                    'No patients matches the search parameter'),
                                              )
                                            : Container(
                                                child: ListView.builder(
                                                    itemBuilder:
                                                        (context, count) {
                                                      return ClientTile(
                                                        isSelect: false,
                                                        offline: true,
                                                        client: offlineClients[
                                                            count],
                                                      );
                                                    },
                                                    itemCount:
                                                        offlineClients.length),
                                              ))
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class OnlinePatients extends StatefulWidget {
  final bool isSelect;
  OnlinePatients({this.isSelect = false});
  @override
  State createState() => OnlinePatientsState();
}

List<Client> savedClients = [];

class OnlinePatientsState extends State<OnlinePatients> {
  ScrollController scrollController = new ScrollController();
  TextEditingController controller = TextEditingController();
  List<Client> clients;
  List<Client> matchedClients;
  bool fetchingClients = true;
  String orderBy = "name";

  Duration selectedDuration = Duration(days: 30);

  @override
  void initState() {
    super.initState();
    fetchingClients = true;
    // if (savedClients.length > 0) {
    //   getClients();
    //   clients = savedClients;
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedClients.length == 0) {
        getClients();
      }
    });

    scrollController.addListener(() {
      Provider.of<AuthProvider>(context, listen: false).resetInactivityTimer();
    });
  }

  Future<void> getClients() async {
    print('getting clients');
    setState(() {
      clients = null;
      fetchingClients = true;
    });
    try {
      List<Client> clients =
          await ClientApi.listClinicalRegistration(selectedDuration.inDays);
      setState(() {
        fetchingClients = false;
        this.clients = clients;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingClients = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
                    getClients();
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
                                    isSelect: widget.isSelect,
                                  )));
                      if (selected != null) {
                        if (widget.isSelect) {
                          Navigator.pop(context, selected);
                        }
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
            child: Padding(
          padding: EdgeInsets.all(0),
          child: clients == null && fetchingClients == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : clients == null && fetchingClients == false
                  ? Center(
                      child: RaisedButton(
                        color: Colors.blueAccent,
                        onPressed: () {
                          getClients();
                        },
                        child: Text('Retry',
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : clients.length == 0
                      ? Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              "Nothing to see here yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          child: ListView.builder(
                              itemBuilder: (context, count) {
                                return ClientTile(
                                  isSelect: widget.isSelect,
                                  client: clients[count],
                                );
                              },
                              itemCount: clients.length),
                          onRefresh: () async {
                            await getClients();
                          }),
        )),
      ],
    );
  }
}

class ClientTile extends StatelessWidget {
  final bool isSelect;
  final Client client;
  final bool offline;

  ClientTile({this.client, this.isSelect, this.offline = false});

  @override
  Widget build(BuildContext context) {
    if (offline) {
      client.isRegisteredOnline = false;
    }
    Function onTap;
    if (isSelect == true) {
      onTap = () {
        Navigator.pop(context, client);
      };
    } else {
      onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClientPortalViewHolder(
                      client,
                    )));
      };
    }
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                  child: ListTile(
                title: Text(
                  client.hospitalNum,
                  style: TextStyle(fontSize: 12),
                ),
              )),
              Expanded(
                  child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                        child: Text(
                      client.email == null ? "---" : client.email,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )),
                    offline == true && client.biometricsUploadFailed == true
                        ? Container()
                        : isSelect == true
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: ClientOptions(
                                  isDashboard: true,
                                  client: client,
                                ),
                              )
                  ],
                ),
              ))
            ],
          ),
        ),
        offline == false
            ? Container()
            : offline == true &&
                    (client.biometricsUploadFailed == false ||
                        client.biometricsUploadFailed == null)
                ? Container()
                : ListTile(
                    title: Text(
                      "Biometrics upload failed. Retry",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        showPersistentLoadingIndicator(context);
                        ClientApi.uploadBiometrics(
                                client.biometrics, client.hospitalNum, context)
                            .then((value) {
                          Navigator.pop(context);
                          ClientsDB.getInstance()
                              .deleteClient(client.localDBIdentifier);
                        }).catchError((err) {
                          Navigator.pop(context);
                          showBasicMessageDialog(err.toString(), context);
                        });
                      },
                      icon: Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
        Divider(
          color: Colors.black54,
        )
      ],
    );
  }
}
