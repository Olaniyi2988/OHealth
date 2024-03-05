import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/views/arv_history.dart';
import 'package:kp/views/client_allergy_history.dart';
import 'package:kp/views/client_dashboard.dart';
import 'package:kp/views/client_diagnosis_history.dart';
import 'package:kp/views/client_lab_order.dart';
import 'package:kp/views/client_pharmacy_orders.dart';
import 'package:kp/views/client_visit_history.dart';
import 'package:kp/views/client_vital_history.dart';
import 'package:kp/widgets/view_holder_menu.dart';

class ClientPortalViewHolder extends StatefulWidget {
  final Client client;
  ClientPortalViewHolder(this.client);
  @override
  _ClientPortalViewHolderState createState() => _ClientPortalViewHolderState();
}

class _ClientPortalViewHolderState extends State<ClientPortalViewHolder> {
  View selectedView;

  @override
  void initState() {
    selectedView = View.DASHBOARD;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
                child: selectedView == View.DASHBOARD
                    ? ClientDashboard(
                        client: widget.client,
                      )
                    : selectedView == View.CLINICS
                        ? ClientVisitHistory(widget.client)
                        : selectedView == View.ARV
                            ? ArvHistory(
                                client: widget.client,
                              )
                            : selectedView == View.PHARMACY
                                ? ClientPharmacyHistory(
                                    client: widget.client,
                                  )
                                : selectedView == View.VITALS
                                    ? ClientVitalsHistory(widget.client)
                                    : selectedView == View.DIAGNOSIS
                                        ? ClientDiagnosisHistory(widget.client)
                                        : selectedView == View.LAB
                                            ? ClientLabOrders(widget.client)
                                            : selectedView == View.ALLERGIES
                                                ? ClientAllergyHistory(
                                                    widget.client)
                                                : Container(
                                                    color: Colors.white,
                                                    child: Center(
                                                      child: Text(
                                                        "Screen not implemented",
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  )),
            Container(
              color: Colors.white,
              child: Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ViewHolderMenu(
                      text: "Profile",
                      icon: Icons.account_box_outlined,
                      selected: selectedView == View.DASHBOARD,
                      onTap: () {
                        if (selectedView != View.DASHBOARD) {
                          setState(() {
                            selectedView = View.DASHBOARD;
                          });
                        }
                      },
                    ),
                    ViewHolderMenu(
                      text: "Vitals",
                      icon: Icons.favorite_border,
                      selected: selectedView == View.VITALS,
                      onTap: () {
                        if (selectedView != View.VITALS) {
                          setState(() {
                            selectedView = View.VITALS;
                          });
                        }
                      },
                    ),
                    ViewHolderMenu(
                      text: "Allergies",
                      icon: Icons.local_hospital_outlined,
                      selected: selectedView == View.ALLERGIES,
                      onTap: () {
                        if (selectedView != View.ALLERGIES) {
                          setState(() {
                            selectedView = View.ALLERGIES;
                          });
                        }
                      },
                    ),
                    ViewHolderMenu(
                      text: "Clinic",
                      icon: Icons.local_hospital_outlined,
                      selected: selectedView == View.CLINICS,
                      onTap: () {
                        if (selectedView != View.CLINICS) {
                          setState(() {
                            selectedView = View.CLINICS;
                          });
                        }
                      },
                    ),
                    ViewHolderMenu(
                      text: "Diagnosis",
                      icon: Icons.wysiwyg_rounded,
                      selected: selectedView == View.DIAGNOSIS,
                      onTap: () {
                        if (selectedView != View.DIAGNOSIS) {
                          setState(() {
                            selectedView = View.DIAGNOSIS;
                          });
                        }
                      },
                    ),
                    ViewHolderMenu(
                      text: "Tests",
                      icon: Icons.file_copy_outlined,
                      selected: selectedView == View.LAB,
                      onTap: () {
                        if (selectedView != View.LAB) {
                          setState(() {
                            selectedView = View.LAB;
                          });
                        }
                      },
                    ),
                    // ViewHolderMenu(
                    //   text: "Pharm",
                    //   icon: Icons.local_pharmacy_outlined,
                    //   selected: selectedView == View.PHARMACY,
                    //   onTap: () {
                    //     if (selectedView != View.PHARMACY) {
                    //       setState(() {
                    //         selectedView = View.PHARMACY;
                    //       });
                    //     }
                    //   },
                    // ),
                    // ViewHolderMenu(
                    //   text: "ARV",
                    //   icon: Icons.medical_services_outlined,
                    //   selected: selectedView == View.ARV,
                    //   onTap: () {
                    //     if (selectedView != View.ARV) {
                    //       setState(() {
                    //         selectedView = View.ARV;
                    //       });
                    //     }
                    //   },
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

enum View {
  DASHBOARD,
  LAB,
  CLINICS,
  ARV,
  PHARMACY,
  VITALS,
  DIAGNOSIS,
  ALLERGIES
}
