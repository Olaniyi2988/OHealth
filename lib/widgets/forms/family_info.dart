import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/forms/form_template.dart';
import 'package:provider/provider.dart';

class FamilyInfoForm extends StatefulWidget {
  final void Function(KpMetaData maritalStatus, DateTime dateOfbirth,
      int chilren, int wives) onFinished;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final VoidCallback onBack;
  final Client client;
  FamilyInfoForm(
      {this.stepIndex,
      this.onFinished,
      this.numberOfSteps,
      this.onBack,
      this.disableBackButton,
      this.disableForwardButton,
      this.client}) {
    assert(client != null);
  }

  @override
  State createState() => FamilyInfoFormState();
}

class FamilyInfoFormState extends State<FamilyInfoForm> {
  KpMetaData maritalStatus;
  DateTime dateOfBirth;
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController childrenController = TextEditingController();
  TextEditingController wivesController = TextEditingController();

  @override
  void initState() {
    maritalStatus = widget.client.maritalStatus;
    dateOfBirth = widget.client.dob;
    childrenController.text = widget.client.numberOfChildren == null
        ? ''
        : widget.client.numberOfChildren.toString();
    wivesController.text = widget.client.numberOfWives == null
        ? ''
        : widget.client.numberOfWives.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider =
        Provider.of<MetadataProvider>(context, listen: true);
    return FormTemplate(
      onFinished: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (formKey.currentState.validate()) {
          if (dateOfBirth == null ||
              (maritalStatus == null &&
                  metaProvider.genericMetaData['maritalstatus'] != null)) {
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(dateOfBirth == null
                        ? 'Select Date of birth'
                        : 'Select Marital Status'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OKAY',
                              style: TextStyle(color: Colors.blueAccent)))
                    ],
                  );
                });
          }
          widget.onFinished(
              maritalStatus,
              dateOfBirth,
              int.parse(childrenController.text == ""
                  ? "0"
                  : childrenController.text.trim()),
              int.parse(wivesController.text == ""
                  ? "0"
                  : wivesController.text.trim()));
        }
      },
      stepIndex: widget.stepIndex,
      numberOfSteps: widget.numberOfSteps,
      disableBackButton: widget.disableBackButton,
      disableForwardButton: widget.disableForwardButton,
      onBack: widget.onBack,
      title: "Marital Information",
      children: [
        CustomFormDropDown<KpMetaData>(
          text: 'Marital Status',
          iconData: Icons.family_restroom_outlined,
          initialValue: maritalStatus,
          items: metaProvider.genericMetaData['maritalstatus'] == null
              ? null
              : metaProvider.genericMetaData['maritalstatus'].map((e) {
                  return DropdownMenuItem<KpMetaData>(
                      child: Text(e.name), value: e);
                }).toList(),
          onChanged: (value) {
            maritalStatus = value;
            widget.client.maritalStatus = maritalStatus;
          },
        ),
        SizedBox(
          height: 20,
        ),
        CustomDateSelector(
          yearOffset: 30,
          maxAge: 18,
          initialDate: dateOfBirth,
          onDateChanged: (date) {
            dateOfBirth = date;
            widget.client.dob = dateOfBirth;
          },
        ),
        SizedBox(
          height: 25,
        ),
        Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: childrenController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.length == 0) {
                    return null;
                  }

                  try {
                    int temp = int.parse(value);
                  } catch (err) {
                    return 'Must be a number';
                  }

                  return null;
                },
                onChanged: (val) {
                  widget.client.numberOfChildren = int.parse(val);
                },
                decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    labelText: 'Number of children'),
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: TextFormField(
                controller: wivesController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.length == 0) {
                    return null;
                  }

                  try {
                    int temp = int.parse(value);
                  } catch (err) {
                    return 'Must be a number';
                  }

                  return null;
                },
                onChanged: (val) {
                  widget.client.numberOfWives = int.parse(val);
                },
                decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    labelText: 'Number of wives'),
              ))
            ],
          ),
        ),
      ],
    );
  }
}
