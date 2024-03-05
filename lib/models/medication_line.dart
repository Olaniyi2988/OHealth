class MedicationLine {
  int id;
  String name;
  String code;
  String description;
  List<Regimen> regimens;

  MedicationLine(
      {this.id, this.name, this.code, this.description, this.regimens});

  factory MedicationLine.fromJson(Map<String, dynamic> json) {
    List<Regimen> regimens = [];
    json['regimen'].forEach((reg) {
      regimens.add(Regimen.fromJson(reg));
    });
    return MedicationLine(
        id: json['medicationline_id'],
        name: json['name'],
        code: json['code'],
        description: json['description'],
        regimens: regimens);
  }

  @override
  String toString() {
    return name + code;
  }
}

class Regimen {
  int id;
  String name;
  String dosage;
  int frequencyId;
  int medicationId;
  DrugFrequency drugFrequency;

  @override
  String toString() {
    return name + dosage;
  }

  Regimen(
      {this.drugFrequency,
      this.name,
      this.id,
      this.dosage,
      this.frequencyId,
      this.medicationId});

  factory Regimen.fromJson(Map<String, dynamic> json) {
    return Regimen(
        id: json['regimencombo_id'],
        name: json['name'],
        dosage: json['dosage'],
        frequencyId: json['drug_frequency_id'],
        medicationId: json['medicationline_id'],
        drugFrequency: DrugFrequency.fromJson(json['drugUsageFrequency']));
  }
}

class DrugFrequency {
  int id;
  String name;
  String code;
  String description;

  @override
  String toString() {
    return name + code;
  }

  DrugFrequency({this.id, this.description, this.name, this.code});

  factory DrugFrequency.fromJson(Map<String, dynamic> json) {
    return DrugFrequency(
        id: json['drug_frequency_id'],
        name: json['name'],
        code: json['code'],
        description: json['description']);
  }
}
