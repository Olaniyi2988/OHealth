import 'package:flutter/material.dart';
import 'package:kp/api/clients_api.dart';
import 'package:kp/db/clients.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/local_government.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/models/state.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EditClient extends StatefulWidget {
  final Client client;
  final void Function() onTap;
  EditClient({this.client, this.onTap});
  @override
  State createState() => EditClientState();
}

class EditClientState extends State<EditClient> {
  ScrollController controller = ScrollController();
  Client client;
  bool changesSaved = true;

  KpMetaData gender;
  KpMetaData occupation;
  KpMetaData maritalStatus;
  KpMetaData disability;
  KpMetaData targetGroup;
  KpMetaData careEntryPoint;
  KpMetaData priorArt;
  KpMetaData referredFrom;
  KpMetaData religion;
  KpMetaData language;
  KpMetaData qualification;
  KpMetaData nationality;
  DateTime dateOfBirth;

  KState state;
  LocalGovernment lga;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController otherNameController = TextEditingController();
  TextEditingController numberOfChildrenController = TextEditingController();
  TextEditingController numberOfWivesController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController altPhoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    firstNameController.text = widget.client.firstName;
    surnameController.text = widget.client.surname;
    otherNameController.text = widget.client.otherNames;
    gender = widget.client.gender;
    disability = widget.client.disability;
    targetGroup = widget.client.targetGroup;
    careEntryPoint = widget.client.careEntryPoint;
    priorArt = widget.client.priorArt;
    referredFrom = widget.client.referredFrom;
    occupation = widget.client.occupation;
    maritalStatus = widget.client.maritalStatus;
    dateOfBirth = widget.client.dob;
    numberOfChildrenController.text = widget.client.numberOfChildren.toString();
    numberOfWivesController.text = widget.client.numberOfWives.toString();
    phoneController.text = widget.client.phone;
    altPhoneController.text = widget.client.altPhone;
    addressController.text = widget.client.residentialAddress.toString();
    state = widget.client.state;
    lga = widget.client.lga;
    emailController.text = widget.client.email;
    religion = widget.client.religion;
    language = widget.client.language;
    qualification = widget.client.qualification;
    nationality = widget.client.nationality;

