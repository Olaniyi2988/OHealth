import 'dart:math';

class HierarchyUnit {
  int id;
  String name;
  bool active;
  List<HierarchyUnit> children;
  int parnetId;
  int hierarchyId;
  bool movedIntoParent = false;
  String altName;
  String code;

  HierarchyUnit(
      {this.id,
      this.name,
      this.children = const [],
      this.active,
      this.altName,
      this.code,
      this.parnetId,
      this.hierarchyId});

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> childrenJson = [];
    if (children != null) {
      children.forEach((element) {
        childrenJson.add(element.toJson());
      });
    }
    return {
      "heirarchyunitid": id,
      "id": id,
      "name": name,
      "active": active,
      'children': childrenJson,
      'parentid': parnetId,
      'altname': altName,
      'code': code,
      'heirarchyid': hierarchyId
    };
  }

  factory HierarchyUnit.fromJson(Map<String, dynamic> json) {
    List<HierarchyUnit> children = [];
    if (json['children'] != null) {
      json['children'].forEach((e) {
        children.add(HierarchyUnit.fromJson(e));
      });
    }

    return HierarchyUnit(
        id: json['heirarchyunitid'],
        name: json['name'],
        active: json['active'],
        parnetId: json['parentid'],
        altName: json['altname'],
        hierarchyId: json['heirarchyid'],
        // code: json['code'] == null ? getRandomString(4) : json['code'],4
        code: json['code'],
        children: children);
  }

  @override
  String toString() {
    return "$id$name$code";
  }
}

const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
