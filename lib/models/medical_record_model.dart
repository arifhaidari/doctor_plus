import '../models/models.dart';
import 'package:intl/intl.dart';

class MedicalRecordModel {
  int? id;
  String? title;
  PatientModel? patient;
  DoctorModel? relatedDoctor;
  List<UserModel>? sharedWith;
  List<UserModel>? myDoctors;
  List<MedicalRecordFileModel>? recordFiles;
  bool? generalAccess;
  int? recordFileNo;
  String? updatedAt;
  String? timeStamp;

  MedicalRecordModel({
    this.id,
    this.title,
    this.patient,
    this.relatedDoctor,
    this.myDoctors,
    this.sharedWith,
    this.recordFiles,
    this.generalAccess,
    this.recordFileNo,
    this.updatedAt,
    this.timeStamp,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    MedicalRecordModel medicalRecordModelObject = MedicalRecordModel(
      id: json['id'],
      title: json['title'],
      patient: json['patient'] != null ? PatientModel.fromJson(json['patient']) : null,
      relatedDoctor:
          json['related_doctor'] != null ? DoctorModel.fromJson(json['related_doctor']) : null,
      generalAccess: json['general_access'],
      recordFileNo: json['record_file_no'],
      updatedAt: json['updated_at'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['updated_at'])).toString()
          : '',
      timeStamp: json['timestamp'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['timestamp'])).toString()
          : '',
    );

    if (json['shared_with'] != null) {
      List<UserModel> sharedDoctorList = <UserModel>[];

      if (json['shared_with'].length > 0) {
        // print('value rof main value');
        // print(json['shared_with'].length);
        json['shared_with'].forEach((element) {
          // print('value of element in model');
          // print(element);
          sharedDoctorList.add(UserModel.fromJson(element));
        });
      }
      // print('valuer of sharedDoctorList.length');
      // print(sharedDoctorList.length);
      medicalRecordModelObject.sharedWith = sharedDoctorList;
    }

    if (json['my_doctors'] != null) {
      List<UserModel> doctorList = <UserModel>[];
      if (['my_doctors'].isNotEmpty) {
        json['my_doctors'].forEach((element) {
          doctorList.add(UserModel.fromJson(element));
        });
      }

      medicalRecordModelObject.myDoctors = doctorList;
    }

    if (json['files'] != null) {
      List<MedicalRecordFileModel> theList = <MedicalRecordFileModel>[];
      if (json['files'].length > 0) {
        json['files'].forEach((element) {
          theList.add(MedicalRecordFileModel.fromJson(element));
        });
      }
      medicalRecordModelObject.recordFiles = theList;
    }

    return medicalRecordModelObject;
  }
}

class MedicalRecordFileModel {
  int? id;
  String? file;

  MedicalRecordFileModel({this.id, this.file});

  factory MedicalRecordFileModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordFileModel(
      id: json['id'],
      file: json['file'],
    );
  }
}
