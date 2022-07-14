import 'package:intl/intl.dart';

class EducationModel {
  int? id;
  String? schoolName;
  String? rtlSchoolName;
  EducationDegreeModel? degree;
  String? startDate;
  String? endDate;

  EducationModel(
      {this.id, this.schoolName, this.rtlSchoolName, this.degree, this.startDate, this.endDate});

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'rtl_school_name': rtlSchoolName,
      'degree': degree != null ? degree!.toJson() : null,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'],
      schoolName: json['school_name'],
      rtlSchoolName: json['rtl_school_name'],
      degree: json['degree'] != null ? EducationDegreeModel.fromJson(json['degree']) : null,
      startDate: json['start_date'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['start_date'])).toString()
          : '',
      endDate: json['end_date'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['end_date'])).toString()
          : '',
    );
  }
}

class DegreeTypeModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;

  DegreeTypeModel({this.id, this.name, this.farsiName, this.pashtoName});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
    };
  }

  factory DegreeTypeModel.fromJson(Map<String, dynamic> json) {
    return DegreeTypeModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
    );
  }
}

// Education Degree Model
// bachelor, master, diploma, non clinical
class EducationDegreeModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;
  DegreeTypeModel? degreeType;

  EducationDegreeModel({this.id, this.name, this.farsiName, this.pashtoName, this.degreeType});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
      'degree_type': degreeType != null ? degreeType!.toJson() : null,
    };
  }

  factory EducationDegreeModel.fromJson(Map<String, dynamic> json) {
    return EducationDegreeModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
      degreeType:
          json['degree_type'] != null ? DegreeTypeModel.fromJson(json['degree_type']) : null,
    );
  }
}
