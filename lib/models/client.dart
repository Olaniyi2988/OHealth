import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kp/models/allergy.dart';
import 'package:kp/models/biometrics.dart';
import 'package:kp/models/country.dart';
import 'package:kp/models/local_government.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/models/next_of_kin.dart';
import 'package:kp/models/state.dart';
import 'package:kp/models/vitals.dart';
import 'package:kp/util.dart';
import 'package:uuid/uuid.dart';

class Client {
  String localDBIdentifier;
  bool biometricsUploadFailed;
  KpMetaData gender;
  String surname;
  String firstName;
  String otherNames;
  String phone;
  String altPhone;
  String residentialAddress;
  KState state;
  LocalGovernment lga;
  Country country;
  DateTime dob;
  DateTime regDate;
  KpMetaData maritalStatus;
  KpMetaData occupation;
  int numberOfChildren;
  int numberOfWives;
  String clientCode;
  int registeredBy;
  String regId;
  Biometrics biometrics;
  List<Vitals> vitalsHistory;
  List<Allergy> allergies;
  bool isRegisteredOnline;
  KpMetaData disability;
  KpMetaData targetGroup;
  KpMetaData careEntryPoint;
  KpMetaData priorArt;
  KpMetaData referredFrom;
  KpMetaData religion;
  KpMetaData language;
  KpMetaData qualification;
  KpMetaData nationality;
  List<NextOfKin> nextOfKins;
  int userId;
  String uuid;
  String hospitalNum;
  String email;
  int patientId;
  String facilityPath;
  String facilityName;
  int facilityId;
  bool biometricsUploaded;

  Client(
      {this.maritalStatus,
      this.gender,
      this.country,
      this.altPhone,
      this.phone,
      this.occupation,
      this.dob,
      this.firstName,
      this.otherNames,
      this.surname,
      this.numberOfWives,
      this.numberOfChildren,
      this.lga,
      this.state,
      this.residentialAddress,
      this.regDate,
      this.clientCode,
      this.registeredBy,
      this.regId,
      this.vitalsHistory,
      this.biometrics,
      this.allergies,
      this.isRegisteredOnline,
      this.disability,
      this.targetGroup,
      this.careEntryPoint,
      this.priorArt,
      this.referredFrom,
      this.uuid,
      this.userId,
      this.religion,
      this.language,
      this.qualification,
      this.nationality,
      this.email,
      this.patientId,
      this.hospitalNum,
      this.facilityPath,
      this.facilityId,
      this.facilityName,
      this.nextOfKins,
      this.biometricsUploaded = false,
      this.localDBIdentifier,
      this.biometricsUploadFailed = false}) {
    if (localDBIdentifier == null) {
      localDBIdentifier = Uuid().v4();
    }
  }

  Client copy() {
    return Client(
        maritalStatus: this.maritalStatus,
        gender: this.gender,
        country: this.country,
        altPhone: this.altPhone,
        phone: this.phone,
        occupation: this.occupation,
        dob: this.dob,
        firstName: this.firstName,
        otherNames: this.otherNames,
        surname: this.surname,
        numberOfWives: this.numberOfWives,
        numberOfChildren: this.numberOfChildren,
        lga: this.lga,
        state: this.state,
        residentialAddress: this.residentialAddress,
        regDate: this.regDate,
        clientCode: this.clientCode,
        registeredBy: this.registeredBy,
        regId: this.regId,
        vitalsHistory: this.vitalsHistory,
        biometrics: this.biometrics,
        allergies: this.allergies,
        isRegisteredOnline: this.isRegisteredOnline,
        disability: this.disability,
        targetGroup: this.targetGroup,
        careEntryPoint: this.careEntryPoint,
        priorArt: this.priorArt,
        referredFrom: this.referredFrom,
        uuid: this.uuid,
        userId: this.userId,
        religion: this.religion,
        language: this.language,
        qualification: this.qualification,
        nationality: this.nationality,
        email: this.email,
        patientId: this.patientId,
        hospitalNum: this.hospitalNum,
        facilityPath: this.facilityPath,
        facilityName: this.facilityName,
        nextOfKins: this.nextOfKins,
        facilityId: this.facilityId);
  }

