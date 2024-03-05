import 'package:flutter/material.dart';
import 'package:kp/api/appointment_api.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/page_provider.dart' as pageProvider;
import 'package:kp/util.dart';
import 'package:kp/views/analytics.dart';
import 'package:kp/views/clinics_home.dart';
import 'package:kp/views/lab_home.dart';
import 'package:kp/views/offline_programs_data.dart';
import 'package:kp/views/pharmacy_options.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:kp/views/appointments.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return Column(
              children: [
                Expanded(
                    child: GridView.count(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  crossAxisCount: orientation == Orientation.landscape ||
                          info.isTablet == true
                      ? 3
                      : 2,
                  children: [
                    MenuCard(
                      color: Colors.blueAccent,
                      asset: 'images/appointment.png',
                      title: 'Appointments',
                      onTap: () {
                        showPersistentLoadingIndicator(context);
                        AppointmentApi.getAppointments(
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .serviceProvider
                                    .userId)
                            .then((appointments) {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AppointmentView(
                                      clientAppointments: appointments)));
                        }).catchError((err) {
                          Navigator.pop(context);
                          showBasicMessageDialog(err.toString(), context);
                        });
                      },
                    ),
                    MenuCard(
                      asset: 'images/stethoscope.png',
                      title: 'Clinics',
                      color: Colors.purple,
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClinicsHome()));
                      },
                    ),
                    MenuCard(
                      asset: 'images/prescription.png',
                      title: 'Pharmacy',
                      color: Colors.pinkAccent,
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PharmacyOptions()));
                      },
                    ),
                    MenuCard(
                      asset: 'images/test.png',
                      title: 'Lab',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LabHome()));
                      },
                      color: Colors.greenAccent,
                    ),
                    MenuCard(
                      asset: 'images/reg.png',
                      title: 'KP Registration',
                      onTap: () {
                        Provider.of<pageProvider.PageProvider>(context,
                                listen: false)
                            .setCurrentPage(pageProvider.Page.REGISTRATION);
                      },
                      color: Colors.redAccent,
                    ),
                    MenuCard(
                      asset: 'images/people.png',
                      title: 'KP Portal',
                      onTap: () {
                        Provider.of<pageProvider.PageProvider>(context,
                                listen: false)
                            .setCurrentPage(pageProvider.Page.PATIENTS);
                      },
                      color: Colors.tealAccent,
                    ),
                    MenuCard(
                      asset: 'images/forms.png',
                      title: 'Service Forms',
                      color: Colors.purple,
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OfflineProgramsData()));
                      },
                    ),
                    MenuCard(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnalyticsView()));
                      },
                      asset: 'images/stats.png',
                      title: 'Analytics',
                      color: Colors.amber,
                    ),
                  ],
                ))
              ],
            );
          },
        );
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final Color color;
  final String asset;
  final Function onTap;
  MenuCard({this.asset, this.title, this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: Card(
          color: color,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              color: color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.5,
                    child: Image.asset(
                      asset,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
