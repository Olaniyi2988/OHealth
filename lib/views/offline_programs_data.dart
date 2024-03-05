import 'package:flutter/material.dart';
import 'package:kp/api/programs.dart';
import 'package:kp/db/programs.dart';
import 'package:kp/db/service_forms.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/programs.dart';
import 'package:kp/util.dart';
import 'package:kp/views/programs_home.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:sembast/sembast.dart';
import 'package:kp/views/patients.dart' as patients;

class OfflineProgramsData extends StatefulWidget {
  OfflineProgramsData();
  @override
  State createState() => OfflineProgramsDataState();
}

class OfflineProgramsDataState extends State<OfflineProgramsData> {
  Stream<List<RecordSnapshot<int, Map<String, dynamic>>>> stream;
  @override
  void initState() {
    ServiceFormsDB.getInstance().getAllFormsSnapshot().then((value) {
      setState(() {
        stream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (stream == null) {
      return Container(
        color: Colors.white,
      );
    }
    return StreamBuilder<List<RecordSnapshot<int, Map<String, dynamic>>>>(
        stream: stream,
        builder: (context, snapshot) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                Client client = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                              appBar: AppBar(
                                iconTheme: IconThemeData(color: Colors.white),
                                title: Text('Select Client'),
                                backgroundColor: Colors.blueAccent,
                              ),
                              body: Padding(
                                padding: EdgeInsets.all(10),
                                child: patients.OnlinePatients(
                                  isSelect: true,
                                ),
                              ),
                            )));
                if (client == null) {
                  return;
                }
                showPersistentLoadingIndicator(context);
                ProgramsApi.getPrograms(returnCache: true).then((programs) {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProgramsMenu(
                                programs: programs,
                                clientUniqueIdentifier: client.hospitalNum,
                              )));
                }).catchError((err) {
                  Navigator.pop(context);
                  showBasicMessageDialog(err.toString(), context);
                });
              },
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    height:
                        (MediaQuery.of(context).size.height - kToolbarHeight) *
                            0.35,
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
                                "Service Forms",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                    ),
                  ),
                  Positioned(
                    child: SizedBox(
                      height: (MediaQuery.of(context).size.height -
                              kToolbarHeight) *
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
                            snapshot.data == null || snapshot.data.length == 0
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SectionHeader(
                                        text: "Saved Form Data",
                                      ),
                                      SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  )
                                : Container(),
                            snapshot.data == null || snapshot.data.length == 0
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 50),
                                      child: Text("Nothing to see here yet"),
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SectionHeader(
                                        text: "Saved Form Data",
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      ...snapshot.data.map((record) {
                                        Map e = record.value;
                                        print(e);
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading:
                                                  Icon(Icons.wysiwyg_outlined),
                                              title: Text(e[
                                                  'client_unique_identifier']),
                                              subtitle: Text(e['formName']),
                                              trailing: SizedBox(
                                                width: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        showPersistentLoadingIndicator(
                                                            context);
                                                        Map columns;
                                                        try {
                                                          columns = await ProgramsApi
                                                              .listDynamicTableColumns(
                                                                  e['formName'],
                                                                  returnCache:
                                                                      true);
                                                          Navigator.pop(
                                                              context);
                                                        } catch (err) {
                                                          Navigator.pop(
                                                              context);
                                                          return showBasicMessageDialog(
                                                              err.toString(),
                                                              context);
                                                        }
                                                        ProgramStage stage =
                                                            await ProgramsDB
                                                                    .getInstance()
                                                                .getProgramStage(
                                                                    e['programId'],
                                                                    e['formName']);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Scaffold(
                                                                          appBar:
                                                                              AppBar(
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            title:
                                                                                Text(e['formName'], style: TextStyle(color: Colors.blueAccent)),
                                                                          ),
                                                                          body:
                                                                              DynamicFormDataInfo(
                                                                            editData:
                                                                                e,
                                                                            columns:
                                                                                columns,
                                                                            child:
                                                                                DynamicForm(
                                                                              config: stage.formJson,
                                                                              programStage: stage,
                                                                              clientUniqueIdentifier: e['client_unique_identifier'],
                                                                              offlineData: true,
                                                                              reportDate: convertStringToDateTime(e['created_date']),
                                                                            ),
                                                                          ),
                                                                        )));
                                                      },
                                                      child: Icon(Icons
                                                          .cloud_upload_outlined),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        bool response =
                                                            await showBasicConfirmationDialog(
                                                                "Delete form?",
                                                                context);
                                                        if (response == false) {
                                                          return;
                                                        }
                                                        showPersistentLoadingIndicator(
                                                            context);
                                                        ServiceFormsDB
                                                                .getInstance()
                                                            .deleteFormData(
                                                                e['formDataId'])
                                                            .then((value) {
                                                          Navigator.pop(
                                                              context);
                                                          showBasicMessageDialog(
                                                              "Service form deleted",
                                                              context);
                                                        }).catchError((err) {
                                                          Navigator.pop(
                                                              context);
                                                          showBasicMessageDialog(
                                                              "Failed to delete",
                                                              context);
                                                        });
                                                      },
                                                      child: Icon(
                                                          Icons.delete_outline),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      }).toList()
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
          );
        });
  }
}
