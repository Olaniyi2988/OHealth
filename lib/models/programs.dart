import 'dart:convert';

class Program {
  int programId;
  String name;
  String code;
  String description;
  List<ProgramStage> programStages;
  int enrolled;

  Program(
      {this.code,
      this.description,
      this.name,
      this.programId,
      this.programStages,
      this.enrolled = 0});

  factory Program.fromJson(Map<String, dynamic> json) {
    List<ProgramStage> stages = [];
    if (json['programstages'] != null) {
      json['programstages'].forEach((stage) {
        stages.add(ProgramStage.fromJson(stage));
      });
    }
    return Program(
        code: json['code'],
        programId: json['program_id'],
        name: json['name'],
        description: json['description'],
        programStages: stages);
  }

  @override
  String toString() {
    return code;
  }
}

class ProgramStage {
  int programStateId;
  int programId;
  String name;
  String code;
  String description;
  String dbIdentifier;
  Map<String, dynamic> formJson;

  ProgramStage(
      {this.code,
      this.description,
      this.formJson,
      this.name,
      this.programId,
      this.programStateId,
      this.dbIdentifier});

  factory ProgramStage.fromJson(Map<String, dynamic> json) {
    return ProgramStage(
        programId: json['program_id'],
        programStateId: json['program_stage_id'],
        name: json['name'],
        code: json['code'],
        description: json['description'],
        formJson: json['programstageform'] == null
            ? {}
            : JsonDecoder().convert(json['programstageform']['json']),
        dbIdentifier: json['form_stage_db_identifier']);
  }

  @override
  String toString() {
    return code;
  }
}

class ClinicalClientProgram {
  int id;
  String clientUniqueIdentifier;
  Program program;

  ClinicalClientProgram({this.program, this.clientUniqueIdentifier, this.id});

  factory ClinicalClientProgram.fromJson(Map<String, dynamic> json) {
    return ClinicalClientProgram(
        id: json['clinical_client_program_id'],
        clientUniqueIdentifier: json['client_unique_identifier'],
        program: Program.fromJson(json['programstages']['programs']));
  }
}
