class LocalGovernment {
  int lgaId;
  int id;
  int stateId;
  String name;
  String code;

  LocalGovernment({this.name, this.code, this.lgaId, this.stateId, this.id});

  factory LocalGovernment.fromJson(Map json) {
    return LocalGovernment(
        lgaId: json['local_government_area_id'],
        stateId: json['state_id'],
        name: json['name'],
        code: json['code'],
        id: json['local_government_area_id']);
  }

  Map toJson() {
    return {
      "local_government_area_id": lgaId,
      "state_id": stateId,
      "name": name,
      "code": code
    };
  }

  @override
  String toString() {
    return "$lgaId$name$code";
  }
}
