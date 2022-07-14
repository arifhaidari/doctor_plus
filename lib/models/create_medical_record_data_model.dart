import 'models.dart';

class CreateMedicalRecordDataModel {
  List<PatientModel>? myRelatives;
  List<UserModel>? myDoctors;

  CreateMedicalRecordDataModel({this.myDoctors, this.myRelatives});

  factory CreateMedicalRecordDataModel.fromJson(Map<String, dynamic> json) {
    CreateMedicalRecordDataModel createMedicalRecordDataModel = CreateMedicalRecordDataModel();
    if (json['my_relatives'] != null) {
      List<PatientModel> _userModelList = <PatientModel>[];
      json['my_relatives'].forEach((element) {
        _userModelList.add(PatientModel.fromJson(element));
      });
      createMedicalRecordDataModel.myRelatives = _userModelList;
    }

    if (json['my_doctors'] != null) {
      List<UserModel> _userModelList = <UserModel>[];
      json['my_doctors'].forEach((element) {
        _userModelList.add(UserModel.fromJson(element));
      });
      createMedicalRecordDataModel.myDoctors = _userModelList;
    }
    return createMedicalRecordDataModel;
  }
}
