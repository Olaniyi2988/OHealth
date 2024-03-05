import 'package:kp/models/metadata.dart';
import 'package:kp/util.dart';

class Diagnosis {
  String note;
  DateTime onsetDate;
  int conditionId;
  int severityId;
  DateTime diagnosisDate;

  Diagnosis(
      {this.conditionId,
      this.diagnosisDate,
      this.note,
      this.onsetDate,
      this.severityId});

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
        note: json['clinical_note'],
        onsetDate: convertStringToDateTime(json['onset_date']),
        conditionId: json['diagnosed_condition_id'],
        severityId: json['severity_id'],
        diagnosisDate: convertStringToDateTime(json['diagnosed_date']));
  }
}
