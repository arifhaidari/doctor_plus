import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_plus/widgets/widgets.dart';
import '../models/models.dart';
import '../providers/provider_list.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'screens.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final List<NotificationModel> _notificationList = <NotificationModel>[];
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _sortingKey = '';
  String _nextPage = '';
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _getData('All', false);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= _notificationList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(_sortingKey, true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _getData(String sortingKey, bool nextPage) async {
    List<NotificationModel> _temmpNotificationList = <NotificationModel>[];
    _sortingKey = sortingKey;

    final _noteResponseList = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : NOTE_GET + '?q=$sortingKey',
        isAuth: true);

    if (!_noteResponseList.error) {
      try {
        setState(() {
          if (_noteResponseList.data['results'] is List &&
              _noteResponseList.data['results'].length != 0) {
            _itemCount = _noteResponseList.data['count'];
            _nextPage = _noteResponseList.data['next'] ?? '';
            _noteResponseList.data['results'].forEach((response) {
              final theObject = NotificationModel.fromJson(response);
              _temmpNotificationList.add(theObject);
            });

            if (!nextPage) {
              _notificationList.clear();
              _notificationList.addAll(_temmpNotificationList);
            } else {
              _notificationList.addAll(_temmpNotificationList);
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
        if (_noteResponseList.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _noteResponseList.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          actions: [
            _notificationSorter(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _getData('All', false);
          },
          child: Builder(
            builder: (context) {
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
              return _notificationList.isEmpty
                  ? const PlaceHolder(
                      title: 'No Notification Available',
                      body: 'Your notification will be listed here',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, left: 5, right: 5),
                      itemCount: _notificationList.length + 1,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        if (index < _notificationList.length) {
                          return Dismissible(
                            key: ValueKey(_notificationList[index].id),
                            onDismissed: (dirction) {
                              _removeNote(_notificationList[index].id ?? 0);
                            },
                            background: Container(
                              padding: const EdgeInsets.only(right: 30),
                              color: Colors.red,
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Clear Notification',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (_notificationList[index].category == 'Review') {
                                  if (_notificationList[index].appt != null) {
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return FeedbackPopup(
                                            apptModel: _notificationList[index].appt ??
                                                ApptModel(
                                                  id: null,
                                                ),
                                            noteId: _notificationList[index].id ?? 0,
                                          );
                                        }).then((value) {
                                      try {
                                        if (value['is_success']) {
                                          setState(() {
                                            _notificationList.removeWhere((element) =>
                                                element.id == _notificationList[index].id);
                                            _itemCount -= 1;
                                          });
                                        }
                                        // ignore: empty_catches
                                      } catch (e) {}
                                    });
                                  }
                                }
                              },
                              child: Card(
                                elevation: 4,
                                color: Palette.imageBackground,
                                child: ListTile(
                                  leading: Icon(
                                    _noteTypeIcon(
                                        _notificationList[index].category ?? 'Appt Cancelation'),
                                    size: 35,
                                    color: Colors.blue[900],
                                  ),
                                  title: AutoSizeText(
                                    _notificationList[index].title ?? 'Unknown Title',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                    maxLines: 1,
                                    minFontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    _notificationList[index].body ?? '',
                                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            child: Center(
                              child: _itemCount <= _notificationList.length
                                  ? null
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        }
                      });
            },
          ),
        ));
  }

  void _removeNote(int noteId) async {
    var feedbackResponse = await HttpService().deleteRequest(
      endPoint: NOTE_DETAIL + "$noteId/",
    );

    if (!feedbackResponse.error) {
      try {
        setState(() {
          _notificationList.removeWhere((element) => element.id == noteId);
          _itemCount -= 1;
        });

        print('value of _itemCount <= _notificationList.length');
        print(_itemCount);
        print(_notificationList.length);

        toastSnackBar('Deleted Successfully');
      } catch (e) {
        infoNoOkDialogue(
            context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

  IconData _noteTypeIcon(String category) {
    switch (category) {
      case 'Appt Cancelation':
        return Icons.access_time;
      // break; // it is a dead code
      case 'Review':
        return Icons.rate_review_outlined;
      case 'Review Reply':
        return Icons.reply;
      default:
        return Icons.star_outline;
    }
  }

  PopupMenuButton _notificationSorter() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        _getData(result, false);
      },
      icon: const Icon(Icons.sort),
      color: Palette.imageBackground,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'All',
          child: Text('All'),
        ),
        const PopupMenuItem<String>(
          value: 'appt_cancelation',
          child: Text('Appointment'),
        ),
        const PopupMenuItem<String>(
          value: 'review',
          child: Text('Review'),
        ),
        const PopupMenuItem<String>(
          value: 'Clear',
          child: Text('Clear All'),
        ),
      ],
    );
  }
}
