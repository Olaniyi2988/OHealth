import 'package:flutter/material.dart';
import 'package:kp/api/programs.dart';
import 'package:kp/models/programs.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:kp/widgets/section_header.dart';

class ProgramsData extends StatefulWidget {
  final ProgramStage programStage;
  final Program program;
  final String clientUniqueIdentifier;
  final List data;
  ProgramsData(
      {this.programStage,
      this.clientUniqueIdentifier,
      this.data,
      this.program});
  @override
  State createState() => ProgramsDataState();
}

class ProgramsDataState extends State<ProgramsData> {
  List data;

  @override
  void initState() {
    data = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          widget.clientUniqueIdentifier,
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
                            text: widget.programStage.name,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ...data.map((e) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.wysiwyg_outlined),
                                  title: Text(e['created_date'].split(' ')[0]),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            showPersistentLoadingIndicator(
                                                context);
                                            Map columns;
                                            try {
                                              columns = await ProgramsApi
                                                  .listDynamicTableColumns(
                                                      widget.programStage
                                                          .dbIdentifier);
                                              Navigator.pop(context);
                                            } catch (err) {
                                              Navigator.pop(context);
                                              return showBasicMessageDialog(
                                                  err.toString(), context);
                                            }
                                            var updatedData =
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                              appBar: AppBar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                title: Text(
                                                                    widget
                                                                        .programStage
                                                                        .name,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blueAccent)),
                                                              ),
                                                              body:
                                                                  DynamicFormDataInfo(
                                                                editData: e,
                                                                columns:
                                                                    columns,
                                                                child:
                                                                    DynamicForm(
                                                                  config: widget
                                                                      .programStage
                                                                      .formJson,
                                                                  programStage:
                                                                      widget
                                                                          .programStage,
                                                                  program: widget
                                                                      .program,
                                                                  clientUniqueIdentifier:
                                                                      widget
                                                                          .clientUniqueIdentifier,
                                                                  editMode:
                                                                      true,
                                                                  // reportDate: date,
                                                                ),
                                                              ),
                                                            )));
                                            if (updatedData != null) {
                                              int updateIndex = -1;
                                              for (int x = 0;
                                                  x < data.length;
                                                  x++) {
                                                if (data[x]['id'] ==
                                                    updatedData['id']) {
                                                  updateIndex = x;
                                                }
                                              }
                                              setState(() {
                                                data[updateIndex] = updatedData;
                                              });
                                            }
                                          },
                                          child: Icon(Icons.edit),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            bool response =
                                                await showBasicConfirmationDialog(
                                                    "Delete form?", context);
                                            if (response == false) {
                                              return;
                                            }
                                            showPersistentLoadingIndicator(
                                                context);
                                            Map<String, dynamic> payload = {
                                              ...e
                                            };
                                            e['client_unique_identifier'] =
                                                widget.clientUniqueIdentifier;
                                            e['submit'] = true;
                                            e['formName'] = widget
                                                .programStage.dbIdentifier;
                                            return ProgramsApi
                                                    .removeDynamicTableData(
                                                        payload)
                                                .then((val) {
                                              if (val == true) {
                                                int toDeleteIndex = -1;
                                                for (int x = 0;
                                                    x < data.length;
                                                    x++) {
                                                  if (data[x]['id'] ==
                                                      payload['id']) {
                                                    toDeleteIndex = x;
                                                  }
                                                }
                                                setState(() {
                                                  data.removeAt(toDeleteIndex);
                                                });
                                                Navigator.pop(context);
                                                showBasicMessageDialog(
                                                    "Form deleted!", context);
                                              }
                                            }).catchError((err) {
                                              Navigator.pop(context);
                                              showBasicMessageDialog(
                                                  err.toString(), context);
                                            });
                                          },
                                          child: Icon(Icons.delete_outline),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(),
                              ],
                            );
                          }).toList(),
                          data == null || data.length == 0
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 50),
                                    child: Text("Nothing to see here yet"),
                                  ),
                                )
                              : Container()
                        ],
                      )
                    ],
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