  factory Client.fromDBJson(Map<String, dynamic> json) {
    List<Vitals> vitalsHistoryTemp = [];
    if (json['vitals_history'] != null) {
      json['vitals_history'].forEach((e) {
        vitalsHistoryTemp.add(Vitals.fromJson(e));
      });
    }
    vitalsHistoryTemp.sort((a, b) {
      return b.dateOfVital.compareTo(a.dateOfVital);
    });

    List<Allergy> allergiesTemp = [];
    if (json['allergies'] != null) {
      json['allergies'].forEach((e) {
        allergiesTemp.add(Allergy.fromJson(e));
      });
    }
    return Client(
        localDBIdentifier: json['db_identifier'],
        biometricsUploadFailed: json['biometrics_upload_failed'],
        surname: json['surname'],
        firstName: json['firstname'],
        otherNames: json['othername'],
        dob: DateTime.fromMillisecondsSinceEpoch(json['date_of_birth']),
        gender: KpMetaData.fromJsonOnly(json['gender']),
        occupation: KpMetaData.fromJsonOnly(json['occupation']),
        maritalStatus: KpMetaData.fromJsonOnly(json['marital_status']),
        phone: json['phone_number'],
        altPhone: json['alt_phone_number'],
        regDate:
            DateTime.fromMillisecondsSinceEpoch(json['date_of_registration']),
        clientCode: json['client_code'],
        registeredBy: json['registered_by'],
        numberOfChildren: json['no_children'],
        numberOfWives: json['no_wives'],
        residentialAddress: json['address'],
        // state: json['state'],
        lga: json['lga'] == null ? null : LocalGovernment.fromJson(json['lga']),
        regId: json['regId'],
        vitalsHistory: vitalsHistoryTemp,
        allergies: allergiesTemp,
        isRegisteredOnline: json['is_registered_online'] == null
            ? false
            : json['is_registered_online'],
        biometrics: json['biometrics'] == null
            ? null
            : Biometrics.fromJson(json['biometrics']),
        biometricsUploaded: json['biometrics_uploaded'],
        targetGroup: KpMetaData.fromJsonOnly(json['target_group']),
        careEntryPoint: KpMetaData.fromJsonOnly(json['care_entry_point']),
        priorArt: KpMetaData.fromJsonOnly(json['prior_art']),
        referredFrom: KpMetaData.fromJsonOnly(json['referred_from']),
        religion: KpMetaData.fromJsonOnly(json['religion']),
        language: KpMetaData.fromJsonOnly(json['language']),
        qualification: KpMetaData.fromJsonOnly(json['qualification']),
        nationality: KpMetaData.fromJsonOnly(json['nationality']),
        userId: json['user_id'],
        uuid: json['uuid'],
        hospitalNum: json['hospital_num'],
        email: json['email'],
        facilityId: json['facility_id'],
        disability: KpMetaData.fromJsonOnly(
          json['disability'],
        ));
  }

  factory Client.formServerJson(Map<String, dynamic> json) {
    return Client(
        surname: json['surname'] == null ? "" : json['surname'],
        firstName: json['firstname'] == null ? "" : json['firstname'],
        otherNames: json['otherNames'] == null ? "" : json['otherNames'],
        dob: json['dateBirth'] == null
            ? null
            : convertStringToDateTime(json['dateBirth']),
        gender: json['genders'] == null
            ? null
            : KpMetaData(
                id: json['genders']['gender_id'],
                name: json['genders']['name'],
                code: json['genders']['code'],
                description: json['genders']['description']),
        occupation: json['occupations'] == null
            ? null
            : KpMetaData(
                id: json['occupations']['occupation_id'],
                name: json['occupations']['name'],
                code: json['occupations']['code'],
                description: json['occupations']['description']),
        maritalStatus: json['maritalstatus'] == null
            ? null
            : KpMetaData(
                id: json['maritalstatus']['marital_status_id'],
                name: json['maritalstatus']['name'],
                code: json['maritalstatus']['code'],
                description: json['maritalstatus']['description']),
        phone: json['phone_number'] == null ? "" : json['phone_number'],
        altPhone:
            json['alt_phone_number'] == null ? "" : json['alt_phone_number'],
        regDate: json['dateRegistration'] == null
            ? null
            : convertStringToDateTime(json['dateRegistration']),
        clientCode:
            json['client_code'] == null ? "" : json['client_code'].toString(),
        registeredBy: json['registered_by'],
        // numberOfChildren: json['no_children'],
        // numberOfWives: json['no_wives'],
        residentialAddress: json['address'] == null ? "" : json['address'],
        // state: json['state'],
        // lga: json['lga'],
        // regId: json['regId'],
        // leftThumbId: json['left_thumb_id'],
        isRegisteredOnline: true,
        // rightThumbId: json['right_thumb_id'],
        targetGroup: json['targetgroups'] == null
            ? null
            : KpMetaData(
                id: json['targetgroups']['target_group_id'],
                name: json['targetgroups']['name'],
                code: json['targetgroups']['code'],
                description: json['targetgroups']['description']),
        careEntryPoint: json['careEntryPoint'] == null
            ? null
            : KpMetaData(
                id: json['careEntryPoint']['care_entry_point_id'],
                name: json['careEntryPoint']['name'],
                code: json['careEntryPoint']['code'],
                description: json['careEntryPoint']['description']),
        priorArt: json['priorart'] == null
            ? null
            : KpMetaData(
                id: json['priorart']['prior_art_id'],
                name: json['priorart']['name'],
                code: json['priorart']['code'],
                description: json['priorart']['description']),
        referredFrom: json['referredfrom'] == null
            ? null
            : KpMetaData(
                id: json['referredfrom']['referred_from_id'],
                name: json['referredfrom']['name'],
                code: json['referredfrom']['code'],
                description: json['referredfrom']['description']),
        religion: json['religions'] == null
            ? null
            : KpMetaData(
                id: json['religions']['religion_id'],
                name: json['religions']['name'],
                code: json['religions']['code'],
                description: json['religions']['description']),
        language: json['languages'] == null
            ? null
            : KpMetaData(
                id: json['languages']['language_id'],
                name: json['languages']['name'],
                code: json['languages']['code'],
                description: json['languages']['description']),
        qualification: json['qualifications'] == null
            ? null
            : KpMetaData(
                id: json['qualifications']['qualification_id'],
                name: json['qualifications']['name'],
                code: json['qualifications']['code'],
                description: json['qualifications']['description']),
        nationality: json['nationalities'] == null
            ? null
            : KpMetaData(
                id: json['nationalities']['nationality_id'],
                name: json['nationalities']['name'],
                code: json['nationalities']['code'],
                description: json['nationalities']['description']),
        patientId: json['patientId'],
        userId: json['userId'],
        uuid: json['idUuid'],
        hospitalNum: json['hospitalNum'] == null ? "" : json['hospitalNum'],
        email: json['email'],
        vitalsHistory: [],
        allergies: [],
        disability: json['disabilities'] == null
            ? null
            : KpMetaData(
                id: json['disabilities']['disability_id'],
                name: json['disabilities']['name'],
                code: json['disabilities']['code'],
                description: json['disabilities']['description']));
  }

