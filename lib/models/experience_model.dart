import 'package:intl/intl.dart';

class ExperienceModel {
  int? id;
  String? hospitalName;
  String? rtlHospitalName;
  String? designation;
  String? rtlDesignation;
  String? startDate;
  String? endDate;

  ExperienceModel({
    this.id,
    this.hospitalName,
    this.rtlHospitalName,
    this.designation,
    this.rtlDesignation,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospital_name': hospitalName,
      'rtl_hospital_name': rtlHospitalName,
      'designation': designation,
      'rtl_designation': rtlDesignation,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'],
      hospitalName: json['hospital_name'],
      rtlHospitalName: json['rtl_hospital_name'],
      designation: json['designation'],
      rtlDesignation: json['rtl_designation'],
      startDate: json['start_date'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['start_date'])).toString()
          : '',
      endDate: json['end_date'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['end_date'])).toString()
          : '',
    );
  }
}
