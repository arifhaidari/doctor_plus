import 'models.dart';

class PatientModel {
  UserModel? user;
  String? bloodGroup;
  int? totalBookedAppt;
  int? familyMemberNo;
  int? medicalRecordNo;
  String? lastCompletedAppt;
  bool? shareRecordToAll;
  RelativeRelationModel? relativeRelation;

  PatientModel({
    this.user,
    this.bloodGroup,
    this.totalBookedAppt,
    this.familyMemberNo,
    this.medicalRecordNo,
    this.lastCompletedAppt,
    this.shareRecordToAll,
    this.relativeRelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user != null ? user!.toJson() : null,
      'blood_group': bloodGroup,
      'total_booked_appt': totalBookedAppt,
      'family_member_no': familyMemberNo,
      'medical_record_no': medicalRecordNo,
      'last_completed_appt': lastCompletedAppt,
      'share_record_to_all': shareRecordToAll,
      'relation': relativeRelation != null ? relativeRelation!.toJson() : null,
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      bloodGroup: json['blood_group'],
      totalBookedAppt: json['total_booked_appt'],
      familyMemberNo: json['family_member_no'],
      medicalRecordNo: json['medical_record_no'],
      lastCompletedAppt: json['last_completed_appt'],
      shareRecordToAll: json['share_record_to_all'],
      relativeRelation:
          json['relation'] != null ? RelativeRelationModel.fromJson(json['relation']) : null,
    );
  }
}

class RelativeRelationModel {
  int? id;
  String? relation;
  String? farsiRelation;
  String? pashtoRelation;

  RelativeRelationModel({
    this.id,
    this.relation,
    this.farsiRelation,
    this.pashtoRelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'relation': relation,
      'farsi_relation': farsiRelation,
      'pashto_relation': pashtoRelation,
    };
  }

  factory RelativeRelationModel.fromJson(Map<String, dynamic> json) {
    return RelativeRelationModel(
      id: json['id'],
      relation: json['relation'],
      farsiRelation: json['farsi_relation'],
      pashtoRelation: json['pashto_relation'],
    );
  }
}
