import 'package:flutter/material.dart';
import 'package:kp/db/clients.dart';
import 'package:kp/models/biometrics.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/edit_client.dart';
import 'package:kp/widgets/forms/contact_info.dart';
import 'package:kp/widgets/forms/family_info.dart';
import 'package:kp/widgets/forms/finger_capture.dart';
import 'package:kp/widgets/forms/next_of_kin.dart';
import 'package:kp/widgets/forms/personal_info.dart';
import 'package:kp/widgets/forms/supplementary.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegistrationView extends StatefulWidget {
  @override
  State createState() => RegistrationViewState();
}

Client savedReg;

class RegistrationViewState extends State<RegistrationView> {
  FormView formView = FormView.NEXT_OF_KIN;
  Client clientIntake = Client();

  @override
  void initState() {
    if (savedReg != null) {
      clientIntake = savedReg;
    }
    super.initState();
  }

  @override
  void dispose() {
    savedReg = clientIntake.copy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: OrientationBuilder(
            builder: (context, orientation) {
              Widget form = SizedBox(
                width: constraint.maxWidth * 0.9,
                height: orientation == Orientation.portrait
                    ? constraint.maxHeight * 0.8
                    : constraint.maxHeight * 0.95,
                child: formView == FormView.PERSONAL_INFO_FORM
                    ? PersonalInfoForm(
                        stepIndex: 1,
                        numberOfSteps: 6,
                        client: clientIntake,
                        onFinished: (surname,
                            firstName,
                            otherNames,
                            gender,
                            occupation,
                            clientCode,
                            religion,
                            language,
                            qualification,
                            nationality) {
                          Provider.of<AuthProvider>(context, listen: false)
                              .resetInactivityTimer();
                          setState(() {
                            clientIntake.surname = surname;
                            clientIntake.firstName = firstName;
                            clientIntake.otherNames = otherNames;
                            clientIntake.gender = gender;
                            clientIntake.occupation = occupation;
                            clientIntake.clientCode = clientCode;
                            clientIntake.religion = religion;
                            clientIntake.language = language;
                            clientIntake.qualification = qualification;
                            clientIntake.nationality = nationality;
                            clientIntake.regDate = DateTime.now();
                            clientIntake.regId = Uuid().v4().toString();
                            clientIntake.registeredBy =
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .serviceProvider
                                    .userId;
                            formView = FormView.MARITAL_INFO_FORM;
                          });
                        },
                        disableBackButton: true,
                      )
                    : formView == FormView.MARITAL_INFO_FORM
                        ? FamilyInfoForm(
                            stepIndex: 2,
                            numberOfSteps: 6,
                            client: clientIntake,
                            onFinished:
                                (maritalStatus, dateOfBirth, children, wives) {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .resetInactivityTimer();
                              setState(() {
                                clientIntake.maritalStatus = maritalStatus;
                                clientIntake.dob = dateOfBirth;
                                clientIntake.numberOfChildren = children;
                                clientIntake.numberOfWives = wives;
                                formView = FormView.CONTACT_INFO_FORM;
                              });
                            },
                            onBack: () {
                              setState(() {
                                formView = FormView.PERSONAL_INFO_FORM;
                              });
                            },
                          )
                        : formView == FormView.CONTACT_INFO_FORM
                            ? ContactInfoForm(
                                stepIndex: 3,
                                numberOfSteps: 6,
                                client: clientIntake,
                                onFinished: (phone, altPhone, address, state,
                                    lga, country, email) {
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .resetInactivityTimer();
                                  setState(() {
                                    clientIntake.phone = phone;
                                    clientIntake.altPhone = altPhone;
                                    clientIntake.residentialAddress = address;
                                    clientIntake.state = state;
                                    clientIntake.lga = lga;
                                    clientIntake.country = country;
                                    clientIntake.email = email;
                                    formView = FormView.OTHER_INFO_FORM;
                                  });
                                },
                                onBack: () {
                                  setState(() {
                                    formView = FormView.MARITAL_INFO_FORM;
                                  });
                                },
                              )
                            : formView == FormView.OTHER_INFO_FORM
                                ? OtherInfoForm(
                                    client: clientIntake,
                                    stepIndex: 4,
                                    numberOfSteps: 6,
                                    onFinished: (disability,
                                        targetGroup,
                                        careEntryPoint,
                                        priorArt,
                                        referredFrom,
                                        facilityPath,
                                        facilityId) {
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .resetInactivityTimer();
                                      setState(() {
                                        clientIntake.disability = disability;
                                        clientIntake.targetGroup = targetGroup;
                                        clientIntake.careEntryPoint =
                                            careEntryPoint;
                                        clientIntake.priorArt = priorArt;
                                        clientIntake.referredFrom =
                                            referredFrom;
                                        clientIntake.facilityId = facilityId;

                                        String temp1 = facilityPath.replaceAll(
                                            "null/", "");
                                        String temp2 =
                                            temp1.replaceAll("null", "");

                                        clientIntake.hospitalNum =
                                            // "HAN/$state/$lga/${targetGroup.code}/$facilityCode/${clientIntake.clientCode}";
                                            "HAN/$temp2/${targetGroup.code}/${clientIntake.careEntryPoint.code}/${clientIntake.clientCode}";
                                        clientIntake.hospitalNum = clientIntake
                                            .hospitalNum
                                            .replaceAll("//", "/");
                                        print(clientIntake.hospitalNum);
                                        formView = FormView.NEXT_OF_KIN;
                                      });
                                    },
                                    onBack: () {
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .resetInactivityTimer();
                                      setState(() {
                                        formView = FormView.CONTACT_INFO_FORM;
                                      });
                                    },
                                  )
                                : formView == FormView.NEXT_OF_KIN
                                    ? NextOfKinForm(
                                        client: clientIntake,
                                        stepIndex: 5,
                                        numberOfSteps: 6,
                                        onFinished: (nextOfKins) {
                                          setState(() {
                                            clientIntake.nextOfKins =
                                                nextOfKins;
                                            formView =
                                                FormView.FINGER_CAPTURE_FORM;
                                          });
                                        },
                                        onBack: () {
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .resetInactivityTimer();
                                          setState(() {
                                            formView = FormView.OTHER_INFO_FORM;
                                          });
                                        },
                                      )
                                    : formView == FormView.FINGER_CAPTURE_FORM
                                        ? FingerCaptureForm(
                                            stepIndex: 6,
                                            numberOfSteps: 6,
                                            client: clientIntake,
                                            onFinished: (Biometrics bio) {
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .resetInactivityTimer();
                                              clientIntake.biometrics = bio;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditClient(
                                                            client:
                                                                clientIntake,
                                                            onTap: () {
                                                              ClientsDB
                                                                      .getInstance()
                                                                  .addClient(
                                                                      clientIntake,
                                                                      context)
                                                                  .then(
                                                                      (value) {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  clientIntake =
                                                                      new Client();
                                                                  formView =
                                                                      FormView
                                                                          .PERSONAL_INFO_FORM;
                                                                  showBasicMessageDialog(
                                                                      "Registration Saved!",
                                                                      context);
                                                                });
                                                              }).catchError(
                                                                      (err) {
                                                                showBasicMessageDialog(
                                                                    err.toString(),
                                                                    context);
                                                              });
                                                            },
                                                          )));
                                            },
                                            onBack: () {
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .resetInactivityTimer();
                                              setState(() {
                                                formView = FormView.NEXT_OF_KIN;
                                              });
                                            },
                                          )
                                        : Container(),
              );
              if (orientation == Orientation.portrait) {
                return SizedBox(
                  height: constraint.maxHeight,
                  width: constraint.maxWidth,
                  child: Stack(
                    children: [
                      Container(
                        height: constraint.maxHeight * 0.2,
                        color: Colors.blueAccent,
                      ),
                      Positioned(
                        child: form,
                        top: constraint.maxHeight * 0.1,
                        left: constraint.maxWidth * 0.1 / 2,
                      )
                    ],
                  ),
                );
              }
              return form;
            },
          ),
        ),
      );
    });
  }
}

enum FormView {
  PERSONAL_INFO_FORM,
  CONTACT_INFO_FORM,
  MARITAL_INFO_FORM,
  ASSESSMENT_SELECTION_FORM,
  FINGER_CAPTURE_FORM,
  OTHER_INFO_FORM,
  NEXT_OF_KIN
}

enum AssessmentType {
  HIV_ASSESSMENT,
  KNOWLEDGE_ASSESSMENT,
  TB_ASSESSMENT,
  STI_SCREENING
}
