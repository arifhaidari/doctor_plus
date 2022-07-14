import 'package:dio/dio.dart';

import '../../models/models.dart';
import 'package:flutter/material.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class PatientApptSlot extends StatefulWidget {
  final bool isPatient;
  final PatientModel patient;
  const PatientApptSlot({Key? key, required this.isPatient, required this.patient})
      : super(key: key);

  @override
  State<PatientApptSlot> createState() => _PatientApptSlotState();
}

class _PatientApptSlotState extends State<PatientApptSlot> {
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

    _getData(widget.isPatient ? 'Me' : 'All');
    _scrollController.addListener(() {
      // _scrollController.position.pixels
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= _myApptList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(_sortingKey, nextPage: true);
      }
    });
  }

  Future<void> _getData(String sortingKey, {bool nextPage = false}) async {
    List<ApptModel> _tempApptList = <ApptModel>[];
    _sortingKey = sortingKey;

    Map<String, dynamic> _theMap = {
      "q": sortingKey,
      "is_profile": 'yes',
      "user_id": widget.patient.user!.id ?? 0,
    };

    final patientProfileResponse = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : APPT_CREATE_LIST, queryMap: _theMap);

    if (!patientProfileResponse.error) {
      try {
        setState(() {
          if (patientProfileResponse.data['results'] is List &&
              patientProfileResponse.data['results'].length != 0) {
            _itemCount = patientProfileResponse.data['count'];
            _nextPage = patientProfileResponse.data['next'] ?? '';
            patientProfileResponse.data['results'].forEach((element) {
              _tempApptList.add(ApptModel.fromJson(element));
            });
          }
          if (!nextPage) {
            _myApptList.clear();
            _myApptList.addAll(_tempApptList);
          } else {
            _myApptList.addAll(_tempApptList);
          }
          print('value fo _itemCount and next pae');
          print(_itemCount);
          print(_nextPage);
          print(_myApptList.length);
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
        if (patientProfileResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = patientProfileResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async {
          _getData(widget.isPatient ? 'Me' : 'All');
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
                    itemCount: _myApptList.length + 1,
                    padding: const EdgeInsets.all(10.0),
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      if (index < _myApptList.length) {
                        return ApptTile(
                          isViewProfile: true,
                          patient: widget.patient,
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
          },
        ),
      ),
    );
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
}
