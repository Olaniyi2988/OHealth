import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kp/api/appointment_api.dart';
import 'package:kp/models/appointment.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_date_selector.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:kp/widgets/custom_time_picker.dart';
import 'package:kp/views/patients.dart' as patients;

class AppointmentView extends StatefulWidget {
  final Client client;
  final List<ClientAppointment> clientAppointments;
  AppointmentView({this.client, this.clientAppointments = const []});
  @override
  State createState() => AppointmentViewState();
}

class AppointmentViewState extends State<AppointmentView> {
  _DataSource events;
  List<Appointment> appointments;
  List<Color> colorCollection;
  Appointment _selectedAppointment;
  CalendarView calendarView = CalendarView.schedule;
  List<ClientAppointment> clientAppointments;

  @override
  void initState() {
    appointments = <Appointment>[];
    clientAppointments = widget.clientAppointments;
    addAppointmentDetails();
    addAppointments();
    events = _DataSource(appointments);
    super.initState();
  }

  void _onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    /// Condition added to open the editor, when the calendar elements tapped
    /// other than the header.
    if (calendarTapDetails.targetElement == CalendarElement.header ||
        calendarTapDetails.targetElement == CalendarElement.viewHeader ||
        calendarTapDetails.targetElement == CalendarElement.resourceHeader) {
      return;
    }

    _selectedAppointment = null;

    if (calendarTapDetails.appointments != null &&
        calendarTapDetails.targetElement == CalendarElement.appointment) {
      _selectedAppointment = calendarTapDetails.appointments[0];
    }

    final DateTime selectedDate = calendarTapDetails.date;
    final CalendarElement targetElement = calendarTapDetails.targetElement;

    if (_selectedAppointment.notes == "") {
      return Navigator.pop(context);
    }

    ClientAppointment clientAppointment;
    widget.clientAppointments.forEach((element) {
      if (_selectedAppointment.subject + "${_selectedAppointment.notes}" ==
          "${element.clientIdentifier}:   ${element.purpose}${element.appointmentId}") {
        clientAppointment = element;
      }
    });

    if (clientAppointment == null) {
      return showBasicMessageDialog(
          "This appointment has been cancelled", context);
    }

