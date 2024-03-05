import 'package:flutter/material.dart';
import 'package:kp/api/lab.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/lab.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class LabOrder extends StatefulWidget {
  final Client client;
  LabOrder({this.client});
  @override
  State createState() => LabOrderState();
}

class LabOrderState extends State<LabOrder> {
  LabTestType selectedType;
  LabTest selectedTest;
  List<LabTest> testsDropdown;
  TextEditingController hospitalNumber = TextEditingController();
  TextEditingController note = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    if (widget.client != null) {
      hospitalNumber = TextEditingController(text: widget.client.hospitalNum);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<LabTestType> testTypes = context
        .select((MetadataProvider metaProvider) => metaProvider.testTypes);
    List<LabTest> tests =
        context.select((MetadataProvider metaProvider) => metaProvider.tests);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                height: (MediaQuery.of(context).size.height - kToolbarHeight) *
                    0.35,
                color: Colors.blueAccent,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Container()
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                child: SizedBox(
                  height:
                      (MediaQuery.of(context).size.height - kToolbarHeight) *
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
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                text: "Laboratory Order Form",
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              CustomFormDropDown<LabTestType>(
                                text: 'Test Type',
                                items: testTypes == null
                                    ? null
                                    : testTypes.map((testType) {
                                        return DropdownMenuItem<LabTestType>(
                                          value: testType,
                                          child: Text(testType.name),
                                        );
                                      }).toList(),
                                useExternalValue: true,
                                initialValue: selectedType,
                                value: selectedType,
                                onChanged: (value) {
                                  setState(() {
                                    selectedType = value;
                                    selectedTest = null;
                                    testsDropdown = [];
                                    if (tests != null) {
                                      tests.forEach((element) {
                                        if (element.labTestTypeId ==
                                            selectedType.labTestTypeId) {
                                          testsDropdown.add(element);
                                        }
                                      });
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomFormDropDown<LabTest>(
                                text: 'Test',
                                items: testsDropdown == null
                                    ? null
                                    : testsDropdown.map((test) {
                                        return DropdownMenuItem<LabTest>(
                                          value: test,
                                          child: Text(test.name),
                                        );
                                      }).toList(),
                                useExternalValue: true,
                                initialValue: selectedTest,
                                value: selectedTest,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTest = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              LabeledTextField(
                                text: 'Hospital Number',
                                readOnly: widget.client != null,
                                controller: hospitalNumber,
                                validator: (val) {
                                  if (val.length == 0) {
                                    return "Enter Hospital Number";
                                  }

                                  return null;
                                },
                              ),
                              LabeledTextField(
                                text: 'Note',
                                controller: note,
                                lines: 5,
                              ),
                              SizedBox(
                                height: 10,
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
                                              color: Colors.white,
                                              fontSize: 20),
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
                                        onPressed: selectedType == null ||
                                                selectedTest == null
                                            ? null
                                            : () async {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                if (formKey.currentState
                                                    .validate()) {
                                                  Provider.of<AuthProvider>(
                                                          context,
                                                          listen: false)
                                                      .resetInactivityTimer();
                                                  bool value =
                                                      await showBasicConfirmationDialog(
                                                          "Do you want to place this test order?",
                                                          context);
                                                  if (value) {
                                                    showPersistentLoadingIndicator(
                                                        context);
                                                    LabApi.postClinicalLabTests(
                                                            {
                                                          'laboratory_test_id':
                                                              selectedTest
                                                                  .labTestId,
                                                          'laboratory_test_type_id':
                                                              selectedTest
                                                                  .labTestTypeId,
                                                          'laboratory_test_note':
                                                              note.text.trim(),
                                                          'ordered_by_id':
                                                              Provider.of<AuthProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .serviceProvider
                                                                  .userId,
                                                          'laboratory_test_status':
                                                              'ordered',
                                                          'ordered_date': DateTime
                                                                  .now()
                                                              .toIso8601String(),
                                                          'client_unique_identifier':
                                                              hospitalNumber
                                                                  .text
                                                                  .trim()
                                                        },
                                                            context)
                                                        .then((value) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(
                                                          context, true);
                                                    }).catchError((err) {
                                                      Navigator.pop(context);
                                                      showBasicMessageDialog(
                                                          err.toString(),
                                                          context);
                                                    });
                                                  }
                                                }
                                              },
                                        child: Text(
                                          'Next',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        color: Colors.blueAccent),
                                  ))
                                ],
                              )
                            ],
                          ),
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
      ),
    );
  }
}
