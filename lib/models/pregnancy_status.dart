class PregnancyStatus {
  int id;
  String name;
  String code;
  String description;

  PregnancyStatus({this.id, this.name, this.code, this.description});

  factory PregnancyStatus.fromJson(Map<String, dynamic> json) {
    return PregnancyStatus(
        name: json['name'],
        id: json['pregnancy_id'],
        code: json['code'],
        description: json['description']);
  }

  @override
  String toString() {
    return id.toString() + name + code + description;
  }
}
