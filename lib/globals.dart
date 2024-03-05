import 'package:flutter/cupertino.dart';

enum ENV { DEVELOPMENT, PRODUCTION }

ENV env = ENV.PRODUCTION;

String endPointBaseUrl = env == ENV.PRODUCTION
    ? 'https://dmelplus.heartlandalliance.org.ng:4040/api/v1'
    : "http://192.168.43.36:4040/api/v1";
BuildContext globalBuildContext;

Map<String, Map<String, dynamic>> genericMetaDataList = {
  'genders': {'id_name': 'gender_id', 'end_point': '/listgenders'},
  'religions': {'id_name': 'religion_id', 'end_point': '/listreligions'},
  'maritalstatus': {
    'id_name': 'marital_status_id',
    'end_point': '/listmaritalstatus'
  },
  'occupations': {'id_name': 'occupation_id', 'end_point': '/listoccupations'},
  'allergies': {'id_name': 'allergy_id', 'end_point': '/listallergies'},
  'allergens': {'id_name': 'allergen_id', 'end_point': '/listallergens'},
  'disabilities': {
    'id_name': 'disability_id',
    'end_point': '/listdisabilities'
  },
  'targetgroups': {
    'id_name': 'target_group_id',
    'end_point': '/listtargetgroups'
  },
  'careentrypoint': {
    'id_name': 'care_entry_point_id',
    'end_point': '/listcareentrypoint'
  },
  'priorart': {'id_name': 'prior_art_id', 'end_point': '/listpriorart'},
  'referredfrom': {
    'id_name': 'referred_from_id',
    'end_point': '/listreferredfrom'
  },
  'languages': {'id_name': 'language_id', 'end_point': '/listlanguages'},
  'qualifications': {
    'id_name': 'qualification_id',
    'end_point': '/listqualifications'
  },
  'drugs': {'id_name': 'itemId', 'end_point': '/listdrugs'},
  'drugfrequency': {
    'id_name': 'drug_frequency_id',
    'end_point': '/listdrugfrequency'
  },
  'drugunits': {'id_name': 'drug_unit_id', 'end_point': '/listdrugunits'},
  'nationalities': {
    'id_name': 'nationality_id',
    'end_point': '/listnationalities'
  },
  'severity': {'id_name': 'severity_id', 'end_point': '/listseverity'},
  'diagnosisconditions': {
    'id_name': 'diagnosis_condition_id',
    'end_point': '/listdiagnosisconditions'
  },
  'relationships': {
    'id_name': 'relationship_id',
    'end_point': '/listrelationships'
  },
  'programs': {'id_name': 'program_id', 'end_point': '/listprograms'},
  'hivtestmodes': {
    'id_name': 'hiv_test_mode_id',
    'end_point': '/listhivtestmodes'
  },
  'specimentypes': {
    'id_name': 'specimen_type_id',
    'end_point': '/listspecimentypes'
  },
  'specimencollectionmodes': {
    'id_name': 'specimen_collection_mode_id',
    'end_point': '/listspecimencollectionmodes'
  },
  'pregnancy': {'id_name': 'pregnancy_id', 'end_point': '/listpregnancy'},
  'healthstatus': {'id_name': 'status_id', 'end_point': '/listhealthstatus'},
  'functionalstatus': {
    'id_name': 'functional_status_id',
    'end_point': '/listfunctionalstatus'
  },
  'clinicalstages': {
    'id_name': 'clinical_stages_id',
    'end_point': '/listclinicalstages'
  },
  'opportunisticinfections': {
    'id_name': 'opportunistic_infections_id',
    'end_point': '/listopportunisticinfections'
  },
  'levelofadherence': {
    'id_name': 'level_of_adherence_id',
    'end_point': '/listlevelofadherence'
  },
};
