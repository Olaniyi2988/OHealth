import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/forms/form_template.dart';
import 'package:provider/provider.dart';

class PersonalInfoForm extends StatefulWidget {
  final VoidCallback onBack;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final Client client;
  final void Function(
      String surname,
      String lastName,
      String otherNames,
      KpMetaData gender,
      KpMetaData occupation,
      String clientCode,
      KpMetaData religion,
      KpMetaData language,
      KpMetaData qualification,
      KpMetaData nationality) onFinished;
  PersonalInfoForm(
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
  State createState() => PersonalInfoFormState();
}

class PersonalInfoFormState extends State<PersonalInfoForm> {
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController otherNamesController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController clientCode = TextEditingController();
  KpMetaData gender;
  KpMetaData occupation;
  KpMetaData religion;
  KpMetaData language;
  KpMetaData qualification;
  KpMetaData nationality;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    surnameController.text =
        widget.client.surname == null ? "" : widget.client.surname;
    otherNamesController.text =
        widget.client.otherNames == null ? "" : widget.client.otherNames;
    firstNameController.text =
        widget.client.firstName == null ? "" : widget.client.firstName;
    clientCode.text =
        widget.client.clientCode == null ? "" : widget.client.clientCode;
    gender = widget.client.gender;
    occupation = widget.client.occupation;
    religion = widget.client.religion;
    language = widget.client.language;
    qualification = widget.client.qualification;
    nationality = widget.client.nationality;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider =
        Provider.of<MetadataProvider>(context, listen: true);

    FocusNode firstNameNode = new FocusNode();

    return FormTemplate(
      stepIndex: widget.stepIndex,
      onFinished: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (formKey.currentState.validate()) {
          if ((gender == null &&
                  metaProvider.genericMetaData['genders'] != null) ||
              (occupation == null &&
                  metaProvider.genericMetaData['occupations'] != null) ||
              (religion == null &&
                  metaProvider.genericMetaData['religions'] != null) ||
              (language == null &&
                  metaProvider.genericMetaData['languages'] != null) ||
              (qualification == null &&
                  metaProvider.genericMetaData['qualifications'] != null) ||
              (nationality == null &&
                  metaProvider.genericMetaData['nationalities'] != null)) {
            return showBasicMessageDialog("Enter missing details", context);
          }
          widget.onFinished(
              surnameController.text,
              firstNameController.text,
              otherNamesController.text,
              gender,
              occupation,
              clientCode.text,
              religion,
              language,
              qualification,
              nationality);
        } else {
          return showBasicMessageDialog("Enter missing details", context);
        }
      },
      numberOfSteps: widget.numberOfSteps,
      disableBackButton: widget.disableBackButton,
      disableForwardButton: widget.disableForwardButton,
      onBack: widget.onBack,
      title: 'Personal info',
      children: [
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: clientCode,
                onChanged: (val) {
                  widget.client.clientCode = val;
                },
                validator: (val) {
                  if (val.length == 0) {
                    return "Can't be empty";
                  }

                  return null;
                },
                readOnly: false,
                decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    labelText: 'Client Code'),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: firstNameController,
                validator: (val) {
                  if (val.length == 0) {
                    return "Can't be empty";
                  }

                  return null;
                },
                onChanged: (val) {
                  widget.client.firstName = val;
                },
                decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    labelText: 'First Name'),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    validator: (val) {
                      if (val.length == 0) {
                        return "Can't be empty";
                      }

                      return null;
                    },
                    onChanged: (val) {
                      widget.client.surname = val;
                    },
                    controller: surnameController,
                    decoration: InputDecoration(
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        labelText: 'Surname'),
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextFormField(
                    controller: otherNamesController,
                    onChanged: (val) {
                      widget.client.otherNames = val;
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        labelText: 'Other Names'),
                  ))
                ],
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Gender',
                iconData: Icons.wc,
                initialValue: gender,
                items: metaProvider.genericMetaData['genders'] == null
                    ? null
                    : metaProvider.genericMetaData['genders'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  gender = value;
                  widget.client.gender = gender;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Occupation',
                initialValue: occupation,
                iconData: Icons.work,
                items: metaProvider.genericMetaData['occupations'] == null
                    ? null
                    : metaProvider.genericMetaData['occupations'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  occupation = value;
                  widget.client.occupation = occupation;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Religion',
                initialValue: religion,
                iconData: Icons.water_damage_outlined,
                items: metaProvider.genericMetaData['religions'] == null
                    ? null
                    : metaProvider.genericMetaData['religions'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  religion = value;
                  widget.client.religion = religion;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Language',
                iconData: Icons.language,
                initialValue: language,
                items: metaProvider.genericMetaData['languages'] == null
                    ? null
                    : metaProvider.genericMetaData['languages'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  language = value;
                  widget.client.language = language;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Qualification',
                iconData: Icons.school,
                initialValue: qualification,
                items: metaProvider.genericMetaData['qualifications'] == null
                    ? null
                    : metaProvider.genericMetaData['qualifications'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  qualification = value;
                  widget.client.qualification = qualification;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Nationality',
                initialValue: nationality,
                iconData: Icons.language_outlined,
                items: metaProvider.genericMetaData['nationalities'] == null
                    ? null
                    : metaProvider.genericMetaData['nationalities'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  nationality = value;
                  widget.client.nationality = nationality;
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
