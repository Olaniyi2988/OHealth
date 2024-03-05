import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/api/clients_api.dart';
import 'package:kp/db/search_history.dart';
import 'package:kp/models/client.dart';
import 'package:kp/util.dart';
import 'package:kp/views/patients.dart';
import 'package:sembast/sembast.dart';

class ClientSearch extends StatefulWidget {
  final bool isSelect;
  ClientSearch({this.isSelect = false});
  @override
  State createState() => ClientSearchState();
}

class ClientSearchState extends State<ClientSearch> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<Client> clients;
  bool fetchingClients = false;
  bool showSearchHistory = true;
  TextEditingController searchController = TextEditingController();

  Future<List<Client>> getClients(String hospitalNumber) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    clients = null;
    setState(() {
      fetchingClients = true;
    });
    try {
      List<Client> clients =
          await ClientApi.listClinicalRegistrationByHospitalNum(hospitalNumber);
      setState(() {
        fetchingClients = false;
      });
      return clients;
    } catch (e) {
      setState(() {
        fetchingClients = false;
      });
      throw (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          setState(() {
            showSearchHistory = false;
          });
        },
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: 5,
                    right: 15,
                    bottom: showSearchHistory == true ? 0 : 10,
                    top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.keyboard_backspace,
                        size: 35,
                      ),
                      onTap: () {
                        if (showSearchHistory == true) {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            showSearchHistory = false;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onTap: () {
                        setState(() {
                          showSearchHistory = true;
                        });
                      },
                      onFieldSubmitted: (text) async {
                        if (text.trim().length == 0) {
                          return;
                        }
                        SearchHistoryDB.getInstance().addHistory(text, context);
                        getClients(text.toUpperCase()).then((value) {
                          setState(() {
                            clients = value;
                            showSearchHistory = false;
                          });
                        }).catchError((err) {
                          showBasicMessageDialog(err.toString(), context);
                        });
                      },
                      controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search Client",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent)),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    )),
                    showSearchHistory == true
                        ? Container()
                        : SizedBox(
                            width: 10,
                          ),
                  ],
                ),
              )),
              showSearchHistory == true && fetchingClients == false
                  ? Expanded(
                      child: FutureBuilder<
                          Stream<
                              List<RecordSnapshot<int, Map<String, dynamic>>>>>(
                      future:
                          SearchHistoryDB.getInstance().getAllHistorySnapshot(),
                      builder: (context, asyncSnapshot) {
                        if (!asyncSnapshot.hasData) return Container();

                        return StreamBuilder<
                            List<RecordSnapshot<int, Map<String, dynamic>>>>(
                          stream: asyncSnapshot.data,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            snapshot.data.sort((a, b) {
                              return b.key.compareTo(a.key);
                            });
                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, count) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          searchController.text = snapshot
                                              .data[count].value['value'];
                                          getClients(snapshot
                                                  .data[count].value['value']
                                                  .toUpperCase())
                                              .then((value) {
                                            setState(() {
                                              clients = value;
                                              showSearchHistory = false;
                                            });
                                          }).catchError((err) {
                                            showBasicMessageDialog(
                                                err.toString(), context);
                                          });
                                        },
                                        title: Text(snapshot
                                            .data[count].value['value']),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  SearchHistoryDB.getInstance()
                                                      .deleteHistory(
                                                          snapshot.data[count]);
                                                },
                                                icon: Icon(Icons.close)),
                                            IconButton(
                                                onPressed: () {
                                                  searchController.text =
                                                      snapshot.data[count]
                                                          .value['value'];
                                                },
                                                icon: Icon(Icons.north_west))
                                          ],
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  );
                                });
                          },
                        );
                      },
                    ))
                  : fetchingClients == false &&
                          clients != null &&
                          clients.length > 0
                      ? Column(
                          children: [
                            // Padding(
                            //   padding: EdgeInsets.only(left: 10, right: 10),
                            //   child: Text(
                            //     "Results",
                            //     style: TextStyle(fontSize: 18),
                            //   ),
                            // ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        )
                      : Container(),
              showSearchHistory == true && fetchingClients == false
                  ? Container()
                  : clients != null && clients.length == 0
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 200),
                            child: Text(
                              "No match found",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 20),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            fetchingClients == true
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 100),
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.blueAccent)),
                                    ),
                                  )
                                : clients == null && fetchingClients == false
                                    ? Container(
                                        color: Colors.grey[200],
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: clients.map((e) {
                                            return ClientTile(
                                              isSelect: widget.isSelect,
                                              client: e,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                            Container(
                              height: 200,
                            )
                          ],
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
