import 'package:flutter/material.dart';
import 'package:kp/api/clients_api.dart';
import 'package:kp/api/programs.dart';
import 'package:kp/db/clients.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/lab_order.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/views/arv_history.dart';
import 'package:kp/views/assessment.dart';
import 'package:kp/views/client_lab_order.dart';
import 'package:kp/views/client_dashboard.dart';
import 'package:kp/views/client_pharmacy_orders.dart';
import 'package:kp/views/edit_client.dart';
import 'package:kp/views/programs_home.dart';
import 'package:provider/provider.dart';

class PatientTile extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final bool header;
  final bool isLabPatient;
  final bool showOptions;
  final LaboratoryOrder labPatient;
  PatientTile(
      {this.client,
      this.onTap,
      this.header = false,
      this.isLabPatient = false,
      this.showOptions = true,
      this.labPatient});
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
        fontWeight: header == true ? FontWeight.bold : FontWeight.w400,
        fontSize: header == true ? 18 : 13);
    EdgeInsets padding = EdgeInsets.only(top: 15, bottom: 15);
    return InkWell(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                isLabPatient == true
                    ? Container()
                    : Expanded(
                        flex: 2,
                        child: Container(
                          padding: padding,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                header == true
                                    ? 'Name'
                                    : client.firstName + " " + client.surname,
                                style: style,
                              ),
                            ),
                          ),
                        )),
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: padding,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            header == true
                                ? 'Hospial Number'
                                : isLabPatient == true
                                    ? labPatient.hospitalNumber
                                    : client.hospitalNum,
                            style: style,
                          ),
                        ),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                      padding: padding,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            header == true
                                ? isLabPatient == true
                                    ? 'Last Order Date'
                                    : 'Age'
                                : isLabPatient == true
                                    ? labPatient.date == null
                                        ? ""
                                        : convertDateToString(labPatient.date)
                                    : convertDateOfBirthToAge(client.dob)
                                        .toString(),
                            style: style,
                          ),
                        ),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: padding,
                      child: Align(
                        alignment: header == true
                            ? Alignment.topCenter
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            header == true
                                ? '${isLabPatient == true ? 'Prescribed by' : 'Contact'}'
                                : isLabPatient == true
                                    ? labPatient.prescribedBy
                                    : client.phone,
                            style: style,
                          ),
                        ),
                      ),
                    )),
                SizedBox(
                  width: 40,
                  child: header == true
                      ? Container()
                      : showOptions == true
                          ? ClientOptions(
                              isLabPatient: isLabPatient,
                              labPatient: labPatient,
                              client: client,
                            )
                          : Container(),
                )
              ],
            ),
            header == true ? Divider() : Container()
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}

class ClientOptions extends StatelessWidget {
  final Client client;
  final bool isDashboard;
  final bool isLabPatient;
  final LaboratoryOrder labPatient;
  ClientOptions(
      {this.client,
      this.isDashboard = false,
      this.isLabPatient = false,
      this.labPatient});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onCanceled: () {
        Provider.of<AuthProvider>(context, listen: false)
            .resetInactivityTimer();
      },
      child: Icon(Icons.more_vert),
      itemBuilder: (context) {
        return [
          isLabPatient == true
              ? null
              : client.isRegisteredOnline == false
                  ? null
                  : isDashboard
                      ? null
                      : PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.dashboard),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Client Dashboard')
                            ],
                          ),
                          value: 'dashboard',
                        ),
          isLabPatient == true
              ? null
              : client.isRegisteredOnline == false
                  ? null
                  : PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Programs and services')
                        ],
                      ),
                      value: 'services',
                    ),
          isLabPatient == true
              ? null
              : client.isRegisteredOnline == false
                  ? null
                  : PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.assessment_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Take Assessment')
                        ],
                      ),
                      value: 'assessment',
                    ),
          isLabPatient == true
              ? null
              : PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Edit Client')
                    ],
                  ),
                  value: 'edit',
                ),
          isLabPatient == true
              ? null
              : client.isRegisteredOnline == true
                  ? null
                  : PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.cloud_upload_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Upload client')
                        ],
                      ),
                      value: 'upload',
                    ),
          isLabPatient == true
              ? null
              : client.isRegisteredOnline == true
                  ? null
                  : PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Delete Client')
                        ],
                      ),
                      value: 'delete',
                    ),
          // client.isRegisteredOnline == false
          //     ? null
          //     : PopupMenuItem(
          //         child: Row(
          //           children: [
          //             Icon(Icons.local_hospital),
          //             SizedBox(
          //               width: 10,
          //             ),
          //             Text('See all tests')
          //           ],
          //         ),
          //         value: 'viewTests',
          //       ),
          client.isRegisteredOnline == false
              ? null
              : PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.local_pharmacy_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Pharmacy')
                    ],
                  ),
                  value: 'pharm',
                ),
          client.isRegisteredOnline == false
              ? null
              : PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.local_pharmacy_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text('ARV')
                    ],
                  ),
                  value: 'arv',
                ),
        ];
      },
      onSelected: (value) async {
        Provider.of<AuthProvider>(context, listen: false)
            .resetInactivityTimer();
        if (value == 'dashboard') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientDashboard(
                        client: client,
                      )));
        } else if (value == 'edit') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditClient(
                        client: client,
                      )));
        } else if (value == 'delete') {
          bool val = await showBasicConfirmationDialog(
              'Are you sure you want to delete this client?', context);
          if (val == true) {
            showPersistentLoadingIndicator(context);
            ClientsDB.getInstance()
                .deleteClient(client.localDBIdentifier)
                .then((value) {
              if (isDashboard == false) {
                Navigator.pop(context);
              } else {
                Navigator.popUntil(context, ModalRoute.withName('home'));
              }
              showBasicMessageDialog("Client Deleted Successfully", context);
            }).catchError((err) {
              Navigator.pop(context);
              showBasicMessageDialog(err.toString(), context);
            });
          }
        } else if (value == 'assessment') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AssessmentView(
                        client: client,
                      )));
        } else if (value == 'upload') {
          showPersistentLoadingIndicator(context);
          ClientApi.postClinicalRegistrationBulk([client], context)
              .then((value) {
            Navigator.pop(context);
            showBasicMessageDialog('Client uploaded', context);
          }).catchError((err) {
            Navigator.pop(context);
            showBasicMessageDialog(err.toString(), context);
          });
        } else if (value == 'services') {
          showPersistentLoadingIndicator(context);
          ProgramsApi.getPrograms(returnCache: true).then((programs) {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProgramsMenu(
                          programs: programs,
                          clientUniqueIdentifier: client.hospitalNum,
                        )));
          }).catchError((err) {
            Navigator.pop(context);
            showBasicMessageDialog(err.toString(), context);
          });
        } else if (value == 'viewTests') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ClientLabOrders(client)));
        } else if (value == 'pharm') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientPharmacyHistory(client: client)));
        } else if (value == 'arv') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArvHistory(client: client)));
        }
      },
    );
  }
}
