class LabTestType {
  int labTestTypeId;
  String name;
  String code;
  String description;
  int id;

  LabTestType(
      {this.name, this.code, this.labTestTypeId, this.description, this.id});

  factory LabTestType.formJson(Map<String, dynamic> json) {
    return LabTestType(
        name: json['name'],
        code: json['code'],
        labTestTypeId: json['labTestTypeId'],
        id: json['labTestTypeId']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'code': code,
      'labTestTypeId': labTestTypeId,
    };
  }

  @override
  String toString() {
    return "$labTestTypeId$name$code";
  }
}

class LabTest {
  int labTestTypeId;
  int labTestId;
  String name;
  String code;
  String description;
  int id;

  LabTest(
      {this.name,
      this.code,
      this.labTestTypeId,
      this.description,
      this.labTestId,
      this.id});

  factory LabTest.formJson(Map<String, dynamic> json) {
    return LabTest(
        name: json['name'],
        code: json['code'],
        labTestTypeId: json['labTestTypeId'],
        labTestId: json['labTestId'],
        id: json['labTestId']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'code': code,
      'labTestTypeId': labTestTypeId,
      'labTestId': labTestId
    };
  }

  @override
  String toString() {
    return "$labTestId$labTestTypeId$name$code";
  }
}
