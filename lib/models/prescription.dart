import 'package:kp/models/metadata.dart';
import 'package:kp/util.dart';

class Prescription {
  KpMetaData drug;
  int dose;
  int drugFrequencyId;
  int drugUnitId;
  int drugId;
  KpMetaData drugUnits;
  KpMetaData drugFrequency;
  String note;
  DateTime prescriptionDate;

  Prescription(
      {this.drugUnits,
      this.drugFrequency,
      this.dose,
      this.drug,
      this.note,
      this.prescriptionDate,
      this.drugFrequencyId,
      this.drugUnitId,
      this.drugId});

  factory Prescription.fromJson(Map json) {
    return Prescription(
        drug: json['drugs'] == null
            ? null
            : KpMetaData.fromJsonOnly(json['drugs']),
        drugFrequency: json['drugfrequency'] == null
            ? null
            : KpMetaData.fromJsonOnly(json['drugfrequency']),
        drugUnits: json['drugunits'] == null
            ? null
            : KpMetaData.fromJsonOnly(json['drugunits']),
        dose: json['dose'] == null ? null : json['dose'],
        note: json['prescription_note'],
        prescriptionDate: convertStringToDateTime(json['prescription_date']),
        drugFrequencyId: json['drug_frequency_id'],
        drugUnitId: json['drug_unit_id'],
        drugId: json['drug_id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_id': drug.id,
      'dose': dose,
      'drug_frequency_id': drugFrequency.id,
      'drug_unit_id': drugUnits.id,
      'prescription_note': note,
      'prescription_date': prescriptionDate.toIso8601String()
    };
  }
}
