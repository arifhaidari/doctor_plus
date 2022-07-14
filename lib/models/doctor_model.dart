import 'models.dart';

class DoctorModel {
  UserModel? user;
  TitleModel? title;
  List<SpecialityModel>? specialityList;
  List<ServiceModel>? serviceList;
  List<ConditionModel>? conditionList;
  List<ClinicModel>? clinicList;
  List<EducationModel>? educationList;
  List<ExperienceModel>? experienceList;
  List<AwardModel>? awardList;
  String? licenseNo;
  int? fee;
  String? bio;
  String? bioFarsi;
  String? bioPashto;
  bool? isFreeService;
  FreeServiceScheduleModel? freeServiceSchedule;
  bool? proStatus;
  double? averageStar;
  int? reviewNo;

  DoctorModel({
    this.user,
    this.title,
    this.specialityList,
    this.serviceList,
    this.conditionList,
    this.clinicList,
    this.educationList,
    this.experienceList,
    this.awardList,
    this.licenseNo,
    this.fee,
    this.bio,
    this.bioFarsi,
    this.bioPashto,
    this.isFreeService,
    this.freeServiceSchedule,
    this.proStatus,
    this.averageStar,
    this.reviewNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title != null ? title!.toJson() : null,
      'speciality_list':
          specialityList != null ? specialityList!.map((e) => e.toJson()).toList() : null,
      'service_list': serviceList != null ? serviceList!.map((e) => e.toJson()).toList() : null,
      'condition_list':
          conditionList != null ? conditionList!.map((e) => e.toJson()).toList() : null,
      'clinic_list': clinicList != null ? clinicList!.map((e) => e.toJson()).toList() : null,
      'education_list':
          educationList != null ? educationList!.map((e) => e.toJson()).toList() : null,
      'experience_list':
          experienceList != null ? experienceList!.map((e) => e.toJson()).toList() : null,
      'award_list': awardList != null ? awardList!.map((e) => e.toJson()).toList() : null,
      'doc_license_no': licenseNo,
      'fee': fee,
      'bio': bio,
      'farsi_bio': bioFarsi,
      'pashto_bio': bioFarsi,
      'is_free_service': isFreeService,
      'free_service_schedule': freeServiceSchedule != null ? freeServiceSchedule!.toJson() : null,
      'professional_status': proStatus,
      'average_star': averageStar,
      'review_no': reviewNo,
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    DoctorModel doctorModelObject = DoctorModel(
      title: json['title'] != null ? TitleModel.fromJson(json['title']) : null,
      licenseNo: json['doc_license_no'],
      fee: json['fee'],
      bio: json['bio'],
      bioFarsi: json['farsi_bio'],
      bioPashto: json['pashto_bio'],
      isFreeService: json['is_free_service'],
      freeServiceSchedule: json['free_service_schedule'] != null
          ? FreeServiceScheduleModel.fromJson(json['free_service_schedule'])
          : null,
      proStatus: json['professional_status'],
      averageStar: json['average_star'],
      reviewNo: json['review_no'],
    );

    if (json['user'] != null) {
      final userObject = UserModel.fromJson(json['user']);
      doctorModelObject.user = userObject;
    }

    if (json['speciality_list'] != null) {
      List<SpecialityModel> specialities = <SpecialityModel>[];
      json['speciality_list'].forEach((val) {
        specialities.add(SpecialityModel.fromJson(val));
      });
      doctorModelObject.specialityList = specialities;
    }

    if (json['service_list'] != null) {
      List<ServiceModel> services = <ServiceModel>[];
      json['service_list'].forEach((val) {
        services.add(ServiceModel.fromJson(val));
      });
      doctorModelObject.serviceList = services;
    }

    if (json['condition_list'] != null) {
      List<ConditionModel> conditions = <ConditionModel>[];
      json['condition_list'].forEach((val) {
        conditions.add(ConditionModel.fromJson(val));
      });
      doctorModelObject.conditionList = conditions;
    }

    if (json['clinic_list'] != null) {
      List<ClinicModel> clinics = <ClinicModel>[];
      json['clinic_list'].forEach((val) {
        clinics.add(ClinicModel.fromJson(val));
      });
      doctorModelObject.clinicList = clinics;
    }

    if (json['education_list'] != null) {
      List<EducationModel> educations = <EducationModel>[];
      json['education_list'].forEach((val) {
        educations.add(EducationModel.fromJson(val));
      });
      doctorModelObject.educationList = educations;
    }

    if (json['experience_list'] != null) {
      List<ExperienceModel> experiences = <ExperienceModel>[];
      json['experience_list'].forEach((val) {
        experiences.add(ExperienceModel.fromJson(val));
      });
      doctorModelObject.experienceList = experiences;
    }

    if (json['award_list'] != null) {
      List<AwardModel> awards = <AwardModel>[];
      json['award_list'].forEach((val) {
        awards.add(AwardModel.fromJson(val));
      });
      doctorModelObject.awardList = awards;
    }

    return doctorModelObject;
  }
}
