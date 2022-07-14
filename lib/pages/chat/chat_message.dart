import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../../providers/provider_list.dart';
import '../../widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import '../../utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';

import '../screens.dart';

class ChatMessage extends StatefulWidget {
  final String theToken;
  final ChatUserModel chatUserModel;
  // ignore: prefer_const_constructors_in_immutables
  ChatMessage({Key? key, required this.theToken, required this.chatUserModel}) : super(key: key);
  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  List<ChatModel> messageList = <ChatModel>[];
  late WebSocketChannel channel;
  FlutterSoundRecorder? _audioRecorder;
  String myPhoneNumber = DRAWER_DATA['phone'];

  final _scrollController = ScrollController();
  // docker run -p 6379:6379 -d redis:5    // it starts the docker
  @override
  void initState() {
    super.initState();
    _getChatData();
    channel = IOWebSocketChannel.connect(
        Uri.parse(CHAT_SOCKET_LINK + '${widget.chatUserModel.phone}/?token=' + widget.theToken));

    channel.stream.listen((event) {
      if (event != null) {
        Map<String, dynamic> theData = json.decode(event);
        if (theData['message'] != '' || theData['message'] != null) {
          bool isNotText = (theData['media_type'] == 'image' ||
              theData['media_type'] == 'attachement' ||
              theData['media_type'] == 'voice');

          // images
          List<ChatImageModel> chatImageList = <ChatImageModel>[];
          if (theData['media_type'] == 'image') {
            if (theData['images'] != null) {
              theData['images'].forEach((val) {
                chatImageList.add(ChatImageModel(image: MEDIA_LINK_NO_SLASH + val));
              });
            }
          }

          // files
          List<ChatAttachmentModel> chatFileList = <ChatAttachmentModel>[];
          if (theData['media_type'] == 'attachement') {
            if (theData['attachments'] != null) {
              theData['attachments'].forEach((val) {
                chatFileList.add(ChatAttachmentModel(attachment: MEDIA_LINK_NO_SLASH + val));
              });
            }
          }

          setState(() {
            // _itemCount += 1;
            messageList.insert(
              0,
              ChatModel(
                  message: isNotText ? "" : theData['message'],
                  // timestamp: ,
                  userModel:
                      UserModel(phone: theData['user_phone'], avatar: widget.chatUserModel.avatar),
                  imageList: (theData['media_type'] == 'image' && chatImageList.isNotEmpty)
                      ? chatImageList
                      : <ChatImageModel>[],
                  attachmentList:
                      (theData['media_type'] == 'attachement' && chatFileList.isNotEmpty)
                          ? chatFileList
                          : <ChatAttachmentModel>[],
                  voice: (theData['media_type'] == 'voice' && theData['voice'] != null)
                      ? (MEDIA_LINK_NO_SLASH + theData['voice'])
                      : null),
            );
          });
        }
      }
    });

    // pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= messageList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getChatData(nextPage: true);
      }
    });
  }

  bool _isUnknownError = false;
  bool _isConnectionError = false;

  int _itemCount = 0;
  String _nextPage = '';
  String _errorMessage = '';

  void _getChatData({bool nextPage = false}) async {
    List<ChatModel> _tempMessageList = <ChatModel>[];

    var _chatResponseList = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '')
            ? _nextPage
            : CHAT_GET_POST + '${widget.chatUserModel.phone}/');

    if (!_chatResponseList.error) {
      try {
        setState(() {
          if (_chatResponseList.data['results'] is List &&
              _chatResponseList.data['results'].length != 0) {
            _itemCount = _chatResponseList.data['count'];
            _nextPage = _chatResponseList.data['next'] ?? '';
            // Chat
            _chatResponseList.data['results'].forEach((response) {
              final theObject = ChatModel.fromJson(response);
              _tempMessageList.add(theObject);
            });

            if (!nextPage) {
              messageList.clear();
              messageList.addAll(_tempMessageList);
            } else {
              messageList.addAll(_tempMessageList);
            }
          }
        });
      } catch (e) {
        setState(() {
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        if (_chatResponseList.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _chatResponseList.errorMessage!;
        }
      });
    }
  }

  // close the websocket in dispose()
  @override
  void dispose() {
    super.dispose();
    channel.sink.close();
    _scrollController.dispose();
    if (_audioRecorder != null) {
      _audioRecorder!.closeAudioSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final mQuery = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        _returnBackProvider();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: _appBarTitle(),
          elevation: 0.0,
          backgroundColor: Palette.blueAppBar,
        ),
        // extendBodyBehindAppBar: true,
        backgroundColor: Palette.blueAppBar,
        body: SafeArea(child: Builder(
          builder: (BuildContext ctx) {
            if (_isUnknownError || _isConnectionError) {
              if (_isConnectionError) {
                return const ErrorPlaceHolder(
                    isStartPage: true,
                    errorTitle: GlobalVariable.INTERNET_ISSUE_TITLE,
                    errorDetail: GlobalVariable.INTERNET_ISSUE_CONTENT);
              } else {
                return ErrorPlaceHolder(
                  isStartPage: true,
                  errorTitle: 'Unknown Error. Try again later',
                  errorDetail: _errorMessage,
                );
              }
            }
            return Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Palette.scaffoldBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: messageList.isEmpty
                          ? const PlaceHolder(
                              title: 'No Message', body: 'Send A Message To Get Started')
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              reverse: true,
                              itemCount: messageList.length + 1,
                              itemBuilder: (context, index) {
                                if (index < messageList.length) {
                                  return MessageWidget(
                                    chatModel: messageList[index],
                                    isMe: widget.chatUserModel.phone !=
                                        messageList[index].userModel!.phone,
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                                    child: Center(
                                      child: _itemCount <= messageList.length
                                          ? null
                                          : const CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              },
                            )),
                ),
                NewMessageWidget(
                  channel: channel,
                  audioRecorder: _audioRecorder,
                  myPhoneNumber: myPhoneNumber,
                  otherUserPhone: widget.chatUserModel.phone ?? 'no_phone',
                )
              ],
            );
          },
        )),
      ),
    );
  }

  void _returnBackProvider() {
    Map<String, dynamic> _theMap = {'is_chat_empty': true};
    if (messageList.isNotEmpty) {
      _theMap = {
        'is_chat_empty': false,
        'is_sender_me': messageList[0].userModel!.phone != widget.chatUserModel.phone,
        'message_type': messageList[0].message == '' ? 'file_attachment' : 'text',
        'message_text': messageList[0].message,
        'timestamp': messageList[0].userModel!.phone != widget.chatUserModel.phone
            ? DateTime.now().toString()
            : widget.chatUserModel.lastText!.timestamp
      };
    }
    Navigator.of(context).pop(_theMap);
  }

  Widget _appBarTitle() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _returnBackProvider()),
        ProfileAvatarCircle(
          imageUrl: widget.chatUserModel.avatar,
          radius: 45,
          borderWidth: 1.5,
          isActive: false,
          circleColor: Colors.white,
        ),
        const SizedBox(
          width: 5.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              widget.chatUserModel.name == null
                  ? 'Unknown Patient'
                  : (widget.chatUserModel.name!.length >= 32
                      ? widget.chatUserModel.name!.substring(0, 32)
                      : widget.chatUserModel.name!),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              minFontSize: 14,
              maxLines: 1,
            ),
            Text(
              'Active ${widget.chatUserModel.lastText!.timestamp! == "" ? "A While Ago" : timeAgoConverter(DateTime.parse(widget.chatUserModel.lastText!.timestamp!))}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}

class MessageWidget extends StatelessWidget {
  final ChatModel chatModel;
  final bool isMe;

  // ignore: use_key_in_widget_constructors
  const MessageWidget({
    required this.chatModel,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(15);
    const borderRadius = BorderRadius.all(radius);
    final theMessage = chatModel.message;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          ProfileAvatarCircle(
            imageUrl: chatModel.userModel!.avatar,
            radius: 38,
            borderWidth: 0.8,
            isActive: false,
          ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 220),
          decoration: BoxDecoration(
            color: isMe ? Palette.blueAppBar : Palette.imageBackground,
            borderRadius: isMe
                ? borderRadius.subtract(const BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(const BorderRadius.only(bottomLeft: radius)),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              // attachments
              if (theMessage == '' &&
                  (chatModel.attachmentList!.isNotEmpty && chatModel.attachmentList != null))
                _showAttach(chatModel.attachmentList ?? <ChatAttachmentModel>[], context),
              // images
              if (theMessage == '' &&
                  (chatModel.imageList!.isNotEmpty && chatModel.imageList != null))
                _showImage(chatModel.imageList ?? <ChatImageModel>[], context),
              // voice
              if (theMessage == '' && chatModel.voice != null)
                VoiceMessagePlayer(
                  voiceUrl: chatModel.voice ?? '',
                  isLocal: false,
                ),
              // only text
              if ((theMessage != ''))
                Text(
                  theMessage ?? '',
                  style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 15),
                ),
              //  end of content
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    chatModel.timestamp ??
                        DateFormat.yMd().add_jm().format(DateTime.now()).toString(),
                    style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(
                    width: 3.0,
                  ),
                  Icon(
                    Icons.done_all,
                    color: isMe ? Colors.white70 : Colors.black54,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Center _showAttach(List<ChatAttachmentModel> theFiles, BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 5.0,
        // shrinkWrap: true,
        // scrollDirection: Axis.horizontal,
        children: theFiles.isEmpty
            ? [const Text('Not Available')]
            : theFiles
                .map(
                  (e) => GestureDetector(
                    onTap: () =>
                        isPdf(e.attachment ?? '') ? showPdf(e.attachment ?? '', context) : null,
                    child: SizedBox(
                      height: 60,
                      width: 65,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            color: Palette.imageBackground,
                            borderRadius: BorderRadius.circular(5)),
                        margin: const EdgeInsets.only(right: 5.0),
                        child: isPdf(e.attachment ?? '')
                            ? const Center(
                                child: Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 40,
                                ),
                              )
                            : const Text('File Error'),
                      ),
                    ),
                  ),
                )
                .toList(),
        // children: medicalNameOnlyList.map((e) => Text(e)).toList(),
      ),
    );
  }

  Center _showImage(List<ChatImageModel> theImages, BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 5.0,
        // shrinkWrap: true,
        // scrollDirection: Axis.horizontal,
        children: theImages.isEmpty
            ? [const Text('Images Not Available')]
            : theImages
                .map(
                  (e) => GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalPhotoGallery(chatImageList: theImages))),
                    child: SizedBox(
                      height: 90,
                      width: 90,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Palette.imageBackground, borderRadius: BorderRadius.circular(5)),
                        margin: const EdgeInsets.only(right: 5.0),
                        child: CachedNetworkImage(
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter:
                                      const ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
                            ),
                          ),
                          placeholder: (context, url) => circularLoading(),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 50,
                          ),
                          fit: BoxFit.cover,
                          imageUrl: e.image ?? '',
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
        // children: medicalNameOnlyList.map((e) => Text(e)).toList(),
      ),
    );
  }
}

