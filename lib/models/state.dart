import 'package:kp/models/local_government.dart';

class KState {
  int stateId;
  int nationalityId;
  String name;
  String code;
  List<LocalGovernment> lgas = [];

  KState({this.code, this.name, this.stateId, this.lgas, this.nationalityId});

  factory KState.fromJson(Map json) {
    List<LocalGovernment> lgas = [];
    json['localgovernmentarea'].forEach((e) {
      lgas.add(LocalGovernment.fromJson(e));
    });
    return KState(
        stateId: json['state_id'],
        nationalityId: json['nationality_id'],
        name: json['name'],
        code: json['code'],
        lgas: lgas);
  }

  Map toJson() {
    return {
      "state_id": stateId,
      "nationality_id": nationalityId,
      "name": name,
      "code": code,
      "localgovernmentarea": lgas.map((e) {
        return e.toJson();
      }).toList()
    };
  }

  @override
  String toString() {
    return "$stateId$name$code";
  }
}
