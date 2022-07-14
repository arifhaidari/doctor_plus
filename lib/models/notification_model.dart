import '../models/models.dart';

class NotificationModel {
  int? id;
  String? title;
  String? body;
  UserModel? receiver;
  ApptModel? appt;
  String? category;
  bool? seen;
  String? timestamp;

  NotificationModel(
      {this.id,
      this.title,
      this.body,
      this.receiver,
      this.appt,
      this.category,
      this.seen,
      this.timestamp});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      receiver: json['receiver'],
      appt: json['appt'] == null ? null : ApptModel.fromJson(json['appt']),
      category: json['category'],
      seen: json['seen'],
      timestamp: json['timestamp'],
    );
  }
}
