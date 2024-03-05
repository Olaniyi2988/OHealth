import 'package:kp/models/metadata.dart';
import 'package:kp/util.dart';

class ClinicalService {
  String clientUniqueIdentifier;
  int id;
  double weight;
  double height;
  int systolic;
  int diastolic;

  int pregnancyStatusId;

  int opportunisticInfectionId;

  int adherenceId;

  int clinicalStageId;

  int functionalStatusId;

  int tbStatusId;

  String clinicalNote;
  DateTime dateOfFirstVisit;
  DateTime dateOfLastVisit;
  List<ClinicalService> visitHistory = [];

  ClinicalService(
      {this.dateOfFirstVisit,
      this.diastolic,
      this.systolic,
      this.height,
      this.weight,
      this.id,
      this.clinicalNote,
      this.clientUniqueIdentifier,
      this.dateOfLastVisit,
      this.pregnancyStatusId,
      this.tbStatusId,
      this.functionalStatusId,
      this.clinicalStageId,
      this.adherenceId,
      this.opportunisticInfectionId});

  factory ClinicalService.fromJson(Map<String, dynamic> json) {
    return ClinicalService(
        clientUniqueIdentifier: json['client_unique_identifier'],
        id: json['clinical_service_id'],
        clinicalStageId: json['clinical_stages_id'],
        functionalStatusId: json['functional_status_id'],
        tbStatusId: json['tb_status_id'],
        weight: double.parse(json['weight'].toString()),
        height: double.parse(json['height'].toString()),
        pregnancyStatusId: json['pregnancy_status_id'],
        systolic: int.parse(json['systolic'].toString()),
        diastolic: int.parse(json['diastolic'].toString()),
        dateOfFirstVisit: convertStringToDateTime(json['date_of_first_visit']),
        dateOfLastVisit: convertStringToDateTime(json['date_of_last_visit']),
        clinicalNote: json['clinical_note']);
  }
}