class VoiceMessagePlayer extends StatefulWidget {
  final String voiceUrl;
  final bool isLocal;
  const VoiceMessagePlayer({
    Key? key,
    required this.voiceUrl,
    required this.isLocal,
  }) : super(key: key);

  @override
  _VoiceMessagePlayerState createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  // AudioPlayer audioPlayerObject = AudioPlayer();
  late AudioPlayer audioPlayerObject;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool isPlaying = false;
  bool isPaused = false;
  bool isRepeat = false;
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    audioPlayerObject = new AudioPlayer();
    audioPlayerObject.setUrl(widget.voiceUrl, isLocal: widget.isLocal);
    audioPlayerObject.onDurationChanged.listen((theDuration) {
      setState(() {
        _duration = theDuration;
      });
    });
    audioPlayerObject.onAudioPositionChanged.listen((thePosition) {
      setState(() {
        _position = thePosition;
      });
    });
    audioPlayerObject.onPlayerCompletion.listen((event) {
      setState(() {
        _position = const Duration(seconds: 0);
        if (isRepeat) {
          isPlaying = true;
        } else {
          isPlaying = false;
          isRepeat = false;
        }
      });
    });
  }

  void _playButton() {
    if (!isPlaying) {
      audioPlayerObject.play(widget.voiceUrl);
      setState(() {
        isPlaying = true;
      });
    } else {
      audioPlayerObject.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayerObject.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Padding(
        // padding: const EdgeInsets.all(5.0),
        // child:
        IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow_rounded),
            onPressed: () =>
                widget.voiceUrl != '' ? _playButton() : toastSnackBar('Audio No Available')),
        // ),
        // the problem is with slider and duration and position value
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_position.toString().split('.')[0].substring(2)),
            const Text('/'),
            Text(_duration.toString().split('.')[0].substring(2)),
          ],
        )

            // Slider(
            //   activeColor: Colors.red,
            //   inactiveColor: Colors.grey,
            //   value: _position.inSeconds.toDouble(),
            //   min: 0.0,
            //   // max: _duration.inSeconds.toDouble(),
            //   // max: (_position.inSeconds.toDouble()) > (_duration.inSeconds.toDouble())
            //   //     ? _duration.inSeconds.toDouble()
            //   //     : 1.0,
            //   max: _duration.inSeconds.toDouble(),
            //   onChanged: (double value) {
            //     setState(() {
            //       print('value of change');
            //       print(value);
            //       _changeToSecond(value.toInt());
            //       // value = value;
            //     });
            //   },
            // ),
            ),
      ],
    );
  }
}

