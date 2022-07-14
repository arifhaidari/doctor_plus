import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../providers/provider_list.dart';
import '../../pages/screens.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class MyAppt extends StatefulWidget {
  const MyAppt({Key? key}) : super(key: key);

  @override
  _MyApptState createState() => _MyApptState();
}

class _MyApptState extends State<MyAppt> {
  final List<ApptModel> _myApptList = <ApptModel>[];
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
        _itemCount <= _myApptList.length
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
    List<ApptModel> _tempApptList = <ApptModel>[];
    _sortingKey = sortingKey;
    Map<String, dynamic> _theMap = {
      "q": sortingKey,
      "is_profile": 'no',
    };
    final _apptResponseList = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : APPT_CREATE_LIST, queryMap: _theMap);

    if (!_apptResponseList.error) {
      try {
        setState(() {
          if (_apptResponseList.data['results'] is List &&
              _apptResponseList.data['results'].length != 0) {
            _itemCount = _apptResponseList.data['count'];
            _nextPage = _apptResponseList.data['next'] ?? '';
            if (_apptResponseList.data['results'].length > 0) {
              _apptResponseList.data['results'].forEach((response) {
                final theObject = ApptModel.fromJson(response);
                _tempApptList.add(theObject);
              });
            }
          }
          if (!nextPage) {
            _myApptList.clear();
            _myApptList.addAll(_tempApptList);
          } else {
            _myApptList.addAll(_tempApptList);
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
        if (_apptResponseList.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _apptResponseList.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Appointments',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          actions: [
            _notificationSorter(),
          ],
        ),
        drawer: const CustomDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            _getData('All', false);
          },
          child: Builder(
            builder: (BuildContext ctxt) {
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
              return _myApptList.isEmpty
                  ? const PlaceHolder(
                      title: 'No Appt Available',
                      body:
                          'Your booked and completed appts of you and your registered family members will be listed here',
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _myApptList.length + 1,
                      padding: const EdgeInsets.all(10.0),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        if (index < _myApptList.length) {
                          return ApptTile(
                            apptModelObject: _myApptList[index],
                            theFunc: (
                              int apptId,
                              int clinicId,
                              int doctorId,
                              int patientId,
                            ) {
                              _cancelAppt(apptId, clinicId, doctorId, patientId);
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: _itemCount <= _myApptList.length
                                  ? null
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        }
                      });

              // return ApptTile(
              //   myApptList: _myApptList,
              // );
            },
          ),
        ));
  }

  void _cancelAppt(int apptId, int clinicId, int doctorId, int patientId) async {
    bool _isDialogRunning = false;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      FormData _body = FormData.fromMap({
        'patient_id': patientId,
        "slot_id": apptId,
        "operation": 'cancel',
      });

      var _apptresponse = await HttpService().postRequest(
        data: _body,
        endPoint: DOCTOR_APPT_LIST + '$doctorId/$clinicId/',
        isAuth: true,
      );

      Navigator.of(context).pop();
      _isDialogRunning = false;

      if (!_apptresponse.error) {
        try {
          if (_apptresponse.data['message'] == 'success') {
            // remove from the list
            setState(() {
              _myApptList.removeWhere((element) => element.id == apptId);
              _itemCount -= 1;
            });
            toastSnackBar('Canceled Successfully');
          } else {
            String _theMessage = GlobalVariable.UNEXPECTED_ERROR;
            if (_apptresponse.data['message'] == 'field_error') {
              _theMessage = 'Select your field properly and try again';
            } else if (_apptresponse.data['message'] == 'already_booked') {
              _theMessage =
                  'This patient has already booked appt with this doctor. Book with another doctor or reschedule your appointment';
            }
            infoNoOkDialogue(context, _theMessage, 'Error Occured');
          }
        } catch (e) {
          _isDialogRunning ? Navigator.of(context).pop() : null;
          infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
              GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(context).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
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
          value: 'Booked',
          child: Text('Booked'),
        ),
        const PopupMenuItem<String>(
          value: 'Completed',
          child: Text('Completed'),
        ),
        const PopupMenuItem<String>(
          value: 'Me',
          child: Text('Me'),
        ),
        const PopupMenuItem<String>(
          value: 'Relatives',
          child: Text('Relatives'),
        ),
      ],
    );
  }
}
