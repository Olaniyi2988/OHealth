import 'package:kp/util.dart';

class ClientAppointment {
  int appointmentId;
  String clientIdentifier;
  String purpose;
  bool cancelled;
  DateTime date;

  ClientAppointment(
      {this.date,
      this.appointmentId,
      this.cancelled,
      this.clientIdentifier,
      this.purpose});

  factory ClientAppointment.fromJson(Map<String, dynamic> json) {
    return ClientAppointment(
        date: convertStringToDateTime(json['appointment_date']),
        appointmentId: json['clinical_appointment_id'],
        purpose: json['appointment_purpose'],
        cancelled: json['canceled'],
        clientIdentifier: json['client_unique_identifier']);
  }
}
