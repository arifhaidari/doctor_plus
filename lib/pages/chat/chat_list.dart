import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../providers/provider_list.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _nextPage = '';
  int _itemCount = 0;

  final TextEditingController _chatUesrSearchController = TextEditingController();
  final List<ChatUserModel> chatUserModelList = <ChatUserModel>[];
  final List<ChatUserModel> _searchList = <ChatUserModel>[];
  @override
  void initState() {
    super.initState();
    _getData(false);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= chatUserModelList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _getData(bool nextPage) async {
    List<ChatUserModel> _tempChatUserModel = <ChatUserModel>[];

    final chatUserResponse = await HttpService()
        .getRequest(endPoint: (nextPage && _nextPage != '') ? _nextPage : CHAT_USER_LIST);

    if (!chatUserResponse.error) {
      try {
        setState(() {
          if (chatUserResponse.data['results'] is List &&
              chatUserResponse.data['results'].length != 0) {
            chatUserResponse.data['results'].forEach((chatUserObject) {
              _itemCount = chatUserResponse.data['count'];
              _nextPage = chatUserResponse.data['next'] ?? '';
              ChatUserModel theObject = ChatUserModel.fromJson(chatUserObject);
              _tempChatUserModel.add(theObject);
            });

            if (!nextPage) {
              chatUserModelList.clear();
              chatUserModelList.addAll(_tempChatUserModel);
            } else {
              chatUserModelList.addAll(_tempChatUserModel);
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
        if (chatUserResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = chatUserResponse.errorMessage!;
        }
      });
    }
  }

  void _searchChatUser(String query, {bool isForceSearch = false}) async {
    if (query.length % 3 == 0 && query != '') {
      String lowerQuery = query.toLowerCase();

      if (query.length < 6 && !isForceSearch) {
        final theList = chatUserModelList.where((element) {
          final theName = element.name != null ? element.name!.toLowerCase() : 'name_not_available';
          return ((theName != 'name_not_available' ? theName.contains(lowerQuery) : false) ||
              (element.rtlName != null ? element.rtlName!.contains(query) : false));
        });
        if (theList.isNotEmpty) {
          setState(() {
            for (var element in theList) {
              chatUserModelList.remove(element);
              chatUserModelList.insert(0, element);
            }
          });
        }
      } else {
        final searchResultObject =
            await HttpService().getRequest(endPoint: CHAT_USER_LIST + "?q=$query");

        if (!searchResultObject.error) {
          try {
            if (searchResultObject.data is List && searchResultObject.data.length != 0) {
              if (searchResultObject.data.length > 0) {
                setState(() {
                  searchResultObject.data.forEach((response) {
                    final theObject = ChatUserModel.fromJson(response);
                    _searchList.add(theObject);
                  });
                  // add to list and skip the redundant
                  for (var element in _searchList) {
                    final chatUserObject = chatUserModelList.firstWhere(
                        (theVal) => theVal.phone == element.phone,
                        orElse: () => ChatUserModel(phone: ''));
                    if (element.phone == chatUserObject.phone) {
                      chatUserModelList.remove(element);
                      chatUserModelList.insert(0, element);
                    } else {
                      chatUserModelList.insert(0, element);
                    }
                  }
                });
              }
            }
          } catch (e) {
            infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: myAppBar('Chat', isAction: true, function: () {}),
        drawer: const CustomDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            _getData(false);
          },
          child: Builder(
            builder: (BuildContext ctx) {
              if (_isUnknownError || _isConnectionError) {
                if (_isConnectionError) {
                  return const ErrorPlaceHolder(
                      isStartPage: true,
                      errorTitle: 'Internet Connection Issue',
                      errorDetail: 'Check your internet connection and try again');
                } else {
                  return ErrorPlaceHolder(
                    isStartPage: true,
                    errorTitle: 'Unknown Error. Try again later',
                    errorDetail: _errorMessage,
                  );
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
                    child: CupertinoSearchTextField(
                      placeholder: 'Search Patient',
                      controller: _chatUesrSearchController,
                      onChanged: (changeVal) {
                        _searchChatUser(changeVal);
                      },
                      onSuffixTap: () {
                        _searchChatUser(_chatUesrSearchController.text, isForceSearch: true);
                        FocusScope.of(context).unfocus();
                      },
                      suffixIcon: const Icon(
                        Icons.search,
                        size: 25,
                        color: Palette.blueAppBar,
                      ),
                    ),
                  ),
                  Expanded(
                    child: chatUserModelList.isEmpty
                        ? const PlaceHolder(
                            title: 'No Chat Available',
                            body: 'User with completed Appt are able to start a chat')
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(10.0),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const PageScrollPhysics(),
                            itemCount: chatUserModelList.length + 1,
                            itemBuilder: (context, index) {
                              if (index < chatUserModelList.length) {
                                final noChatYet =
                                    chatUserModelList[index].lastText!.messageText != 'no_chat_yet';
                                final sendByMe = chatUserModelList[index].lastText!.sendByMe;
                                return Card(
                                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final theToken = await SharedPref().getToken();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatMessage(
                                            theToken: theToken.toString(),
                                            chatUserModel: chatUserModelList[index],
                                          ),
                                        ),
                                      ).then((value) {
                                        if (!value['is_chat_empty']) {
                                          setState(() {
                                            chatUserModelList[index].lastText!.sendByMe =
                                                value['is_sender_me'] ?? true;
                                            chatUserModelList[index].lastText!.messageType =
                                                value['message_type'];
                                            chatUserModelList[index].lastText!.messageText =
                                                value['message_text'];
                                            chatUserModelList[index].lastText!.timestamp =
                                                value['timestamp'];

                                            chatUserModelList[index].lastText!.seen = true;
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      width: mQuery.width * 0.94,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ProfileAvatarCircle(
                                                  imageUrl: chatUserModelList[index].avatar,
                                                  isActive: true,
                                                  radius: 75,
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          AutoSizeText(
                                                            chatUserModelList[index].name ??
                                                                'Unknown User',
                                                            maxLines: 1,
                                                            minFontSize: 15,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w700),
                                                          ),
                                                          AutoSizeText(
                                                            timeExtractor(chatUserModelList[index]
                                                                .lastText!
                                                                .timestamp!),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            minFontSize: 13,
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w400,
                                                                color: Palette.darkGreen),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          if (noChatYet)
                                                            Icon(Icons.done_all,
                                                                color: chatUserModelList[index]
                                                                            .lastText!
                                                                            .seen ==
                                                                        false
                                                                    ? Palette.darkGreen
                                                                    : Colors.blue[900]),
                                                          const SizedBox(
                                                            width: 3.0,
                                                          ),
                                                          if (!noChatYet)
                                                            const Expanded(
                                                              child: AutoSizeText(
                                                                '...',
                                                                overflow: TextOverflow.ellipsis,
                                                                minFontSize: 13,
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w400,
                                                                    color: Colors.black),
                                                              ),
                                                            ),
                                                          if (chatUserModelList[index]
                                                                      .lastText!
                                                                      .messageType ==
                                                                  'text' &&
                                                              noChatYet)
                                                            Expanded(
                                                              child: AutoSizeText(
                                                                chatUserModelList[index]
                                                                        .lastText!
                                                                        .messageText ??
                                                                    '',
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                minFontSize: 13,
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                        (chatUserModelList[index]
                                                                                        .lastText!
                                                                                        .seen ==
                                                                                    true ||
                                                                                sendByMe!)
                                                                            ? FontWeight.w400
                                                                            : FontWeight.w500,
                                                                    color: (chatUserModelList[index]
                                                                                    .lastText!
                                                                                    .seen ==
                                                                                true ||
                                                                            sendByMe!)
                                                                        ? Palette.darkGreen
                                                                        : Colors.black),
                                                              ),
                                                            ),
                                                          if (chatUserModelList[index]
                                                                      .lastText!
                                                                      .messageType ==
                                                                  'file_attachment' &&
                                                              noChatYet)
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.start,
                                                              children: [
                                                                Icon(
                                                                  Icons.attachment_rounded,
                                                                  color: (chatUserModelList[index]
                                                                                  .lastText!
                                                                                  .seen ==
                                                                              true ||
                                                                          sendByMe!)
                                                                      ? Palette.darkGreen
                                                                      : Colors.black,
                                                                ),
                                                                const SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(
                                                                  'Attachments',
                                                                  style: TextStyle(
                                                                      fontSize: 15,
                                                                      fontWeight:
                                                                          (chatUserModelList[index]
                                                                                          .lastText!
                                                                                          .seen ==
                                                                                      true ||
                                                                                  sendByMe!)
                                                                              ? FontWeight.w400
                                                                              : FontWeight.w500,
                                                                      color:
                                                                          chatUserModelList[index]
                                                                                      .lastText!
                                                                                      .seen ==
                                                                                  true
                                                                              ? Palette.darkGreen
                                                                              : Colors.black),
                                                                )
                                                              ],
                                                            ),
                                                          if (chatUserModelList[index]
                                                                      .lastText!
                                                                      .messageType ==
                                                                  'voice' &&
                                                              noChatYet)
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.start,
                                                              children: [
                                                                Icon(
                                                                  Icons.mic_none_rounded,
                                                                  color: (chatUserModelList[index]
                                                                                  .lastText!
                                                                                  .seen ==
                                                                              true ||
                                                                          sendByMe!)
                                                                      ? Palette.darkGreen
                                                                      : Colors.black,
                                                                ),
                                                                const SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(
                                                                  'Voice',
                                                                  style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight:
                                                                          (chatUserModelList[index]
                                                                                          .lastText!
                                                                                          .seen ==
                                                                                      true ||
                                                                                  sendByMe!)
                                                                              ? FontWeight.w400
                                                                              : FontWeight.w600,
                                                                      color:
                                                                          (chatUserModelList[index]
                                                                                          .lastText!
                                                                                          .seen ==
                                                                                      true ||
                                                                                  sendByMe!)
                                                                              ? Palette.darkGreen
                                                                              : Colors.black),
                                                                )
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                                  child: Center(
                                    child: _itemCount <= chatUserModelList.length
                                        ? null
                                        : const CircularProgressIndicator(),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
