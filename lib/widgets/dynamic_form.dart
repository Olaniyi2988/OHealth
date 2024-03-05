import 'package:flutter/material.dart';
import 'package:kp/api/programs.dart';
import 'package:kp/db/service_forms.dart';
import 'package:kp/models/programs.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/dynamic_add_another.dart';
import 'package:kp/widgets/dynamic_date_time_picker.dart';
import 'package:kp/widgets/dynamic_dropdown.dart';
import 'package:kp/widgets/dynamic_field.dart';
import 'package:kp/widgets/dynamic_form_group.dart';
import 'package:kp/widgets/dynamic_radio.dart';
import 'package:kp/widgets/dynamic_select_box.dart';
import 'package:kp/widgets/dynamic_select_boxes.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DynamicForm extends StatefulWidget {
  final Map<String, dynamic> config;
  final ProgramStage programStage;
  final Program program;
  final String clientUniqueIdentifier;
  final DateTime reportDate;
  final editMode;
  final bool offlineData;
  DynamicForm(
      {this.config,
      this.programStage,
      this.clientUniqueIdentifier,
      this.reportDate,
      this.editMode = false,
      this.program,
      this.offlineData = false});
  @override
  State createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  ScrollController controller = ScrollController();
  Map<String, dynamic> value;
  Widget dynamicForm;

  @override
  void initState() {
    dynamicForm = getDynamicComponent(widget.config, (value) {
      if (this.value == null) {
        this.value = value;
      } else {
        this.value.addAll(value);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config
        .toString()
        .contains("Service form not available at the moment")) {
      return Center(
        child: Text(
          'Service form not available at the moment',
          style: TextStyle(color: Colors.blueAccent, fontSize: 15),
        ),
      );
    }
    if (DynamicFormDataInfo.of(context) != null &&
        (widget.editMode == true || widget.offlineData == true)) {
      if (value == null) {
        value = {};
        value.addAll(DynamicFormDataInfo.of(context).editData);
      }
    }

    List components = widget.config['components'];
    if (components == null) {
      return Center(
        child: Text(
          'The form contains no elements',
          style: TextStyle(color: Colors.blueAccent, fontSize: 15),
        ),
      );
    }

    if (dynamicForm == null) {
      return Center(
        child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: ListView(
            cacheExtent: 99999999999,
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              dynamicForm,
              Padding(
                padding: EdgeInsets.only(left: 5, right: 5, top: 30),
                child: Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                      height: 50,
                      child: RaisedButton(
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          bool response = await showBasicConfirmationDialog(
                              widget.editMode == true
                                  ? "Save changes?"
                                  : widget.offlineData == true
                                      ? "Upload form?"
                                      : "Save this form?",
                              context);
                          if (response == false) {
                            return;
                          }
                          if (widget.editMode == true) {
                            Map<String, dynamic> valueCopy = {...value};
                            valueCopy['submit'] = true;
                            valueCopy['client_unique_identifier'] =
                                widget.clientUniqueIdentifier;
                            valueCopy['formName'] =
                                widget.programStage.dbIdentifier;
                            showPersistentLoadingIndicator(context);

                            return ProgramsApi.updateDynamicData(valueCopy)
                                .then((val) {
                              if (val == true) {
                                print('will update');
                                Navigator.pop(context);
                                Navigator.pop(context, this.value);
                                showBasicMessageDialog("Form Saved!", context);
                              }
                            }).catchError((err) {
                              Navigator.pop(context);
                              showBasicMessageDialog(err.toString(), context);
                            });
                          }

                          if (value == null) {
                            return showBasicMessageDialog(
                                "You haven't filled the form", context);
                          }
                          Map<String, dynamic> payload = {
                            ...value,
                            ...{
                              "client_unique_identifier":
                                  widget.clientUniqueIdentifier,
                              "created_date":
                                  widget.reportDate.toIso8601String(),
                              "formName": widget.programStage.dbIdentifier,
                              "submit": true
                            }
                          };

                          payload["created_by"] =
                              Provider.of<AuthProvider>(context, listen: false)
                                  .serviceProvider
                                  .userId;
                          String formDataId = payload['formDataId'];
                          if (widget.offlineData == true) {
                            payload.remove('programId');
                            payload.remove('formDataId');
                          }

                          showPersistentLoadingIndicator(context);
                          ProgramsApi.insertDynamicTableData(payload)
                              .then((value) {
                            Navigator.pop(context);
                            if (widget.offlineData == true) {
                              ServiceFormsDB.getInstance()
                                  .deleteFormData(formDataId);
                              Navigator.pop(context, true);
                            }
                            showBasicMessageDialog("Form Saved!", context);
                          }).catchError((err) {
                            Navigator.pop(context);
                            showBasicMessageDialog(err.toString(), context);
                          });
                        },
                        child: Text(
                            widget.editMode == true
                                ? 'Save'
                                : widget.offlineData == true
                                    ? "Upload"
                                    : 'Submit',
                            style: TextStyle(color: Colors.white)),
                        color: Colors.blueAccent,
                      ),
                    )),
                    widget.editMode == true || widget.offlineData == true
                        ? Container()
                        : SizedBox(
                            width: 10,
                          ),
                    widget.editMode == true || widget.offlineData == true
                        ? Container()
                        : Expanded(
                            child: SizedBox(
                            child: RaisedButton(
                              onPressed: () async {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                bool saveOffline =
                                    await showBasicConfirmationDialog(
                                        "Save offline?", context);
                                if (saveOffline == false) {
                                  return;
                                }
                                if (value == null) {
                                  return showBasicMessageDialog(
                                      "You haven't filled the form", context);
                                }

                                Map<String, dynamic> payload = {
                                  ...value,
                                  ...{
                                    "client_unique_identifier":
                                        widget.clientUniqueIdentifier,
                                    "created_date":
                                        widget.reportDate.toIso8601String(),
                                    "formName":
                                        widget.programStage.dbIdentifier,
                                    "submit": true
                                  }
                                };

                                payload['programId'] = widget.program.programId;
                                var uuid = Uuid();
                                payload['formDataId'] = uuid.v4();
                                showPersistentLoadingIndicator(context);
                                return ServiceFormsDB.getInstance()
                                    .saveFormData(payload)
                                    .then((value) {
                                  Navigator.pop(context);
                                  showBasicMessageDialog("Saved!", context);
                                }).catchError((err) {
                                  Navigator.pop(context);
                                  showBasicMessageDialog(
                                      "Error saving", context);
                                });
                              },
                              child: Text("Save Offline",
                                  style: TextStyle(color: Colors.white)),
                              color: Colors.blueAccent,
                            ),
                            height: 50,
                          ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DynamicFormDataInfo extends InheritedWidget {
  final editData;
  final Map columns;
  DynamicFormDataInfo({Widget child, this.editData, this.columns})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static DynamicFormDataInfo of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DynamicFormDataInfo>();
}

Widget getDynamicComponent(Map<String, dynamic> config,
    Function(Map<String, dynamic> value) callBack) {
  Widget component;
  if (config['addAnother'] != null || config['addAnotherPosition'] != null) {
    component = DynamicAddAnother(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else if (config['components'] != null || config['columns'] != null) {
    component = DynamicFormGroup(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else if (config['type'] == 'textfield' ||
      config['type'] == 'textarea' ||
      config['type'] == 'number' ||
      config['type'] == 'password') {
    component = DynamicField(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else if (config['type'] == 'select') {
    component = DynamicDropdown(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else if (config['type'] == 'radio') {
    if (config['values'] != null) {
      component = DynamicRadio(
        config: config,
        key: GlobalKey(),
        onValueChanged: callBack,
      );
    } else {
      component = DynamicSelectBox(
        config: config,
        key: GlobalKey(),
        onValueChanged: callBack,
      );
    }
  } else if (config['type'] == 'checkbox') {
    component = DynamicSelectBox(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else if (config['type'] == 'selectboxes') {
    component = DynamicSelectBoxes(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else if (config['type'] == 'datetime') {
    component = DynamicDateTimePicker(
      config: config,
      key: GlobalKey(),
      onValueChanged: callBack,
    );
  } else {
    component = null;
  }
  return component;
}
