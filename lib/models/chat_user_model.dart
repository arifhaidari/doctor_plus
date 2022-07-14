class ChatUserModel {
  String? phone;
  String? name;
  String? rtlName;
  String? avatar;
  LastChatText? lastText;

  ChatUserModel({this.phone, this.name, this.rtlName, this.avatar, this.lastText});

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      phone: json['phone'],
      name: json['full_name'],
      rtlName: json['rtl_full_name'],
      avatar: json['avatar'],
      lastText: json['last_text'] != null ? LastChatText.fromJson(json['last_text']) : null,
    );
  }
}

class LastChatText {
  bool? sendByMe;
  String? messageType;
  String? messageText;
  String? timestamp;
  bool? seen;

  LastChatText({this.sendByMe, this.messageType, this.messageText, this.timestamp, this.seen});

  factory LastChatText.fromJson(Map<String, dynamic> json) {
    return LastChatText(
      sendByMe: json['sent_by_me'],
      messageType: json['message_type'],
      messageText: json['message_text'],
      timestamp: json['timestamp'],
      seen: json['seen'],
    );
  }
}
