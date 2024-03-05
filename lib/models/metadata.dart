class KpMetaData {
  int id;
  String name;
  String code;
  String description;

  KpMetaData({this.name, this.code, this.id, this.description});

  factory KpMetaData.fromJsonOnly(Map<String, dynamic> json) {
    return KpMetaData(name: json['name'], code: json['code'], id: json['id']);
  }

  factory KpMetaData.fromJson(Map<String, dynamic> json, String idName) {
    try {
      return KpMetaData(
          id: json[idName],
          name: json['name'],
          code: json['code'],
          description: json['description']);
    } catch (err) {
      return KpMetaData();
    }
  }

  Map toJson() {
    return <String, dynamic>{'name': name, 'code': code, 'id': id};
  }

  @override
  String toString() {
    return "$id$name$code";
  }
}
