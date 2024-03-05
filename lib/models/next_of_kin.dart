import 'package:kp/models/metadata.dart';

class NextOfKin {
  String lastName;
  String firstName;
  String otherName;
  String phoneNumber;
  String altNumber;
  String contactAddress;
  KpMetaData gender;
  KpMetaData relationship;
  KpMetaData occupation;

  NextOfKin(
      {this.firstName,
      this.occupation,
      this.gender,
      this.lastName,
      this.altNumber,
      this.contactAddress,
      this.otherName,
      this.phoneNumber,
      this.relationship});
}
