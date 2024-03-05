class Biometrics {
  String leftMid;
  String leftIndex;
  String leftThumb;
  String rightThumb;
  String rightIndex;
  String rightMid;
  String filePath;

  Biometrics(
      {this.leftIndex,
      this.leftMid,
      this.leftThumb,
      this.rightIndex,
      this.rightMid,
      this.rightThumb,
      this.filePath});

  factory Biometrics.fromJson(Map json) {
    return Biometrics(
        leftMid: json['leftMid'],
        leftIndex: json['leftIndex'],
        leftThumb: json['leftThumb'],
        rightThumb: json['rightThumb'],
        rightIndex: json['rightIndex'],
        rightMid: json['rightMid'],
        filePath: json['filePath']);
  }

  Map<String, dynamic> toJson() {
    return {
      "leftMid": leftMid,
      "leftIndex": leftIndex,
      "leftThumb": leftThumb,
      "rightThumb": rightThumb,
      "rightIndex": rightIndex,
      "rightMid": rightMid,
      "filePath": filePath
    };
  }

  List<Map> toPrints() {
    return [
      {"side": "left", "position": "index", "type": "left", "data": leftIndex},
      {
        "side": "right",
        "position": "index",
        "type": "right",
        "data": rightIndex
      },
      {"side": "left", "position": "thumb", "type": "left", "data": leftThumb},
      {
        "side": "right",
        "position": "thumb",
        "type": "right",
        "data": rightThumb
      },
      {"side": "left", "position": "middle", "type": "left", "data": leftMid},
      {"side": "right", "position": "middle", "type": "right", "data": rightMid}
    ];
  }
}
