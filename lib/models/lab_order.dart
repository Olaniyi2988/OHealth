import 'package:kp/models/lab.dart';
import 'package:kp/util.dart';

class LaboratoryOrder {
  String hospitalNumber;
  DateTime date;
  String note;
  String prescribedBy;
  int orderNumber;
  int testId;
  String status;
  LabTest test;

  LaboratoryOrder(
      {this.hospitalNumber = "",
      this.prescribedBy = "",
      this.date,
      this.orderNumber,
      this.testId,
      this.status = "",
      this.note});
  factory LaboratoryOrder.fromJson(Map<String, dynamic> json) {
    return LaboratoryOrder(
        hospitalNumber: json['client_unique_identifier'],
        note: json['laboratory_test_note'],
        date: json['ordered_date'] == null
            ? null
            : convertStringToDateTime(json['ordered_date']),
        status: json['laboratory_test_status'],
        testId: json['laboratory_test_id'],
        prescribedBy: json['users'] == null ? null : json['users']['username']);
  }
}
