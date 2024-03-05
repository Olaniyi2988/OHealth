import 'package:flutter/material.dart';
import 'package:kp/api/programs.dart';
import 'package:kp/models/programs.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/programs_data.dart';
import 'package:kp/views/registration.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class ProgramsView extends StatefulWidget {
  final List<Program> programs;
  final String clientUniqueIdentifier;
  final bool viewMode;
  ProgramsView(
      {this.programs, this.clientUniqueIdentifier, this.viewMode = false});
  @override
  State createState() => ProgramsViewState();
}

class ProgramsViewState extends State<ProgramsView> {
  AssessmentType assessmentType;
  Program seletedProgram;
  ProgramStage selectedStage;
  DateTime date;

  @override
  void initState() {
    widget.programs.sort((a, b) {
      return a.programId.compareTo(b.programId);
    });
    // seletedProgram = widget.programs[0];
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
                            text: widget.viewMode == true
                                ? "View Data"
                                : "Client Service Enrollment",
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomFormDropDown<Program>(
                            text: 'Programs',
                            items: widget.programs.map((program) {
                              return DropdownMenuItem<Program>(
                                value: program,
                                child: Text(program.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .resetInactivityTimer();
                                seletedProgram = value;
                                selectedStage = null;
                              });
                            },
                          ),
                          CustomFormDropDown<ProgramStage>(
                            text: 'Program Stage',
                            value: selectedStage,
                            useExternalValue: true,
                            items: seletedProgram == null
                                ? []
                                : seletedProgram.programStages.map((stage) {
                                    return DropdownMenuItem<ProgramStage>(
                                      value: stage,
                                      child: Text(stage.name),
                                    );
                                  }).toList(),
                            onChanged: (value) {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .resetInactivityTimer();
                              setState(() {
                                selectedStage = value;
                              });
                            },
                          ),
                          widget.viewMode == true
                              ? Container()
                              : CustomDateSelector(
                                  title: "Report Date",
                                  initialDate: date,
                                  onDateChanged: (date) {
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .resetInactivityTimer();
                                    setState(() {
                                      this.date = date;
                                    });
                                  },
                                ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: 60,
                                child: RaisedButton(
                                    onPressed: () {
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .resetInactivityTimer();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Back',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    color: Colors.blueAccent),
                              )),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: 60,
                                child: RaisedButton(
                                    onPressed: selectedStage == null ||
                                            seletedProgram == null ||
                                            (date == null &&
                                                widget.viewMode == false)
                                        ? null
                                        : () async {
                                            Provider.of<AuthProvider>(context,
                                                    listen: false)
                                                .resetInactivityTimer();
                                            showPersistentLoadingIndicator(
                                                context);
                                            Map columns;
                                            try {
                                              columns = await ProgramsApi
                                                  .listDynamicTableColumns(
                                                      selectedStage
                                                          .dbIdentifier,
                                                      returnCache: true);
                                            } catch (err) {
                                              print(err);
                                              Navigator.pop(context);
                                              return showBasicMessageDialog(
                                                  err.toString(), context);
                                            }
                                            if (widget.viewMode == true) {
                                              return ProgramsApi.getDynamicData(
                                                      widget
                                                          .clientUniqueIdentifier,
                                                      selectedStage
                                                          .dbIdentifier)
                                                  .then((data) {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProgramsData(
                                                              programStage:
                                                                  selectedStage,
                                                              program:
                                                                  seletedProgram,
                                                              clientUniqueIdentifier:
                                                                  widget
                                                                      .clientUniqueIdentifier,
                                                              data: data,
                                                            )));
                                              }).catchError((err) {
                                                Navigator.pop(context);
                                                showBasicMessageDialog(
                                                    err.toString(), context);
                                              });
                                            }
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Scaffold(
                                                          appBar: AppBar(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: Text(
                                                                selectedStage
                                                                    .name,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blueAccent)),
                                                          ),
                                                          body:
                                                              DynamicFormDataInfo(
                                                            columns: columns,
                                                            child: DynamicForm(
                                                              config:
                                                                  selectedStage
                                                                      .formJson,
                                                              programStage:
                                                                  selectedStage,
                                                              program:
                                                                  seletedProgram,
                                                              clientUniqueIdentifier:
                                                                  widget
                                                                      .clientUniqueIdentifier,
                                                              reportDate: date,
                                                            ),
                                                          ),
                                                        )));
                                          },
                                    child: Text(
                                      'Next',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    color: Colors.blueAccent),
                              ))
                            ],
                          )
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
