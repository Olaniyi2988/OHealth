import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/views/registration.dart';
import 'package:kp/widgets/assessments/assessment.dart';
import 'package:kp/widgets/forms/select_assessment.dart';
import 'package:provider/provider.dart';

class AssessmentView extends StatefulWidget {
  final Client client;
  AssessmentView({this.client});
  @override
  State createState() => AssessmentViewState();
}

class AssessmentViewState extends State<AssessmentView> {
  AssessmentType assessmentType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        Provider.of<AuthProvider>(context, listen: false)
            .resetInactivityTimer();
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              height:
                  (MediaQuery.of(context).size.height - kToolbarHeight) * 0.35,
              color: Colors.blueAccent,
            ),
            Positioned(
              child: SizedBox(
                height:
                    (MediaQuery.of(context).size.height - kToolbarHeight) * 0.8,
                width: MediaQuery.of(context).size.width * 0.85,
                child: assessmentType == null
                    ? AssessmentSelectionForm(
                        stepIndex: 1,
                        numberOfSteps: 2,
                        onFinished: (assessment) {
                          setState(() {
                            assessmentType = assessment;
                          });
                        },
                        // disableBackButton: true,
                        onBack: () {
                          Navigator.pop(context);
                        },
                      )
                    : assessmentType == AssessmentType.KNOWLEDGE_ASSESSMENT
                        ? Assessment(
                            onFinished: () {},
                            questions: [
                              'Previoisly tested HIV negative',
                              'Client Pregnant (Test and ensure linkage to PMTCT program)',
                              'Client informed about risk factors for HIV transmission',
                              'Client informed on preventing HIV transmission methods',
                              'Client informed about possible test results',
                              'Informed consent for HIV test given'
                            ],
                            title: "Knowledge Assessment",
                            onBack: () {
                              setState(() {
                                assessmentType = null;
                              });
                            },
                          )
                        : assessmentType == AssessmentType.HIV_ASSESSMENT
                            ? Assessment(
                                onFinished: () {},
                                questions: [
                                  'Ever had sexual intercourse',
                                  'Blood transfusion in last 3 months',
                                  'Unprotected sex with casual partner in last 3 months',
                                  'Unprotected sex with regular partner in last 3 months',
                                  'STI in last 3 months',
                                  'More than 1 sex partner during last 3 months'
                                ],
                                title: "HIV Assessment",
                                onBack: () {
                                  setState(() {
                                    assessmentType = null;
                                  });
                                },
                              )
                            : assessmentType == AssessmentType.TB_ASSESSMENT
                                ? Assessment(
                                    onFinished: () {},
                                    questions: [
                                      'Current cough',
                                      'Weight loss',
                                      'Fever',
                                      'Night Sweats'
                                    ],
                                    title: "Clinical TB Screening",
                                    onBack: () {
                                      setState(() {
                                        assessmentType = null;
                                      });
                                    },
                                  )
                                : assessmentType == AssessmentType.STI_SCREENING
                                    ? Assessment(
                                        onFinished: () {},
                                        questions: true
                                            ? [
                                                'Complaints of urethral discharge or burning when urinating?',
                                                'Complaints of scrotal swelling and pain',
                                                'Complaints of genital sore(s) or swollen inguinal lymph nodes with or without pains?'
                                              ]
                                            : [
                                                'Complaints of vaginal discharge or burning when urinating?',
                                                'Complaints of lower abdominal pains with or without vaginal discharge?',
                                                'Complaints of genital sore(s) or swollen inguinal lymph nodes with or without pains?'
                                              ],
                                        title: "Syndromatic STI screening",
                                        onBack: () {
                                          setState(() {
                                            assessmentType = null;
                                          });
                                        },
                                      )
                                    : Container(),
              ),
              top: (MediaQuery.of(context).size.height - kToolbarHeight) * 0.15,
              left: MediaQuery.of(context).size.width * 0.15 / 2,
            )
          ],
        ),
      ),
    ));
  }
}
