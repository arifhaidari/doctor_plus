import '../models/models.dart';
import 'package:intl/intl.dart';

// ChatMessage Model
class ChatModel {
  int? id;
  UserModel? userModel;
  String? message;
  String? timestamp;
  String? voice;
  List<ChatImageModel>? imageList;
  List<ChatAttachmentModel>? attachmentList;

  ChatModel(
      {this.id,
      this.userModel,
      this.message,
      this.timestamp,
      this.voice,
      this.imageList,
      this.attachmentList});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    ChatModel chatModelObject = ChatModel(
      id: json['id'],
      userModel: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
      timestamp: json['timestamp'] != null
          ? DateFormat.yMd().add_jm().format(DateTime.parse(json['timestamp'])).toString()
          : '',
      voice: json['voice'],
    );

    // image list
    if (json['image_list'] != null || json['image_list'] == []) {
      List<ChatImageModel> chatImageModelList = <ChatImageModel>[];
      json['image_list'].forEach((element) {
        chatImageModelList.add(ChatImageModel.fromJson(element));
      });
      chatModelObject.imageList = chatImageModelList;
    } else {
      chatModelObject.imageList = <ChatImageModel>[];
    }

    // attachment list
    if (json['attachment_list'] != null || json['attachment_list'] == []) {
      List<ChatAttachmentModel> chatAttachmentModelList = <ChatAttachmentModel>[];
      json['attachment_list'].forEach((element) {
        chatAttachmentModelList.add(ChatAttachmentModel.fromJson(element));
      });
      chatModelObject.attachmentList = chatAttachmentModelList;
    } else {
      chatModelObject.attachmentList = <ChatAttachmentModel>[];
    }
    return chatModelObject;
  }
}

// MultipleImage Model
class ChatImageModel {
  int? id;
  ChatModel? chatModel;
  String? image;

  ChatImageModel({this.id, this.chatModel, this.image});

  Map<String, dynamic> toJson() {
    return {
      'message': chatModel,
      'image': image,
    };
  }

  factory ChatImageModel.fromJson(Map<String, dynamic> json) {
    return ChatImageModel(
      id: json['id'],
      chatModel: json['message'] != null ? ChatModel.fromJson(json['message']) : null,
      image: json['image'],
    );
  }
}

// MultipleImage Model
class ChatAttachmentModel {
  int? id;
  ChatModel? chatModel;
  String? attachment;

  ChatAttachmentModel({this.id, this.chatModel, this.attachment});

  Map<String, dynamic> toJson() {
    return {
      'message': chatModel,
      'attachment': attachment,
    };
  }

  factory ChatAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ChatAttachmentModel(
      id: json['id'],
      chatModel: json['message'] != null ? ChatModel.fromJson(json['message']) : null,
      attachment: json['attachment'],
    );
  }
}

// District Model
class WebsocketResponse {
  String? message;
  String? userPhone;
  String? type;
  String? mediaType;
  String? voice;
  List<ChatImageModel>? images;
  List<ChatAttachmentModel>? attachments;

  WebsocketResponse(
      {this.message,
      this.userPhone,
      this.type = 'chat_message',
      this.mediaType,
      this.voice,
      this.images,
      this.attachments});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user_phone': userPhone,
      'type': type,
      'media_type': mediaType,
      'voice': voice,
      'images': images != null ? images!.map((e) => e.toJson()) : null,
      'attachments': attachments != null ? attachments!.map((e) => e.toJson()) : null,
    };
  }

  factory WebsocketResponse.fromJson(Map<String, dynamic> json) {
    WebsocketResponse websocketResponse = WebsocketResponse(
      message: json['message'],
      userPhone: json['user_phone'],
      mediaType: json['media_type'],
      voice: json['voice'],
    );
    if (json['images'] != null) {
      List<ChatImageModel> chatModelList = <ChatImageModel>[];
      json['images'].forEach((element) {
        chatModelList.add(ChatImageModel.fromJson(element));
      });
      websocketResponse.images = chatModelList;
    } else {
      websocketResponse.images = <ChatImageModel>[];
    }
    // attachments
    if (json['attachments'] != null) {
      List<ChatAttachmentModel> chatModelList = <ChatAttachmentModel>[];
      json['attachments'].forEach((element) {
        chatModelList.add(ChatAttachmentModel.fromJson(element));
      });
      websocketResponse.attachments = chatModelList;
    } else {
      websocketResponse.attachments = <ChatAttachmentModel>[];
    }
    return websocketResponse;
  }
}