    showDialog(
        context: context,
        builder: (context) {
          TextEditingController clientController =
              TextEditingController(text: clientAppointment.clientIdentifier);
          TextEditingController purposeController =
              TextEditingController(text: clientAppointment.purpose);
          return AlertDialog(
            contentPadding: EdgeInsets.all(10),
            title: SectionHeader(
              text: "Appointment Details",
            ),
            content: SizedBox(
              width: 10000,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabeledTextField(
                      readOnly: true,
                      controller: clientController,
                      text: "Select Client",
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    LabeledTextField(
                      text: "Purpose",
                      controller: purposeController,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomDateSelector(
                        title: "Date",
                        futureOnly: true,
                        readOnly: true,
                        initialDate: clientAppointment.date),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(color: Colors.white),
                  )),
              ElevatedButton(
                  onPressed: () async {
                    var reason = await showBasicPromptDialog(
                        "Why are you cancelling", context);
                    if (reason == "null" || reason == "" || reason == null) {
                      return;
                    }
                    Map<String, dynamic> payload = {
                      "cancellation_reason": reason,
                      "canceled_by":
                          Provider.of<AuthProvider>(context, listen: false)
                              .serviceProvider
                              .userId,
                      "canceled_date": DateTime.now().toIso8601String(),
                      "clinical_appointment_id": clientAppointment.appointmentId
                    };
                    showPersistentLoadingIndicator(context);
                    AppointmentApi.cancelClinicalAppointment(payload)
                        .then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      showBasicMessageDialog("Appointment cancelled", context);
                      setState(() {
                        clientAppointments.forEach((element) {
                          if (element.appointmentId ==
                              clientAppointment.appointmentId) {
                            element.cancelled = true;
                          }
                        });
                        addAppointments();
                        events = _DataSource(appointments);
                      });
                    }).catchError((err) {
                      Navigator.pop(context);
                      showBasicMessageDialog(err.toString(), context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                  ),
                  child: Text(
                    'Cancel Appointment',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          );
        });
  }

  void addAppointmentDetails() {
    colorCollection = <Color>[];
    colorCollection.add(const Color(0xFF0F8644));
    colorCollection.add(const Color(0xFF8B1FA9));
    colorCollection.add(const Color(0xFFD20100));
    colorCollection.add(const Color(0xFFFC571D));
    colorCollection.add(const Color(0xFF36B37B));
    colorCollection.add(const Color(0xFF01A1EF));
    colorCollection.add(const Color(0xFF3D4FB5));
    colorCollection.add(const Color(0xFFE47C73));
    colorCollection.add(const Color(0xFF636363));
    colorCollection.add(const Color(0xFF0A8043));
  }

  void addAppointments() {
    final Random random = Random();
    appointments = [];
    clientAppointments.forEach((element) {
      appointments.add(Appointment(
        subject: element.cancelled == true
            ? "${element.clientIdentifier}:   ${element.purpose} (cancelled)"
            : "${element.clientIdentifier}:   ${element.purpose}",
        notes: "${element.appointmentId}",
        startTime: element.date,
        endTime: DateTime(element.date.year, element.date.month,
            element.date.day, element.date.hour + 1, element.date.minute),
        color: colorCollection[random.nextInt(9)],
        isAllDay: false,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                TextEditingController clientController =
                    TextEditingController();
                TextEditingController purposeController =
                    TextEditingController();
                DateTime selectedDate;
                TimeOfDay selectedTime;
                GlobalKey<FormState> key = GlobalKey();
                if (widget.client != null) {
                  clientController.text = widget.client.hospitalNum;
                }
                return AlertDialog(
                  contentPadding: EdgeInsets.all(10),
                  title: SectionHeader(
                    text: "Schedule Appointment",
                  ),
                  content: SizedBox(
                    width: 10000,
                    child: SingleChildScrollView(
                      child: Form(
                        key: key,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LabeledTextField(
                              readOnly: true,
                              controller: clientController,
                              text: "Select Client",
                              validator: (val) {
                                if (val.length == 0) {
                                  return "Can't be empty";
                                }

                                return null;
                              },
                              onTap: () async {
                                if (widget.client == null) {
                                  Client client = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  iconTheme: IconThemeData(
                                                      color: Colors.white),
                                                  title: Text('Select Client'),
                                                  backgroundColor:
                                                      Colors.blueAccent,
                                                ),
                                                body: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child:
                                                      patients.OnlinePatients(
                                                    isSelect: true,
                                                  ),
                                                ),
                                              )));
                                  if (client != null) {
                                    print(client.hospitalNum);
                                    clientController.text = client.hospitalNum;
                                  }
                                }
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            LabeledTextField(
                              text: "Purpose",
                              controller: purposeController,
                              validator: (val) {
                                if (val.length == 0) {
                                  return "Can't be empty";
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomDateSelector(
                              title: "Date",
                              futureOnly: true,
                              onDateChanged: (date) {
                                selectedDate = date;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTimeSelector(
                              title: 'Time',
                              onTimeChanged: (time) {
                                selectedTime = time;
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton(
                        onPressed: () {
                          if (key.currentState.validate()) {
                            if (selectedDate == null || selectedTime == null) {
                              return showBasicMessageDialog(
                                  "Enter all details", context);
                            }

                            Map<String, dynamic> payload = {
                              "service_provider_id": Provider.of<AuthProvider>(
                                      context,
                                      listen: false)
                                  .serviceProvider
                                  .userId,
                              "created_by": Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .serviceProvider
                                  .userId,
                              "client_unique_identifier":
                                  clientController.text.trim(),
                              "appointment_purpose":
                                  purposeController.text.trim(),
                              "created_date": DateTime.now().toIso8601String(),
                              "appointment_date": DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute)
                                  .toIso8601String()
                            };
                            showPersistentLoadingIndicator(context);
                            AppointmentApi.postClinicalAppointment(payload)
                                .then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              showBasicMessageDialog(
                                  "Appointment created", context);
                              final Random random = Random();
                              setState(() {
                                appointments.add(Appointment(
                                  subject:
                                      "${clientController.text}:   ${purposeController.text}",
                                  notes: "",
                                  startTime: DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute),
                                  endTime: DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour + 1,
                                      selectedTime.minute),
                                  color: colorCollection[random.nextInt(9)],
                                  isAllDay: false,
                                ));
                                events = _DataSource(appointments);
                              });
                            }).catchError((err) {
                              Navigator.pop(context);
                              showBasicMessageDialog(err.toString(), context);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                        ),
                        child: Text(
                          'Schedule',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Appointments'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Padding(
          //   padding: EdgeInsets.all(10),
          //   child: GestureDetector(
          //     onTap: (){
          //       if(calendarView==CalendarView.schedule){
          //         setState(() {
          //           calendarView=CalendarView.month;
          //         });
          //       }else{
          //         setState(() {
          //           calendarView=CalendarView.schedule;
          //         });
          //       }
          //     },
          //     child: Icon(
          //         Icons.swap_horiz
          //     ),
          //   ),
          // )
        ],
      ),
      body: SfCalendar(
        showDatePickerButton: true,
        view: calendarView,
        dataSource: events,
        scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
        onTap: _onCalendarTapped,
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

Widget scheduleViewBuilder(
    BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
  final String monthName = _getMonthDate(details.date.month);
  return Stack(
    children: [
      Image(
          image: ExactAssetImage('images/' + monthName + '.png'),
          fit: BoxFit.cover,
          width: details.bounds.width,
          height: details.bounds.height),
      Positioned(
        left: 55,
        right: 0,
        top: 20,
        bottom: 0,
        child: Text(
          monthName + ' ' + details.date.year.toString(),
          style: TextStyle(fontSize: 18),
        ),
      )
    ],
  );
}

String _getMonthDate(int month) {
  if (month == 01) {
    return 'January';
  } else if (month == 02) {
    return 'February';
  } else if (month == 03) {
    return 'March';
  } else if (month == 04) {
    return 'April';
  } else if (month == 05) {
    return 'May';
  } else if (month == 06) {
    return 'June';
  } else if (month == 07) {
    return 'July';
  } else if (month == 08) {
    return 'August';
  } else if (month == 09) {
    return 'September';
  } else if (month == 10) {
    return 'October';
  } else if (month == 11) {
    return 'November';
  } else {
    return 'December';
  }
}
