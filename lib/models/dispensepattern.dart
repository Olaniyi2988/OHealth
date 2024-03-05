class DispensePattern {
  int id;
  String name;
  String code;
  int tabletNumber;
  String description;

  DispensePattern(
      {this.name, this.description, this.code, this.id, this.tabletNumber});

  factory DispensePattern.fromJson(Map<String, dynamic> json) {
    return DispensePattern(
        id: json['drugdispensepattern_id'],
        name: json['name'],
        code: json['code'],
        tabletNumber: int.parse(json['tablet_no']),
        description: json['description']);
  }

  @override
  String toString() {
    return name + code + description + id.toString();
  }
}
