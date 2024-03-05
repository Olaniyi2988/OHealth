class Allergy {
  int allergyId;
  int allergenId;
  int severityId;
  String observation;

  Allergy({this.observation, this.allergenId, this.allergyId, this.severityId});

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
        allergenId: json['allergen_id'],
        allergyId: json['allergy_id'],
        severityId: json['severity_id'],
        observation: json['observation']);
  }
}
