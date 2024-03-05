class FunctionalStatus {
  String id;
  String name;
  String code;
  String description;

  FunctionalStatus({this.id, this.code, this.name, this.description});

  factory FunctionalStatus.fromJson(Map<String, dynamic> json) {
    return FunctionalStatus(
        id: json['functional_status_id'],
        name: json['name'],
        code: json['code'],
        description: json['description']);
  }
}
