//Award Model

import 'package:intl/intl.dart';

class AwardModel {
  int? id;
  String? awardName;
  String? rtlAwardName;
  String? awardYear;

  AwardModel({this.id, this.awardName, this.rtlAwardName, this.awardYear});

  Map<String, dynamic> toJson() {
    return {
      'award_name': awardName,
      'rtl_award_name': rtlAwardName,
      'award_year': awardYear,
    };
  }

  factory AwardModel.fromJson(Map<String, dynamic> json) {
    return AwardModel(
      id: json['id'],
      awardName: json['award_name'],
      rtlAwardName: json['rtl_award_name'],
      awardYear: json['award_year'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['award_year'])).toString()
          : '',
    );
  }
}

class TitleModel {
  int? id;
  String title;
  String? farsiTitle;
  String? pashtoTitle;

  TitleModel({this.id, required this.title, this.farsiTitle, this.pashtoTitle});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'farsi_title': farsiTitle,
      'pashto_title': pashtoTitle,
    };
  }

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(
        id: json['id'],
        title: json['title'],
        farsiTitle: json['farsi_title'],
        pashtoTitle: json['pashto_title']);
  }
}

// Free Service Model
class FreeServiceScheduleModel {
  String? startAt;
  String? endAt;

  FreeServiceScheduleModel({required this.startAt, required this.endAt});

  Map<String, dynamic> toJson() {
    return {
      'start_at': startAt,
      'end_at': endAt,
    };
  }

  factory FreeServiceScheduleModel.fromJson(Map<String, dynamic> json) {
    return FreeServiceScheduleModel(
      // startAt: json['start_at'] != null ? DateTime.parse(json['start_at']) : null,
      startAt: json['start_at'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['start_at'])).toString()
          : '',
      endAt: json['end_at'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['end_at'])).toString()
          : '',
    );
  }
}