class NewMessageWidget extends StatefulWidget {
  final WebSocketChannel channel;
  late final FlutterSoundRecorder? audioRecorder;
  final String otherUserPhone;
  final String myPhoneNumber;
  // ignore: prefer_const_constructors_in_immutables
  NewMessageWidget(
      {Key? key,
      required this.channel,
      this.audioRecorder,
      required this.otherUserPhone,
      required this.myPhoneNumber})
      : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';
  bool isAttachment = true;
  bool isVoice = false;
  final String _filePath = 'sound_file.wav';
  // bool _play = false;
  String _recordText = '00:00:00';
  StreamSubscription? _recorderSubscription;

  void _voiceRecorder() async {
    setState(() {
      isVoice = true;
    });
    widget.audioRecorder = FlutterSoundRecorder();
    await widget.audioRecorder!.openAudioSession();
    // listen to the stream to track time passed
    widget.audioRecorder!.setSubscriptionDuration(const Duration(milliseconds: 100));

    final _isPremitted = await Permission.microphone.request();
    if (_isPremitted != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission is not granted');
    }
    _recorderSubscription = widget.audioRecorder!.onProgress!.listen((e) {
      // Duration maxDuration = e.duration;
      // double decibels = e.decibels!.toDouble();

      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds, isUtc: true);

      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date).toString();

      setState(() {
        _recordText = txt.substring(0, 8);
      });
    });

    await widget.audioRecorder!.startRecorder(toFile: _filePath, codec: Codec.pcm16WAV);
    _theCounter(widget.audioRecorder!);
  }

  Future<void> _stopRecord(BuildContext ctx) async {
    _recorderSubscription!.cancel();
    await widget.audioRecorder!.stopRecorder();
    widget.audioRecorder!.closeAudioSession();
    if (2 == 2) {
      FormData fileBody = FormData.fromMap({
        'audio': MultipartFile.fromFile(
          _filePath,
          filename: 'sound_recorder_file_name',
        ),
      });

      var voiceChatResponse = await HttpService().postRequest(
        data: fileBody,
        endPoint: CHAT_GET_POST + "${widget.otherUserPhone}/",
      );

      if (!voiceChatResponse.error) {
        if (voiceChatResponse.data['status'] == 'success') {
          try {
            final fileBodyData = {
              'message': 'voice-message',
              'voice': voiceChatResponse.data['voice'],
              'user_phone': widget.myPhoneNumber,
            };
            final jsonData = json.encode(fileBodyData);
            widget.channel.sink.add(jsonData);
          } catch (e) {
            infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    }
  }

  void _theCounter(FlutterSoundRecorder myRecorder) {
    if (myRecorder.isStopped) {
      // stop the counter
    }
    if (myRecorder.isRecording) {
      //increase the counter
    }
    // if (myRecorder.isPaused)  {
    //   // do not have this option for now
    // }
  }

  // =============== // =================

  Future<void> _getFile(BuildContext ctx) async {
    if (widget.otherUserPhone == 'no_phone') {
      infoNoOkDialogue(context, 'Restart the app to get started', 'User Not Available');
      return;
    }
    FilePickerResult? fileResult;

    File? _file;
    FormData? fileBody;

    fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
    );
    String fileName = 'no_file';
    if (fileResult != null) {
      // if allowMultiple is true then we use List<File>
      // List<File> files = fileResult.paths.map((path) => File(path)).toList();
      _file = File(fileResult.files.single.path!);
      fileName = _file.path.split('/').last;
      String _theFormat = _file.path.split('.').last;
      if (_theFormat != 'pdf') {
        toastSnackBar('Only pdf is allowed as an attachement');
        return;
      }
      // file body
      fileBody = FormData.fromMap({
        'file': [
          fileName == 'no_file'
              ? 'no_file'
              : await MultipartFile.fromFile(
                  _file.path,
                  filename: fileName,
                )
        ],
      });
    }

    // sending request
    if (fileResult != null) {
      var chatResponse = await HttpService().postRequest(
        data: fileBody,
        endPoint: CHAT_GET_POST + "${widget.otherUserPhone}/",
      );

      if (!chatResponse.error) {
        if (chatResponse.data['status'] == 'success') {
          try {
            final fileBodyData = {
              'message': 'attachment-files',
              'files': chatResponse.data['attachmentNames'],
              'user_phone': widget.myPhoneNumber,
            };
            final jsonData = json.encode(fileBodyData);
            widget.channel.sink.add(jsonData);
            toastSnackBar('Saved Successfully');
          } catch (e) {
            infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    }
  }

  Future getImage(String mediaType, BuildContext ctx) async {
    // ignore: prefer_typing_uninitialized_variables

    var pickedFile;
    File? _image;
    final picker = ImagePicker();
    if (mediaType == 'camera') {
      pickedFile = await picker.getImage(
          source: ImageSource.camera,
          imageQuality: 65, // <- Reduce Image quality
          maxHeight: 300, // <- reduce the image size
          maxWidth: 300);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery,
          imageQuality: 65, // <- Reduce Image quality
          maxHeight: 300, // <- reduce the image size
          maxWidth: 300);
    }
    // send to server from here
    _image = File(pickedFile.path);

    String avatarName = _image.path.split('/').last;
    FormData? imageBody = FormData.fromMap({
      'image': [
        avatarName == 'no_avatar'
            ? 'no_avatar'
            : await MultipartFile.fromFile(
                _image.path,
                filename: avatarName,
              )
      ],
    });

    // send post
    if (pickedFile != null) {
      var chatResponse = await HttpService().postRequest(
        data: imageBody,
        endPoint: CHAT_GET_POST + "${widget.otherUserPhone}/",
      );

      if (!chatResponse.error) {
        if (chatResponse.data['status'] == 'success') {
          try {
            final imageBodyData = {
              'message': 'image-files',
              'images': chatResponse.data['imageNames'],
              'user_phone': widget.myPhoneNumber,
            };
            final jsonData = json.encode(imageBodyData);
            widget.channel.sink.add(jsonData);
            toastSnackBar('Saved Successfully');
          } catch (e) {
            infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    }
  }

  void sendMessage() async {
    setState(() {
      isAttachment = true;
    });
    FocusScope.of(context).unfocus();
    final theData = {
      'message': _controller.text,
      'user_phone': widget.myPhoneNumber,
    };
    final jsonData = json.encode(theData);
    widget.channel.sink.add(jsonData);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            if (isVoice)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isVoice = false;
                      });
                      _stopRecord(context);
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueAppBar,
                      ),
                      child: const Icon(Icons.clear, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            if (!isAttachment && !isVoice)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isAttachment = true;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueAppBar,
                      ),
                      child: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            if (isAttachment && !isVoice)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _getFile(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueAppBar,
                      ),
                      child: const Icon(Icons.attach_file, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showModalBottomSheet(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueAppBar,
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      toastSnackBar('Not Available');
                      // _voiceRecorder()
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueAppBar,
                      ),
                      child: const Icon(CupertinoIcons.mic, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            if (isVoice)
              Row(
                children: [
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isVoice = false;
                      });
                      _stopRecord(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueAppBar,
                      ),
                      child: const Icon(Icons.pause, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            if (isVoice)
              Expanded(
                child: SizedBox(
                  height: 50.0,
                  // color: Colors.green,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        _recordText,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
            if (!isVoice)
              Expanded(
                child: SizedBox(
                  height: 50.0,
                  child: TextFormField(
                    controller: _controller,
                    onTap: () {
                      setState(() {
                        isAttachment = false;
                      });
                    },
                    onChanged: (value) => setState(() {
                      message = value;
                    }),
                    decoration: textFieldDesign(context, 'Type Your Message'),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: message.trim().isEmpty ? null : sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.blueAppBar,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      );

  void _showModalBottomSheet() {
    const borderRaius = Radius.circular(15);
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: borderRaius, topRight: borderRaius),
        ),
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () async {
                      Navigator.of(context).pop();
                      getImage('camera', context);
                    },
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      color: Palette.blueAppBar,
                    ),
                    title: const Text('Camera'),
                    horizontalTitleGap: 0,
                    minLeadingWidth: 35,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      getImage('gallery', context);
                    },
                    horizontalTitleGap: 0,
                    minLeadingWidth: 35,
                    leading: const Icon(
                      Icons.drive_file_move_outline,
                      color: Palette.blueAppBar,
                    ),
                    title: const Text('Gallery'),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
