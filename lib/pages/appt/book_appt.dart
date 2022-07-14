import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/dummy_data.dart';
import '../../models/models.dart';
import '../../pages/screens.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class BookAppt extends StatefulWidget {
  final int doctorId;
  final String docotorName;
  final int clinicId;
  final String? patientName;
  const BookAppt({
    Key? key,
    required this.doctorId,
    required this.clinicId,
    required this.docotorName,
    this.patientName,
  }) : super(key: key);

  @override
  _BookApptState createState() => _BookApptState();
}

class _BookApptState extends State<BookAppt> {
  final List<String> _patientList = ['Select Patient', 'Me'];
  final List<String> _clinicList = ['Select Clinic'];
  String _defaultPatient = 'Select Patient';
  String _defaultClinic = 'Select Clinic';
  String _selectedDay = 'Wednesday';
  String _selectedSlot = 'None';
  String _formErrorMessage = '';
  int _selectedClinicId = 0;
  late ClinicModel _selectedClinic;
  int _selectedSlotId = 0;
  final List<ApptModel> _apptModelList = <ApptModel>[];
  final List<PatientModel> _patientModelList = <PatientModel>[];
  List<ApptModel> _selectedDayApptList = <ApptModel>[];
  final List<ClinicModel> _clinicModelList = <ClinicModel>[];
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _selectedClinicId = widget.clinicId;
    _defaultPatient = widget.patientName ?? 'Select Patient';
    _getData('All');
  }

  Future<void> _getData(String operation) async {
    setState(() {
      _isLoading = true;
    });
    final _medicalRecordResponse = await HttpService().getRequest(
        endPoint: DOCTOR_APPT_LIST + '${widget.doctorId}/$_selectedClinicId/?operation=$operation',
        isAuth: true);

    if (!_medicalRecordResponse.error) {
      try {
        setState(() {
          if (operation == 'All') {
            if (_medicalRecordResponse.data['clinics'] is List) {
              if (_medicalRecordResponse.data['clinics'].length > 0) {
                _medicalRecordResponse.data['clinics'].forEach((response) {
                  final clinicObject = ClinicModel.fromJson(response);
                  _clinicList.add(clinicObject.clinicName!);
                  _clinicModelList.add(clinicObject);
                });
                final theClinicObj = _clinicModelList.firstWhere(
                    (element) => element.id == widget.clinicId,
                    orElse: () => ClinicModel(id: null));
                if (theClinicObj.id != null) {
                  _selectedClinic = theClinicObj;
                  _defaultClinic = theClinicObj.clinicName!;
                  _clinicList.remove('Select Clinic');
                }
              }
            }
            if (_medicalRecordResponse.data['patients'] is List) {
              if (_medicalRecordResponse.data['patients'].length > 0) {
                _medicalRecordResponse.data['patients'].forEach((response) {
                  final patientObj = PatientModel.fromJson(response);
                  _patientModelList.add(patientObj);
                  _patientList.add(patientObj.user!.name ?? 'Me');
                });
              }
            }
          }
          if (operation == 'appts' || operation == 'All') {
            if (_medicalRecordResponse.data['appts'] is List) {
              _apptModelList.clear();
              if (_medicalRecordResponse.data['appts'].length > 0) {
                _medicalRecordResponse.data['appts'].forEach((theResponse) {
                  final apptObject = ApptModel.fromJson(theResponse);
                  _apptModelList.add(apptObject);
                });

                _createApptSublist('initial');
              }
            }
          }

          _selectedSlotId = 0;
          _selectedSlot = 'None';
        });
      } catch (e) {
        setState(() {
          _isUnknownError = true;
          _isLoading = false;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        _isLoading = false;
        if (_medicalRecordResponse.errorMessage == NO_INTERNET_CONNECTION) {
          // print('connection error ');
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _medicalRecordResponse.errorMessage!;
        }
      });
    }
  }

  void _createApptSublist(String weekDay) {
    _selectedDay = weekDay != 'initial' ? weekDay : 'Monday';
    if (weekDay == 'initial') {
      final currentDay = getToday();
      // print('valeur o currentDay');
      // print(currentDay);
      _selectedDay = currentDay;
    }
    setState(() {
      _selectedDayApptList = _apptModelList
          .where((element) => element.dayPattern!.weekDay!.weekDay! == _selectedDay)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Book Appointment',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _getData('All');
          },
          child: Builder(
            builder: (BuildContext ctx) {
              if (_isLoading) {
                return const LoadingPlaceHolder();
              }
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
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        widget.docotorName,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.5),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                    _infoDropdown(_clinicList, _defaultClinic, 'clinic'),
                    const SizedBox(
                      height: 5,
                    ),
                    if (widget.patientName == null)
                      _infoDropdown(_patientList, _defaultPatient, 'patient'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Column(
                        children: [
                          cardDetailItem(
                              'Clinic: ${_defaultClinic == "Select Clinic" ? "None" : _defaultClinic}',
                              MdiIcons.hospitalBuilding),
                          cardDetailItem(
                              'Available Slots: ${_apptModelList.length}', Icons.access_time),
                          cardDetailItem('Selected Slot: $_selectedSlot', Icons.date_range),
                          cardDetailItem(
                              'Patient: ${_defaultPatient == "Select Patient" ? "None" : _defaultPatient}',
                              CupertinoIcons.person),
                          cardDetailItem(
                              _selectedClinic.address != null
                                  ? "${_selectedClinic.address ?? ''}, ${_selectedClinic.district!.name ?? ''}, ${_selectedClinic.city!.name ?? ''}"
                                  : "Address Not Available",
                              Icons.room_outlined,
                              maxLine: 2),
                        ],
                      ),
                    ),
                    Container(
                      width: mQuery.width * 0.90,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: dashedLine(Palette.blueAppBar),
                    ),
                    // Days of the week
                    Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        'Select Day',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Wrap(
                      spacing: 5.0,
                      // runSpacing: 2.0,
                      children: [
                        ...GlobalDummyData.WEEK_DAY_MODEL_DATE
                            .map(
                              (e) => ChoiceChip(
                                selected: e.weekDay == _selectedDay,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _createApptSublist(e.weekDay ?? "Monday");
                                  });
                                },
                                backgroundColor: Palette.imageBackground,
                                selectedColor: Palette.blueAppBar,
                                label: Text(
                                  e.weekDay!,
                                  style: TextStyle(
                                      color:
                                          e.weekDay == _selectedDay ? Colors.white : Colors.black),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                    Container(
                      width: mQuery.width * 0.90,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: dashedLine(Palette.blueAppBar),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        'Select Slot',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 5.0,
                      children: [
                        if (_selectedDayApptList.isEmpty)
                          SizedBox(
                            width: mQuery.width * 0.90,
                            child: const Text(
                              'No Appt Avaliable for Today',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_selectedDayApptList.isNotEmpty)
                          ..._selectedDayApptList
                              .map(
                                (e) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSlotId = e.id!;
                                      _selectedSlot = "${e.startApptTime} - ${e.endApptTime}";
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)),
                                    elevation: 5.0,
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        height: 100,
                                        width: 180,
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: _selectedSlotId == e.id
                                              ? Palette.blueAppBar
                                              : Palette.imageBackground,
                                        ),
                                        child: Column(
                                          children: [
                                            AutoSizeText(
                                              e.apptDate!,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: _selectedSlotId == e.id
                                                      ? Colors.white
                                                      : Colors.black),
                                              maxLines: 1,
                                              minFontSize: 12,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(
                                              height: 3.0,
                                            ),
                                            dashedLine(_selectedSlotId == e.id
                                                ? Colors.white
                                                : Colors.black),
                                            const SizedBox(
                                              height: 3.0,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: _fromToText(
                                                        'From', e.startApptTime!, e.id)),
                                                Expanded(
                                                    child: _fromToText('To', e.endApptTime!, e.id)),
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              )
                              .toList(),
                      ],
                    ),
                    if (_formErrorMessage != '')
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: mQuery.width * 0.90,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          _formErrorMessage,
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 5.0,
                          minimumSize: const Size(300, 42),
                          onPrimary: Colors.white,
                          primary: Palette.blueAppBar,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                      onPressed: () => _submitData(context),
                      child: const Text(
                        'Proceed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      height: 150,
                    )
                  ],
                ),
              );
            },
          ),
        ));
  }

  void _submitData(BuildContext ctx) async {
    // create body
    bool _isDialogRunning = false;
    if (!_isFormOkay()) {
      return;
    }

    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      int patientId = int.tryParse(DRAWER_DATA['id']) ?? 0;
      if (_defaultPatient != 'Me') {
        final patientObj = _patientModelList.firstWhere((element) =>
            element.user!.name == _defaultPatient || element.user!.rtlName == _defaultPatient);
        patientId = patientObj.user!.id!;
      }
      FormData _body = FormData.fromMap({
        'patient_id': patientId,
        "slot_id": _selectedSlotId,
        "operation": widget.patientName == null ? 'booking' : 'reschedule',
      });

      var _apptresponse = await HttpService().postRequest(
        data: _body,
        endPoint: DOCTOR_APPT_LIST + '${widget.doctorId}/$_selectedClinicId/',
        isAuth: true,
      );
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!_apptresponse.error) {
        try {
          if (_apptresponse.data['message'] == 'success') {
            ApptModel? _theSelectedApptModel = _apptModelList.firstWhere(
                (element) => element.id == _selectedSlotId,
                orElse: () => ApptModel(id: null));
            if (_theSelectedApptModel.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetails(
                    apptModel: ApptModel(
                      doctor: DoctorModel(user: UserModel(name: widget.docotorName)),
                      clinic: _selectedClinic,
                      startApptTime: _theSelectedApptModel.startApptTime,
                      endApptTime: _theSelectedApptModel.endApptTime,
                      dayPattern: DaySchedulePatternModel(
                        weekDay: WeekDayModel(weekDay: _selectedDay),
                      ),
                      apptDate: _theSelectedApptModel.apptDate,
                      relative: null,
                      patient: PatientModel(
                        user: UserModel(name: _defaultPatient),
                      ),
                      status: 'Booked',
                    ),
                    isSummary: true,
                  ),
                ),
              );
            }
            toastSnackBar(
                widget.patientName == null ? 'Booked Successfully' : 'Rescheduled Successfully');
          } else {
            String _theMessage = GlobalVariable.UNEXPECTED_ERROR;
            if (_apptresponse.data['message'] == 'field_error') {
              _theMessage = 'Select your field properly and try again';
            } else if (_apptresponse.data['message'] == 'already_booked') {
              _theMessage =
                  'This patient has already booked appt with this doctor. Book with another doctor or reschedule your appointment';
            } else if (_apptresponse.data['message'] == 'exceeding_four') {
              _theMessage =
                  'Your are exceeding the number of booked appt. Reschedule your booked appointment if you still want to book this time slot';
            }
            infoNoOkDialogue(context, _theMessage, 'Error Occured');
          }
        } catch (e) {
          _isDialogRunning ? Navigator.of(ctx).pop() : null;
          infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
              GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

  void _theSetState(String theMessage) {
    setState(() {
      _formErrorMessage = theMessage;
    });
  }

  bool _isFormOkay() {
    if (_defaultPatient == 'Select Patient') {
      _theSetState('Select a patient');
      return false;
    }
    if (_defaultClinic == 'Select Clinic' || _selectedClinicId == 0) {
      _theSetState('You have not selected any clinic');
      return false;
    }

    if (_selectedSlotId == 0 || _selectedSlot == 'None') {
      _theSetState('Select a time slot to book');
      return false;
    }
    return true;
  }

  Widget _infoDropdown(theList, defaultVal, operation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Palette.blueAppBar, width: 1.5),
      ),
      child: DropdownButton<String>(
        value: defaultVal,
        icon: const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(
            Icons.keyboard_arrow_down_sharp,
          ),
        ),
        iconSize: 28,
        isExpanded: true,
        elevation: 16,
        style: const TextStyle(color: Colors.black, fontSize: 15.5, fontWeight: FontWeight.w500),
        dropdownColor: Palette.imageBackground,
        underline: const SizedBox.shrink(),
        onChanged: (String? newValue) {
          setState(() {
            if (operation == 'clinic') {
              _defaultClinic = newValue!;
              final clinicObj = _clinicModelList.firstWhere(
                  (element) => element.clinicName == newValue,
                  orElse: () => ClinicModel(id: null));
              if (clinicObj.id != null) {
                _selectedClinicId = clinicObj.id!;
                _selectedClinic = clinicObj;
              } else {
                _selectedClinicId = 0;
              }
              _getData('appts');
            }
            if (operation == 'patient') {
              _defaultPatient = newValue!;
            }
          });
        },
        items: theList.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ));
        }).toList(),
      ),
    );
  }

  Column _fromToText(String title, String data, int? id) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          title,
          style:
              TextStyle(fontSize: 16, color: _selectedSlotId == id ? Colors.white : Colors.black),
          maxLines: 1,
          minFontSize: 13,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 4.0,
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: AutoSizeText(
            data,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            minFontSize: 13,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