  Map toJson(BuildContext context) {
    return <String, dynamic>{
      'hospitalNum': hospitalNum,
      'client_code': clientCode,
      'dateRegistration': regDate.millisecondsSinceEpoch,
      'dateBirth': dob.millisecondsSinceEpoch,
      'firstname': firstName,
      'surname': surname,
      // 'otherNames': otherNames,
      'marital_status_id': maritalStatus == null ? null : maritalStatus.id,
      'gender_id': gender == null ? null : gender.id,
      'email': email,
      'address': residentialAddress,
      'phone_number': phone,
      'occupation_id': occupation == null ? null : occupation.id,
      'qualification_id': qualification == null ? null : qualification.id,
      'facility_id': facilityId,
      'heirarchyunitid': facilityId,
      'language_id': language == null ? null : language.id,
      'target_group_id': targetGroup == null ? null : targetGroup.id,
      'nationality_id': nationality == null ? null : nationality.id,
      'care_entry_point_id': careEntryPoint == null ? null : careEntryPoint.id,
      'referred_from_id': referredFrom.id,
      'local_government_area_id': lga.id,
      'userId': registeredBy,
      // 'alt_phone_number': altPhone,
      'disability_id': disability == null ? null : disability.id,
      'prior_art_id': priorArt == null ? null : priorArt.id,
      'religion_id': religion == null ? null : religion.id,
    };
  }

  Map toJsonUpdate(BuildContext context) {
    Map<String, dynamic> json = toJson(context);
    json.keys.where((k) => json[k] == null).toList().forEach(json.remove);
    print(JsonEncoder().convert(json));
    json['userId'] = userId;
    json['idUuid'] = uuid;
    return json;
  }

  Map toDBJson(BuildContext context) {
    return <String, dynamic>{
      'db_identifier': localDBIdentifier,
      'facility_id': facilityId,
      'biometrics_upload_failed': biometricsUploadFailed,
      'surname': surname,
      'firstname': firstName,
      'othername': otherNames,
      'date_of_birth': dob.millisecondsSinceEpoch,
      'gender': gender.toJson(),
      'occupation': occupation.toJson(),
      'marital_status': maritalStatus.toJson(),
      'phone_number': phone,
      'alt_phone_number': altPhone,
      'date_of_registration': regDate.millisecondsSinceEpoch,
      'client_code': clientCode,
      'registered_by': registeredBy,
      'regId': regId,
      'no_children': numberOfChildren,
      'no_wives': numberOfWives,
      'address': residentialAddress,
      // 'state': state,
      'lga': lga.toJson(),
      'biometrics': biometrics == null ? null : biometrics.toJson(),
      'biometrics_uploaded': biometricsUploaded,
      'is_registered_online':
          isRegisteredOnline == null ? false : isRegisteredOnline,
      'target_group': targetGroup.toJson(),
      'disability': disability.toJson(),
      'care_entry_point': careEntryPoint.toJson(),
      'prior_art': priorArt.toJson(),
      'referred_from': referredFrom.toJson(),
      'uuid': uuid,
      'user_id': userId,
      'hospital_num': hospitalNum,
      'religion': religion.toJson(),
      'language': language.toJson(),
      'qualification': qualification.toJson(),
      'nationality': nationality.toJson(),
      'email': email
    };
  }
}
