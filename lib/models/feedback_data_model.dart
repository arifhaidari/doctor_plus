import 'dart:core';

class FeedbackDataModel {
  int? feedbackNo;
  double? averageStar;
  double? overallExperience;
  double? doctorCheckup;
  double? staffBehavior;
  double? clinicEnvironment;
  int? patientNo;
  int? completedApptNo;
  int? experienceYear;
  List<int>? favoiteDoctorList;

  FeedbackDataModel({
    this.feedbackNo,
    this.averageStar,
    this.overallExperience,
    this.doctorCheckup,
    this.staffBehavior,
    this.clinicEnvironment,
    this.patientNo,
    this.completedApptNo,
    this.experienceYear,
    this.favoiteDoctorList,
  });

  factory FeedbackDataModel.fromJson(Map<String, dynamic> json) {
    return FeedbackDataModel(
      feedbackNo: json['feedback_no'],
      averageStar: double.tryParse(json['average_star']),
      overallExperience: double.tryParse(json['overall_experience']),
      doctorCheckup: double.tryParse(json['doctor_checkup']),
      staffBehavior: double.tryParse(json['staff_behavior']),
      clinicEnvironment: double.tryParse(json['clinic_environment']),
      patientNo: json['patient_no'],
      completedApptNo: json['completed_appt_no'],
      experienceYear: json['experience_year'],
      favoiteDoctorList: _listConverter(json['favorite_doctor_list']),
      // how to convert a dynamic list to integer list
      // how to know the type of a variable in flutter
    );
  }
}

List<int> _listConverter(List<dynamic> dynamicList) {
  List<int> intList = <int>[];
  for (var element in dynamicList) {
    intList.add(element);
  }
  return intList;
}
