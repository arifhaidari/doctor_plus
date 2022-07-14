import '../models/models.dart';

class FeedbackModel {
  int? id;
  ApptModel? apptModel;
  String? comment;
  double? scoreCount;
  DateTime? timestamp;
  String? overAllExperience;
  String? doctorCheckup;
  String? staffBehavior;
  String? clinicEnvironment;
  List<FeedbackReplyModel>? replyList;

  FeedbackModel({
    this.id,
    this.apptModel,
    this.comment,
    this.scoreCount,
    this.timestamp,
    this.overAllExperience,
    this.doctorCheckup,
    this.staffBehavior,
    this.clinicEnvironment,
    this.replyList,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    FeedbackModel feedbackModelObject = FeedbackModel(
      id: json['id'],
      apptModel: json['appointment'] != null ? ApptModel.fromJson(json['appointment']) : null,
      comment: json['comment'],
      scoreCount:
          json['score_count'] != null ? double.tryParse(json['score_count'].toString()) : 2.5,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      overAllExperience: json['overall_experience'],
      doctorCheckup: json['doctor_checkup'],
      staffBehavior: json['staff_behavior'],
      clinicEnvironment: json['clinic_environment'],
      replyList: <FeedbackReplyModel>[],
    );
    if (json['replies'] != null) {
      List<FeedbackReplyModel> feedbackRepliesList = <FeedbackReplyModel>[];
      json['replies'].forEach((element) {
        final FeedbackReplyModel object = FeedbackReplyModel.fromJson(element);
        feedbackRepliesList.add(object);
      });
      feedbackModelObject.replyList = feedbackRepliesList;
    }
    return feedbackModelObject;
  }
}

class FeedbackReplyModel {
  int? id;
  UserModel? author;
  String? reply;
  bool? isMe;
  DateTime? timestamp;

  FeedbackReplyModel({this.id, this.author, this.reply, this.isMe, this.timestamp});

  factory FeedbackReplyModel.fromJson(Map<String, dynamic> json) {
    return FeedbackReplyModel(
      id: json['id'],
      author: json['author'] != null ? UserModel.fromJson(json['author']) : null,
      reply: json['reply'],
      isMe: json['is_me'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }
}
