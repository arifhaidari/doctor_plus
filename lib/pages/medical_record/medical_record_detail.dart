import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/medical_record_model.dart';
import '../../models/user_model.dart';
import '../../providers/provider_list.dart';
import '../../pages/screens.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class MedicalRecordDetail extends StatefulWidget {
  final int recordId;
  const MedicalRecordDetail({Key? key, required this.recordId}) : super(key: key);

  @override
  _MedicalRecordDetailState createState() => _MedicalRecordDetailState();
}

class _MedicalRecordDetailState extends State<MedicalRecordDetail> {
  MedicalRecordModel _medicalRecordModel = MedicalRecordModel();
  final _searchMyDoctorController = TextEditingController();

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    final _medicalRecordResponse = await HttpService()
        .getRequest(endPoint: MEDICAL_RECORD_DETAIL + '${widget.recordId}', isAuth: true);

    if (!_medicalRecordResponse.error) {
      try {
        setState(() {
          _medicalRecordModel = MedicalRecordModel.fromJson(_medicalRecordResponse.data);
          _medicalRecordModel.sharedWith!
              .removeWhere((element) => element.id == _medicalRecordModel.relatedDoctor!.user!.id);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        _isLoading = false;
        if (_medicalRecordResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _medicalRecordResponse.errorMessage!;
        }
      });
    }
  }

