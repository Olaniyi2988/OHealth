import 'package:kp/models/state.dart';

class Country {
  int nationalityId;
  String name;
  String code;
  List<KState> states = [];

  Country({this.code, this.name, this.nationalityId, this.states});

  factory Country.fromJson(Map json) {
    List<KState> states = [];
    json['state'].forEach((e) {
      states.add(KState.fromJson(e));
    });
    return Country(
        nationalityId: json['nationality_id'],
        name: json['name'],
        code: json['code'],
        states: states);
  }

  Map toJson() {
    return {
      "nationality_id": nationalityId,
      "name": name,
      "code": code,
      'state': states.map((e) {
        return e.toJson();
      }).toList()
    };
  }

  @override
  String toString() {
    return "$nationalityId$name$code";
  }
}
