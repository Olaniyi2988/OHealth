class HealthStatus {
  int id;
  int typeId;
  String name;
  String code;
  String description;

  HealthStatus({this.description, this.code, this.name, this.id, this.typeId});

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
        id: json['status_id'],
        typeId: json['status_type_id'],
        name: json['name'],
        code: json['code'],
        description: json['description']);
  }

  @override
  String toString() {
    return id.toString() +
        typeId.toString() +
        name.toString() +
        code.toString();
  }
}