  bool _isReverse = false;

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        print('isndie the internal gesture ');
        _isReverse = false;
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          // resizeToAvoidBottomInset: false, // this is new
          backgroundColor: Palette.scaffoldBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: Platform.isAndroid
                  ? const Icon(Icons.arrow_back)
                  : const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop({
                "record_id": _medicalRecordModel.id,
                "file_no": _medicalRecordModel.recordFiles!.length,
                "title": _medicalRecordModel.title,
                "related_doctor": _medicalRecordModel.relatedDoctor!.user!.name,
                "patient": _medicalRecordModel.patient!.user!.name,
              }),
            ),
            title: const Text(
              'Medical Record',
              style: TextStyle(
                  fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Palette.blueAppBar,
            actions: [
              IconButton(
                  icon: const Icon(MdiIcons.archiveEditOutline),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditMedicalRecord(
                                medicalRecordModel: _medicalRecordModel,
                              ))).then((value) => _getData()))
            ],
          ),
          body: Builder(
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
              return Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  reverse: _isReverse ? true : false, // this is new
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ViewDoctorProfile(
                                        doctorId:
                                            _medicalRecordModel.relatedDoctor!.user!.id ?? 0))),
                            child: ProfileAvatarSquare(
                              avatarLink: _medicalRecordModel.relatedDoctor!.user!.avatar,
                              gender: _medicalRecordModel.relatedDoctor!.user!.gender ?? 'Male',
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ViewDoctorProfile(
                                              doctorId:
                                                  _medicalRecordModel.relatedDoctor!.user!.id ??
                                                      0))),
                                  child: tileText(
                                      "${_medicalRecordModel.relatedDoctor!.title!.title} ${_medicalRecordModel.relatedDoctor!.user!.name}",
                                      'doctor_name'),
                                ),
                                tileText(
                                    (_medicalRecordModel.relatedDoctor!.specialityList!.isNotEmpty
                                        ? _medicalRecordModel
                                            .relatedDoctor!.specialityList!.first.name
                                        : "No Speciality")!,
                                    'other'),
                                if (_medicalRecordModel.relatedDoctor!.specialityList!.length > 1)
                                  tileText(
                                      _medicalRecordModel.relatedDoctor!.specialityList!.last.name!,
                                      'other'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    RatingBarIndicator(
                                      rating: _medicalRecordModel.relatedDoctor!.averageStar ?? 3.5,
                                      itemBuilder: (context, index) => const Icon(
                                        Icons.star,
                                        color: Colors.amberAccent,
                                      ),
                                      itemCount: 5,
                                      itemSize: 21.0,
                                      unratedColor: Colors.grey[400],
                                      direction: Axis.horizontal,
                                    ),
                                    tileText("(${_medicalRecordModel.relatedDoctor!.reviewNo})",
                                        'other'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        width: mQuery.width * 0.85,
                        child: dashedLine(Palette.blueAppBar),
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 5.0,
                        direction: Axis.horizontal,
                        children: _medicalRecordModel.recordFiles!
                            .map(
                              (e) => isPdf(e.file!)
                                  ? _pdfDisplay(e.file)
                                  : _medicalFileDisplay(e.file!),
                            )
                            .toList(),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: mQuery.width * 0.85,
                        child: dashedLine(Palette.blueAppBar),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 5, left: 10),
                        child: const Text(
                          'Share With Doctors:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      if (_medicalRecordModel.patient!.shareRecordToAll!)
                        const ListTile(
                          title: Text(
                            'by default we share your medical record with all those doctors which you have booked or completed appts.',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          subtitle: Text(
                              'To change the default, go to settings and change the default sharing file for all doctors'),
                        ),
                      if (_medicalRecordModel.generalAccess! &&
                          !_medicalRecordModel.patient!.shareRecordToAll!)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: ListTile(
                                title: Text(
                                  'This medical record is shared with all those doctors which you have booked or completed appts.',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: FlutterSwitch(
                                activeColor: Palette.blueAppBar,
                                width: 50.0,
                                height: 25.0,
                                value: _medicalRecordModel.generalAccess!,
                                onToggle: (val) {
                                  setState(() {
                                    _toggleGeneralAccess(_medicalRecordModel.generalAccess!,
                                        _medicalRecordModel.id!, context);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      if (!_medicalRecordModel.generalAccess! &&
                          !_medicalRecordModel.patient!.shareRecordToAll!)
                        Row(
                          children: [
                            const Expanded(
                              child: ListTile(
                                title: Text(
                                  'Share with all doctors',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: FlutterSwitch(
                                activeColor: Palette.blueAppBar,
                                width: 50.0,
                                height: 25.0,
                                value: _medicalRecordModel.generalAccess!,
                                onToggle: (val) {
                                  setState(() {
                                    _toggleGeneralAccess(_medicalRecordModel.generalAccess!,
                                        _medicalRecordModel.id!, context);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      if (!_medicalRecordModel.generalAccess! &&
                          !_medicalRecordModel.patient!.shareRecordToAll!)
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 10),
                              width: mQuery.width * 0.85,
                              height: 60,
                              child: Card(
                                elevation: 2.0,
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: TypeAheadFormField<UserModel?>(
                                    loadingBuilder: (context) => circularLoading(),
                                    noItemsFoundBuilder: (context) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'No Doctor Found',
                                          style: TextStyle(
                                              fontSize: 16.0, fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    },
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: _searchMyDoctorController,
                                      decoration: textFieldDesign(context, 'Search Doctor',
                                          isIcon: true,
                                          theTextController: _searchMyDoctorController),
                                    ),
                                    suggestionsCallback: _getMyDoctorSuggession,
                                    itemBuilder: (context, UserModel? userModel) => ListTile(
                                          title: ListTile(
                                            leading: const CircleAvatar(
                                              child: Icon(MdiIcons.doctor),
                                              backgroundColor: Palette.blueAppBar,
                                            ),
                                            title: Text(userModel!.name ?? 'No Doctor'),
                                          ),
                                        ),
                                    onSuggestionSelected: (UserModel? userModel) {
                                      _addOrRemoveToShareWith(
                                          userModel!, 'add', _medicalRecordModel.id!, context);
                                      _searchMyDoctorController.clear();
                                    }),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 0),
                              width: mQuery.width * 0.85,
                              child: Wrap(
                                  // alignment: WrapAlignment.start,
                                  spacing: 5.0,
                                  runSpacing: 0.0,
                                  children: [
                                    if (_medicalRecordModel.sharedWith!.isEmpty)
                                      const Center(
                                        child: Text(
                                          'Only Shared With Related Doctor',
                                          style:
                                              TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ..._medicalRecordModel.sharedWith!.map((e) {
                                      return InputChip(
                                        label: Text(e.name!),
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        elevation: 5.0,
                                        deleteIconColor: Colors.white,
                                        // avatar: Icon(Icons.local_hospital),
                                        backgroundColor: Palette.blueAppBar,
                                        onDeleted: () {
                                          questionDialogue(
                                              context,
                                              'Do you really want to not share with ${e.name}?',
                                              'Unshare Medical Record', () {
                                            _addOrRemoveToShareWith(
                                                e, 'remove', _medicalRecordModel.id!, context);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ]),
                            ),
                          ],
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: mQuery.width * 0.85,
                        child: dashedLine(Palette.blueAppBar),
                      ),
                      cardDetailItem(
                          'Title: ${_medicalRecordModel.title}', MdiIcons.recordCircleOutline,
                          maxLine: 2),
                      cardDetailItem(
                          'Medical Record No: ${_medicalRecordModel.recordFiles!.length}',
                          Icons.medical_services_outlined),
                      cardDetailItem('Patient: ${_medicalRecordModel.patient!.user!.name}',
                          Icons.person_outlined),
                      cardDetailItem(
                          'Completed Appts No: ${_medicalRecordModel.patient!.totalBookedAppt}',
                          Icons.date_range),
                      cardDetailItem(
                          'Last Appointment: ${_medicalRecordModel.patient!.lastCompletedAppt ?? "No Completed Appt"}',
                          Icons.access_time),
                      // Padding(
                      //     // this is new
                      //     padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  GestureDetector _pdfDisplay(String? pdfLink) {
    return GestureDetector(
      onTap: () => showPdf(pdfLink ?? '', context),
      child: Container(
        height: 110,
        width: 110,
        child: const Center(
            child: Icon(
          Icons.picture_as_pdf_outlined,
          size: 45,
        )),
        decoration: BoxDecoration(
            color: Palette.imageBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 0.8, color: Colors.black, style: BorderStyle.solid)),
      ),
    );
  }

  GestureDetector _medicalFileDisplay(String _imageLink) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MedicalPhotoGallery(
                    medicalRecordFileList: _medicalRecordModel.recordFiles!
                        .where((element) => !isPdf(element.file!))
                        .toList(),
                  ))),
      child: Container(
        height: 110,
        width: 110,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.8, color: Colors.black, style: BorderStyle.solid)),
        child: CachedNetworkImage(
          color: Palette.imageBackground,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => circularLoading(),
          errorWidget: (context, url, error) => ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 45,
            ),
          ),
          fit: BoxFit.cover,
          imageUrl: _imageLink,
        ),
      ),
    );
  }

  void _toggleGeneralAccess(bool theBool, int _recordId, BuildContext ctx) async {
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      FormData body = FormData.fromMap({
        'record_id': _recordId,
        'the_bool': !theBool,
      });

      var _sharedWithResponse = await HttpService()
          .postRequest(data: body, endPoint: MEDICAL_RECORD_GENERAL_SHARE_HANDLER, isAuth: true);
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!_sharedWithResponse.error && _sharedWithResponse.data['message'] == 'success') {
        setState(() {
          _medicalRecordModel.generalAccess = !theBool;
        });
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

  void _addOrRemoveToShareWith(
      UserModel _userModel, String operation, int _recordId, BuildContext ctx) async {
    bool _isDialogRunning = false;
    if (_medicalRecordModel.relatedDoctor!.user!.id == _userModel.id && operation == 'remove') {
      infoNoOkDialogue(
          context,
          'By default, medical record is shared to related doctor. To remove or change the related doctor edit the medical record',
          'No Allowed');
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
      FormData body = FormData.fromMap({
        'record_id': _recordId,
        'doctor_id': _userModel.id,
        'operation': operation,
      });

      var _sharedWithResponse = await HttpService()
          .postRequest(data: body, endPoint: MEDICAL_RECORD_SHARE_HANDLER, isAuth: true);
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!_sharedWithResponse.error && _sharedWithResponse.data['message'] == 'success') {
        setState(() {
          if (operation == 'add') {
            _medicalRecordModel.sharedWith!.add(_userModel);
            _medicalRecordModel.myDoctors!.remove(_userModel);
          } else {
            _medicalRecordModel.sharedWith!.remove(_userModel);
            _medicalRecordModel.myDoctors!.add(_userModel);
          }
        });
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

  List<UserModel> _getMyDoctorSuggession(String query) {
    _isReverse = true;
    return List.of(_medicalRecordModel.myDoctors!).where((theVale) {
      final doctorName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return doctorName.contains(queryLower);
    }).toList();
  }
}