    client = widget.client;
    controller.addListener(() {
      Provider.of<AuthProvider>(context, listen: false).resetInactivityTimer();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
          color: Colors.white,
          child: ResponsiveBuilder(
            builder: (context, sizingInfo) {
              return OrientationBuilder(
                builder: (builder, orientation) {
                  return Consumer<MetadataProvider>(
                    builder: (context, metaProvider, _) {
                      List<Widget> personalInfoFields = [];
                      personalInfoFields.add(LabeledTextField(
                        text: "First Name",
                        readOnly: widget.onTap != null,
                        controller: firstNameController,
                        onChanged: (val) {
                          client.firstName = val;
                          changesSaved = false;
                        },
                      ));

                      personalInfoFields.add(LabeledTextField(
                        text: "Surname",
                        controller: surnameController,
                        readOnly: widget.onTap != null,
                        onChanged: (val) {
                          client.surname = val;
                          changesSaved = false;
                        },
                      ));

                      personalInfoFields.add(LabeledTextField(
                        text: "Other Names",
                        controller: otherNameController,
                        readOnly: widget.onTap != null,
                        onChanged: (val) {
                          client.otherNames = val;
                          changesSaved = false;
                        },
                      ));

                      personalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: widget.onTap != null,
                          text: 'Gender',
                          iconData: Icons.wc,
                          initialValue: gender,
                          items: metaProvider.genericMetaData['genders'] == null
                              ? null
                              : metaProvider.genericMetaData['genders']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            gender = value;
                            client.gender = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      personalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          text: 'Occupation',
                          readOnly: widget.onTap != null,
                          iconData: Icons.work,
                          initialValue: occupation,
                          items: metaProvider.genericMetaData['occupations'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['occupations']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            occupation = value;
                            client.occupation = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      personalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          text: 'Religion',
                          readOnly: widget.onTap != null,
                          iconData: Icons.water_damage_outlined,
                          initialValue: religion,
                          items:
                              metaProvider.genericMetaData['religions'] == null
                                  ? null
                                  : metaProvider.genericMetaData['religions']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                          onChanged: (value) {
                            religion = value;
                            client.religion = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      personalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          text: 'Language',
                          readOnly: widget.onTap != null,
                          iconData: Icons.language,
                          initialValue: language,
                          items:
                              metaProvider.genericMetaData['languages'] == null
                                  ? null
                                  : metaProvider.genericMetaData['languages']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                          onChanged: (value) {
                            language = value;
                            client.language = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      personalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          text: 'Qualification',
                          readOnly: widget.onTap != null,
                          iconData: Icons.school,
                          initialValue: qualification,
                          items: metaProvider
                                      .genericMetaData['qualifications'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['qualifications']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            qualification = value;
                            client.qualification = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      personalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          text: 'Nationality',
                          readOnly: widget.onTap != null,
                          iconData: Icons.language,
                          initialValue: nationality,
                          items: metaProvider
                                      .genericMetaData['nationalities'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['nationalities']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            nationality = value;
                            client.nationality = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      int chunk;
                      if (orientation == Orientation.portrait) {
                        if (sizingInfo.isMobile) {
                          chunk = 2;
                        } else {
                          chunk = 3;
                        }
                      } else {
                        chunk = 3;
                      }
                      List<Widget> personalInfoRows =
                          splitToChunks(personalInfoFields, chunk);

                      //marital info
                      List<Widget> maritalInfoFields = [];
                      maritalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: widget.onTap != null,
                          text: 'Marital Status',
                          iconData: Icons.family_restroom_outlined,
                          initialValue: maritalStatus,
                          items: metaProvider
                                      .genericMetaData['maritalstatus'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['maritalstatus']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            maritalStatus = value;
                            client.maritalStatus = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      maritalInfoFields.add(
                        CustomDateSelector(
                          initialDate: dateOfBirth,
                          readOnly: widget.onTap != null,
                          onDateChanged: (date) {
                            dateOfBirth = date;
                            client.dob = date;
                            changesSaved = false;
                          },
                        ),
                      );
                      maritalInfoFields.add(LabeledTextField(
                        text: "Number of Children",
                        controller: numberOfChildrenController,
                        readOnly: widget.onTap != null,
                        onChanged: (val) {
                          client.numberOfChildren = int.parse(val);
                          changesSaved = false;
                        },
                      ));

                      maritalInfoFields.add(LabeledTextField(
                        readOnly: widget.onTap != null,
                        text: "Number of wives",
                        controller: numberOfWivesController,
                        onChanged: (val) {
                          client.numberOfWives = int.parse(val);
                          changesSaved = false;
                        },
                      ));

                      List<Widget> maritalInfoRows =
                          splitToChunks(maritalInfoFields, chunk);

                      // contact info
                      List<Widget> contactInfoFields = [];
                      contactInfoFields.add(LabeledTextField(
                        readOnly: widget.onTap != null,
                        text: "Phone Number",
                        controller: phoneController,
                        onChanged: (val) {
                          client.phone = val;
                          changesSaved = false;
                        },
                      ));

                      contactInfoFields.add(LabeledTextField(
                        readOnly: widget.onTap != null,
                        text: "Alt Number",
                        controller: altPhoneController,
                        onChanged: (val) {
                          client.altPhone = val;
                          changesSaved = false;
                        },
                      ));

                      contactInfoFields.add(LabeledTextField(
                        readOnly: widget.onTap != null,
                        text: "Email",
                        controller: emailController,
                        onChanged: (val) {
                          client.email = val;
                          changesSaved = false;
                        },
                      ));

                      contactInfoFields.add(LabeledTextField(
                        readOnly: widget.onTap != null,
                        text: "Residential Address",
                        controller: addressController,
                        onChanged: (val) {
                          client.residentialAddress = val;
                          changesSaved = false;
                        },
                      ));

                      contactInfoFields.add(LabeledTextField(
                        // readOnly: widget.onTap != null,
                        readOnly: true,
                        text: "State",
                        controller: TextEditingController(
                            text: state == null ? "" : state.name),
                        onChanged: (val) {
                          // client.state = val;
                          // changesSaved = false;
                        },
                      ));

                      contactInfoFields.add(LabeledTextField(
                        // readOnly: widget.onTap != null,
                        readOnly: true,
                        text: "LGS",
                        controller: TextEditingController(
                            text: lga == null ? "" : lga.name),
                        onChanged: (val) {
                          // client.state = val;
                          // changesSaved = false;
                        },
                      ));

                      List<Widget> contactInfoRows =
                          splitToChunks(contactInfoFields, chunk);

                      // contact info
                      List<Widget> hospitalInfoFields = [];
                      hospitalInfoFields.add(LabeledTextField(
                        readOnly: true,
                        text: "Unique Identifier",
                        controller:
                            new TextEditingController(text: client.hospitalNum),
                        onChanged: (val) {},
                      ));

                      hospitalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: widget.onTap != null,
                          text: 'Disability',
                          iconData: Icons.wheelchair_pickup,
                          initialValue: disability,
                          items: metaProvider.genericMetaData['disabilities'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['disabilities']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            disability = value;
                            client.disability = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      hospitalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: true,
                          text: 'Target Group',
                          iconData: Icons.group,
                          initialValue: targetGroup,
                          items: metaProvider.genericMetaData['targetgroups'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['targetgroups']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            targetGroup = value;
                            client.targetGroup = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      hospitalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: true,
                          text: 'Care Entry Point',
                          iconData: Icons.local_hospital_outlined,
                          initialValue: careEntryPoint,
                          items: metaProvider
                                      .genericMetaData['careentrypoint'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['careentrypoint']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            careEntryPoint = value;
                            client.careEntryPoint = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      hospitalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: true,
                          text: 'Prior Art',
                          iconData: Icons.wysiwyg,
                          initialValue: priorArt,
                          items:
                              metaProvider.genericMetaData['priorart'] == null
                                  ? null
                                  : metaProvider.genericMetaData['priorart']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                          onChanged: (value) {
                            priorArt = value;
                            client.priorArt = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      hospitalInfoFields.add(
                        CustomFormDropDown<KpMetaData>(
                          readOnly: true,
                          text: 'Referred form',
                          iconData: Icons.add_link,
                          initialValue: referredFrom,
                          items: metaProvider.genericMetaData['referredfrom'] ==
                                  null
                              ? null
                              : metaProvider.genericMetaData['referredfrom']
                                  .map((e) {
                                  return DropdownMenuItem<KpMetaData>(
                                      child: Text(e.name), value: e);
                                }).toList(),
                          onChanged: (value) {
                            referredFrom = value;
                            client.referredFrom = value;
                            changesSaved = false;
                          },
                        ),
                      );

                      List<Widget> hospitalInfoRows =
                          splitToChunks(hospitalInfoFields, chunk);

                      return Scaffold(
                        appBar: AppBar(
                          title: Text(
                            widget.onTap != null
                                ? 'Registration Summary'
                                : client.firstName + " " + client.surname,
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          backgroundColor: Colors.white,
                          actions: [
                            FlatButton(
                                onPressed: () async {
                                  if (widget.onTap != null) {
                                    return widget.onTap();
                                  }
                                  if (changesSaved == true) {
                                    return showBasicMessageDialog(
                                        'You have not made any changes',
                                        context);
                                  }
                                  bool val = await showBasicConfirmationDialog(
                                      "Are you sure you want to save changes?",
                                      context);
                                  if (val == true) {
                                    if (client.isRegisteredOnline == true) {
                                      print('is registered online');
                                      showPersistentLoadingIndicator(context);
                                      ClientApi.postClinicalRegistration(
                                              client, context)
                                          .then((value) {
                                        Navigator.pop(context);
                                        showBasicMessageDialog(
                                            'Client updated', context);
                                      }).catchError((err) {
                                        Navigator.pop(context);
                                        showBasicMessageDialog(
                                            err.toString(), context);
                                      });
                                      //TODO
                                    } else {
                                      showPersistentLoadingIndicator(context);
                                      ClientsDB.getInstance()
                                          .updateClient(
                                              client.localDBIdentifier,
                                              client.toDBJson(context),
                                              context)
                                          .then((value) {
                                        changesSaved = true;
                                        Navigator.pop(context);
                                      }).catchError((err) {
                                        Navigator.pop(context);
                                        showBasicMessageDialog(
                                            err.toString(), context);
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  'SAVE',
                                  style: TextStyle(color: Colors.blueAccent),
                                )),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        body: Container(
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: ListView(
                              controller: controller,
                              physics: BouncingScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                FormLegend(
                                  text: 'Personal Information',
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ...personalInfoRows,
                                SizedBox(
                                  height: 20,
                                ),
                                FormLegend(
                                  text: 'Marital Information',
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ...maritalInfoRows,
                                SizedBox(
                                  height: 20,
                                ),
                                FormLegend(
                                  text: 'Contact',
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ...contactInfoRows,
                                FormLegend(
                                  text: 'Hospital Info',
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ...hospitalInfoRows
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        onWillPop: () async {
          if (widget.onTap != null) {
            return true;
          }
          if (changesSaved == true) {
            return true;
          } else {
            bool val = await showBasicConfirmationDialog(
                'Changes have not been saved. Proceed without saving?',
                context);
            return val;
          }
        });
  }
}

class FormLegend extends StatelessWidget {
  final String text;
  FormLegend({this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            text,
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}
