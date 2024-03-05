import 'package:kp/util.dart';

class Vitals {
  DateTime dateOfVital;
  int pulse;
  int respiratoryRate;
  int temperature;
  int weight;
  int height;
  int systolicPressure;
  int diastolicPressure;

  Vitals(
      {this.diastolicPressure,
      this.systolicPressure,
      this.weight,
      this.temperature,
      this.respiratoryRate,
      this.pulse,
      this.dateOfVital,
      this.height});

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
        dateOfVital: convertStringToDateTime(json['created_date']),
        pulse: json['pulse'],
        respiratoryRate: json['respiratory_rate'],
        temperature: json['temperature'],
        weight: json['weight'],
        systolicPressure: json['systolic'],
        height: json['height'],
        diastolicPressure: json['diastolic']);
  }

  Map<String, dynamic> toJson() {
    return {
      'date_of_vitals': dateOfVital.millisecondsSinceEpoch,
      'pulse': pulse,
      'respiratory_rate': respiratoryRate,
      'temperature': temperature,
      'weight': weight,
      'systolic_pressure': systolicPressure,
      'diastolic_pressure': diastolicPressure
    };
  }
}
