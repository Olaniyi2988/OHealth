class ClinicalStage {
  int id;
  String name;
  String code;
  String description;

  ClinicalStage({this.description, this.code, this.name, this.id});

  factory ClinicalStage.fromJson(Map<String, dynamic> json) {
    return ClinicalStage(
        id: json['clinical_stages_id'],
        name: json['name'],
        code: json['code'],
        description: json['description']);
  }

  @override
  String toString() {
    return id.toString() + name + code + description;
  }
}
