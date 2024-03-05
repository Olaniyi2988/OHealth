import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/models/next_of_kin.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/forms/form_template.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class NextOfKinForm extends StatefulWidget {
  final void Function(List<NextOfKin>) onFinished;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final VoidCallback onBack;
  final Client client;
  NextOfKinForm(
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
  State createState() => NextOfKinFormState();
}

class NextOfKinFormState extends State<NextOfKinForm> {
  GlobalKey<FormState> formKey = GlobalKey();
  List<NextOfKin> nextOfKins = [];

  @override
  void initState() {
    if (widget.client.nextOfKins != null) {
      nextOfKins = [...widget.client.nextOfKins];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> kinsWidget = [];
    nextOfKins.forEach((e) {
      kinsWidget.add(Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.contact_mail),
                title: Text('${e.firstName} ${e.lastName}'),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text(e.phoneNumber),
              ),
              ListTile(
                leading: Icon(Icons.family_restroom_outlined),
                title: Text(
                    e.relationship == null ? "father" : e.relationship.name),
              )
            ],
          ),
        ),
      ));
    });
    return FormTemplate(
      onFinished: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (formKey.currentState.validate()) {
          widget.onFinished(nextOfKins);
        }
      },
      nextIsSave: false,
      stepIndex: widget.stepIndex,
      numberOfSteps: widget.numberOfSteps,
      disableForwardButton: widget.disableForwardButton,
      disableBackButton: widget.disableBackButton,
      onBack: widget.onBack,
      title: "Next of kin",
      children: [
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kinsWidget.length == 0
                  ? Text(
                      'Add next of kin',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Container(),
              ...kinsWidget,
              SizedBox(
                height: 15,
              ),
              RaisedButton(
                onPressed: () {
                  GlobalKey<FormState> formKey = GlobalKey();
                  TextEditingController firstName = TextEditingController();
                  TextEditingController lastName = TextEditingController();
                  TextEditingController otherNames = TextEditingController();
                  TextEditingController phoneNumber = TextEditingController();
                  TextEditingController altPhoneNumber =
                      TextEditingController();
                  TextEditingController contactAddress =
                      TextEditingController();
                  KpMetaData gender;
                  KpMetaData relationship;
                  KpMetaData occupation;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: SectionHeader(
                            text: 'Add Next of Kin',
                          ),
                          insetPadding: EdgeInsets.all(10),
                          contentPadding: EdgeInsets.all(10),
                          content: GestureDetector(
                            onTap: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...splitToChunks([
                                          LabeledTextField(
                                            text: 'LastName',
                                            controller: lastName,
                                            validator: (val) {
                                              if (val.length == 0) {
                                                return "Can't be empty";
                                              }
                                              return null;
                                            },
                                          ),
                                          LabeledTextField(
                                            text: 'FirstName',
                                            controller: firstName,
                                            validator: (val) {
                                              if (val.length == 0) {
                                                return "Can't be empty";
                                              }
                                              return null;
                                            },
                                          ),
                                          LabeledTextField(
                                            text: 'Othername',
                                            controller: otherNames,
                                            // validator: (val) {
                                            //   if (val.length == 0) {
                                            //     return "Can't be empty";
                                            //   }
                                            //   return null;
                                            // },
                                          ),
                                          CustomFormDropDown<KpMetaData>(
                                            text: 'Gender',
                                            // iconData: Icons.school,
                                            initialValue: null,
                                            items: Provider.of<MetadataProvider>(
                                                                context,
                                                                listen: true)
                                                            .genericMetaData[
                                                        'genders'] ==
                                                    null
                                                ? null
                                                : Provider.of<MetadataProvider>(
                                                        context,
                                                        listen: true)
                                                    .genericMetaData['genders']
                                                    .map((e) {
                                                    return DropdownMenuItem<
                                                            KpMetaData>(
                                                        child: Text(e.name),
                                                        value: e);
                                                  }).toList(),
                                            onChanged: (value) {
                                              gender = value;
                                            },
                                          ),
                                          LabeledTextField(
                                            text: 'Phone Number',
                                            controller: phoneNumber,
                                            validator: (val) {
                                              if (val.length == 0) {
                                                return "Can't be empty";
                                              }

                                              if (validatePhone(val) == false) {
                                                return "Enter a valid Number";
                                              }

                                              return null;
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                          LabeledTextField(
                                            text: 'Alt phone',
                                            controller: altPhoneNumber,
                                            validator: (val) {
                                              if (val.length > 0) {
                                                if (validatePhone(val) ==
                                                    false) {
                                                  return "Enter a valid Number";
                                                }
                                              }

                                              return null;
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                          CustomFormDropDown<KpMetaData>(
                                            text: 'Relationship',
                                            // iconData: Icons.school,
                                            initialValue: null,
                                            items: Provider.of<MetadataProvider>(
                                                                context,
                                                                listen: true)
                                                            .genericMetaData[
                                                        'relationships'] ==
                                                    null
                                                ? null
                                                : Provider.of<MetadataProvider>(
                                                        context,
                                                        listen: true)
                                                    .genericMetaData[
                                                        'relationships']
                                                    .map((e) {
                                                    return DropdownMenuItem<
                                                            KpMetaData>(
                                                        child: Text(e.name),
                                                        value: e);
                                                  }).toList(),
                                            onChanged: (value) {
                                              relationship = value;
                                            },
                                          ),
                                          CustomFormDropDown<KpMetaData>(
                                            text: 'Occupation',
                                            // iconData: Icons.school,
                                            initialValue: null,
                                            items: Provider.of<MetadataProvider>(
                                                                context,
                                                                listen: true)
                                                            .genericMetaData[
                                                        'occupations'] ==
                                                    null
                                                ? null
                                                : Provider.of<MetadataProvider>(
                                                        context,
                                                        listen: true)
                                                    .genericMetaData[
                                                        'occupations']
                                                    .map((e) {
                                                    return DropdownMenuItem<
                                                            KpMetaData>(
                                                        child: Text(e.name),
                                                        value: e);
                                                  }).toList(),
                                            onChanged: (value) {
                                              occupation = value;
                                            },
                                          ),
                                          LabeledTextField(
                                            text: 'Contact Address',
                                            controller: contactAddress,
                                            validator: (val) {
                                              if (val.length == 0) {
                                                return "Can't be empty";
                                              }
                                              return null;
                                            },
                                          ),
                                        ], 2)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            RaisedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'CANCEL',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.blueAccent,
                            ),
                            RaisedButton(
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  if (gender == null ||
                                      occupation == null ||
                                      relationship == null) {
                                    return showBasicMessageDialog(
                                        'Incomplete details', context);
                                  }

                                  var temp = NextOfKin(
                                      firstName: firstName.text,
                                      lastName: lastName.text,
                                      otherName: otherNames.text,
                                      phoneNumber: phoneNumber.text,
                                      contactAddress: contactAddress.text,
                                      gender: gender,
                                      altNumber: altPhoneNumber.text,
                                      occupation: occupation,
                                      relationship: relationship);
                                  if (widget.client.nextOfKins == null) {
                                    widget.client.nextOfKins = [];
                                  }
                                  widget.client.nextOfKins.add(temp);
                                  setState(() {
                                    nextOfKins.add(temp);
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'ADD',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.blueAccent,
                            ),
                          ],
                          // contentPadding: EdgeInsets.zero,
                        );
                      });
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blueAccent,
              )
            ],
          ),
        )
      ],
    );
  }
}
