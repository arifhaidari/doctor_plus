import 'package:intl/intl.dart';
import '../models/dummy_data.dart';

import 'models.dart';

class ApptModel {
  int? id;
  DoctorModel? doctor;
  PatientModel? patient;
  PatientModel? relative;
  ClinicModel? clinic;
  DaySchedulePatternModel? dayPattern;
  String? startApptTime;
  String? endApptTime;
  String? status;
  String? remark;
  bool isFeedbackGiven;
  double? feedback;
  String? review;
  // Map<String, dynamic>? status;
  bool? feedBackStatus;
  bool active;
  String? apptDate;
  String? bookedAt;
  List<ApptConditionTreatModel>? conditionTreated;

  ApptModel({
    this.id,
    this.doctor,
    this.patient,
    this.relative,
    this.clinic,
    this.dayPattern,
    this.startApptTime,
    this.endApptTime,
    this.status,
    this.remark,
    this.isFeedbackGiven = false,
    this.feedback,
    this.review,
    this.feedBackStatus,
    this.active = true,
    this.apptDate,
    this.bookedAt,
    this.conditionTreated,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor != null ? doctor!.toJson() : null,
      'patient': patient != null ? patient!.toJson() : null,
      'relative': relative != null ? relative!.toJson() : null,
      'clinic': clinic != null ? clinic!.toJson() : null,
      'day_pattern': dayPattern != null ? dayPattern!.toJson() : null,
      'start_appt_time': startApptTime,
      'end_appt_time': endApptTime,
      'status': status,
      'remark': remark,
      'is_feedback_given': isFeedbackGiven,
      'feedback': feedback,
      'review': review,
      'feedback_status': feedBackStatus,
      'active': active,
      'appt_date': apptDate,
      'booked_at': bookedAt,
      'condition_treated': conditionTreated != null
          ? conditionTreated!.map((conditionObject) {
              return conditionObject.toJson();
            }).toList()
          : <ApptConditionTreatModel>[],
    };
  }

  factory ApptModel.fromJson(Map<String, dynamic> json) {
    print('valeu fo odubele');
    print(json['feedback']);
    ApptModel theApptModel = ApptModel(
      id: json['id'],
      doctor: json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null,
      patient: json['patient'] != null ? PatientModel.fromJson(json['patient']) : null,
      relative: json['relative'] != null ? PatientModel.fromJson(json['relative']) : null,
      clinic: json['clinic'] != null ? ClinicModel.fromJson(json['clinic']) : null,
      dayPattern: json['day_pattern'] != null
          ? DaySchedulePatternModel.fromJson(json['day_pattern'])
          : null,
      startApptTime: json['start_appt_time'],
      endApptTime: json['end_appt_time'],
      status: GlobalDummyData.CAPITUALIZE[json['status']],
      remark: json['remark'],
      review: json['review'],
      isFeedbackGiven: json['is_feedback_given'] ?? false,
      feedback: json['feedback'] != null ? double.tryParse(json['feedback'].toString()) : 3.5,
      feedBackStatus: json['feedback_status'],
      active: json['active'] ?? false,
      apptDate: json['appt_date'],
      bookedAt: json['booked_at'],
    );
    if (json['condition_treated'] != null) {
      List<ApptConditionTreatModel> conditionTreatObj = <ApptConditionTreatModel>[];
      json['condition_treated'].forEach((val) {
        conditionTreatObj.add(ApptConditionTreatModel.fromJson(val));
      });
      theApptModel.conditionTreated = conditionTreatObj;
    }
    return theApptModel;
  }
}

// Appt Condition Model
class ApptConditionTreatModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;

  ApptConditionTreatModel({this.id, this.name, this.farsiName, this.pashtoName});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
    };
  }

  factory ApptConditionTreatModel.fromJson(Map<String, dynamic> json) {
    return ApptConditionTreatModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
    );
  }
}

// Day Schedule Pattern
class DaySchedulePatternModel {
  int? id;
  WeekDayModel? weekDay;
  String? startDayTime;
  String? endDayTime;
  ClinicModel? clinic;
  bool active;

  DaySchedulePatternModel(
      {this.id, this.weekDay, this.startDayTime, this.endDayTime, this.clinic, this.active = true});

  Map<String, dynamic> toJson() {
    return {
      'week_day': WeekDayModel().toJson(),
      'start_day_time': startDayTime,
      'end_day_time': endDayTime,
      'clinic': clinic != null ? clinic!.toJson() : null,
      'active': active,
    };
  }

  factory DaySchedulePatternModel.fromJson(Map<String, dynamic> json) {
    return DaySchedulePatternModel(
      id: json['id'],
      weekDay: json['week_day'] != null ? WeekDayModel.fromJson(json['week_day']) : null,
      startDayTime: json['start_day_time'],
      endDayTime: json['end_day_time'],
      clinic: json['clinic'] != null ? ClinicModel.fromJson(json['clinic']) : null,
      active: json['active'] == null ? true : false,
    );
  }
}

// Week Days Model
class WeekDayModel {
  int? id;
  String? weekDay;
  String? rtlWeekDay;

  WeekDayModel({this.id, this.weekDay, this.rtlWeekDay});

  Map<String, dynamic> toJson() {
    return {
      'week_day': weekDay,
      'rtl_week_day': rtlWeekDay,
    };
  }

  factory WeekDayModel.fromJson(Map<String, dynamic> json) {
    return WeekDayModel(
      id: json['id'],
      weekDay: json['week_day'],
      rtlWeekDay: json['rtl_week_day'],
    );
  }
}

class BookedApptModel {
  int? id;
  int? patientId;
  int? clinicId;
  String? patientName;
  String? rtlPatientName;
  String? phone;
  String? age;
  String? avatar;
  String? gender;
  String? clinicName;
  String? rtlClinicName;
  String? weekDay;
  String? rtlWeekDay;
  String? startApptTime;
  String? endApptTime;
  String? apptDate;
  String? bookedAt;

  BookedApptModel({
    this.id,
    this.patientId,
    this.clinicId,
    this.patientName,
    this.rtlPatientName,
    this.phone,
    this.age,
    this.avatar,
    this.gender,
    this.clinicName,
    this.rtlClinicName,
    this.weekDay,
    this.rtlWeekDay,
    this.startApptTime,
    this.endApptTime,
    this.apptDate,
    this.bookedAt,
  });

  factory BookedApptModel.fromJson(Map<String, dynamic> json) {
    return BookedApptModel(
      id: json['id'],
      patientId: json['patient_id'],
      clinicId: json['clinic_id'],
      patientName: json['patient_name'],
      rtlPatientName: json['rtl_patient_name'],
      phone: json['patient_phone'],
      age: json['patient_age'],
      avatar: json['avatar'],
      gender: json['gender'] ?? 'Male',
      clinicName: json['clinic_name'],
      rtlClinicName: json['rtl_clinic_name'],
      weekDay: json['week_day'],
      rtlWeekDay: json['rtl_week_day'],
      startApptTime: json['start_appt_time'],
      endApptTime: json['end_appt_time'],
      apptDate: json['appt_date'] != null
          ? DateFormat.d().format(DateTime.parse(json['appt_date'])).toString()
          : '',
      bookedAt: json['booked_at'] != null
          ? DateFormat.yMMMMd().format(DateTime.parse(json['booked_at'])).toString()
          : '',
    );
  }
}
