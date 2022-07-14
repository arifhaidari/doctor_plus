// ignore_for_file: empty_catches

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/models.dart';
import '../../pages/screens.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class EditMedicalRecord extends StatefulWidget {
  final MedicalRecordModel medicalRecordModel;
  const EditMedicalRecord({Key? key, required this.medicalRecordModel}) : super(key: key);

  @override
  _EditMedicalRecordState createState() => _EditMedicalRecordState();
}

class _EditMedicalRecordState extends State<EditMedicalRecord> {
  final List<String> _patientList = ['Select Patient', 'Me'];
  final List<String>? _filePaths = <String>[];
  final List<int>? _deletedFiles = <int>[];

  final _searchMyDoctorController = TextEditingController();
  final _searchRelatedDoctorController = TextEditingController();
  final _recordTitleController = TextEditingController();
  CreateMedicalRecordDataModel _createMedicalRecordDataModel = CreateMedicalRecordDataModel();
  List<UserModel> _sharedWithDoctorList = <UserModel>[];
  final List<UserModel> _relatedDoctorCollection = <UserModel>[];
  UserModel? _relatedDoctor;

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  bool isFormError = false;
  String _errorMessage = '';
  String _formErrorMessage = '';
  String _defaultPatient = 'Select Patient';
  bool _selectedPatinetFileShare = DRAWER_DATA['share_record_to_all'];
  bool _shareWithAll = true;

  @override
  void initState() {
    super.initState();
    _setLocalData();
    _getData();
  }

  void _setLocalData() {
    // _localFilePaths = widget.medicalRecordModel.recordFiles!.map((e) => e.file!).toList();
    _searchRelatedDoctorController.text = widget.medicalRecordModel.relatedDoctor!.user!.name!;
    _recordTitleController.text = widget.medicalRecordModel.title!;
    _sharedWithDoctorList = widget.medicalRecordModel.sharedWith!;
    _relatedDoctor = widget.medicalRecordModel.relatedDoctor!.user;
    _shareWithAll = widget.medicalRecordModel.generalAccess!;
    _selectedPatinetFileShare = widget.medicalRecordModel.patient!.shareRecordToAll!;
    _defaultPatient = widget.medicalRecordModel.patient!.user!.name! == DRAWER_DATA['full_name']
        ? 'Me'
        : widget.medicalRecordModel.patient!.user!.name!;
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    final _medicalRecordDataResponse =
        await HttpService().getRequest(endPoint: CREATE_MEDICAL_RECORD_DATA, isAuth: true);

    if (!_medicalRecordDataResponse.error) {
      try {
        setState(() {
          _createMedicalRecordDataModel =
              CreateMedicalRecordDataModel.fromJson(_medicalRecordDataResponse.data);

          _relatedDoctorCollection.addAll(_createMedicalRecordDataModel.myDoctors!);
          _createMedicalRecordDataModel.myDoctors = _createMedicalRecordDataModel.myDoctors!
              .where((element) => !_isContain(element.id!))
              .toList();
          _patientList.addAll(
              _createMedicalRecordDataModel.myRelatives!.map((e) => e.user!.name!).toList());

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
        if (_medicalRecordDataResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _medicalRecordDataResponse.errorMessage!;
        }
      });
    }
  }

  bool _isContain(int userId) {
    final result = _sharedWithDoctorList.firstWhere((element) => element.id == userId,
        orElse: () => UserModel(id: null));
    if (result.id != null) {
      return true;
    }
    return false;
  }

  bool _isReverse = false;

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        _isReverse = false;
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          backgroundColor: Palette.scaffoldBackground,
          appBar: AppBar(
            title: const Text(
              'Edit Record',
              style: TextStyle(
                  fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Palette.blueAppBar,
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
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  reverse: _isReverse,
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(spacing: 8.0, runSpacing: 5.0, direction: Axis.horizontal, children: [
                        ...widget.medicalRecordModel.recordFiles!
                            .map(
                              (e) => GestureDetector(
                                  onTap: () => isPdf(e.file!) ? showPdf(e.file!, context) : null,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 110,
                                        width: 110,
                                        child: isPdf(e.file!)
                                            ? const Center(
                                                child: Icon(
                                                Icons.picture_as_pdf_outlined,
                                                size: 45,
                                              ))
                                            : CachedNetworkImage(
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
                                                    Icons.image_outlined,
                                                    size: 45,
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                                imageUrl: e.file ?? '',
                                              ),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: isPdf(e.file!) ? Palette.imageBackground : null,
                                            border: Border.all(
                                                width: 0.8,
                                                color: Colors.black,
                                                style: BorderStyle.solid)),
                                      ),
                                      Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                              icon: const Icon(
                                                CupertinoIcons.clear_circled_solid,
                                                color: Palette.umber,
                                                size: 25,
                                              ),
                                              onPressed: () => _removePreviousRecord(e)))
                                    ],
                                  )),
                            )
                            .toList(),
                        ..._filePaths!
                            .map(
                              (e) => GestureDetector(
                                  onTap: () =>
                                      isPdf(e) ? showPdf(e, context, operation: 'asset') : null,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 110,
                                        width: 110,
                                        child: isPdf(e)
                                            ? const Center(
                                                child: Icon(
                                                Icons.picture_as_pdf_outlined,
                                                size: 45,
                                              ))
                                            : null,
                                        decoration: BoxDecoration(
                                            image: isPdf(e)
                                                ? null
                                                : DecorationImage(
                                                    image: FileImage(File(e)), fit: BoxFit.cover),
                                            borderRadius: BorderRadius.circular(8),
                                            color: isPdf(e) ? Palette.imageBackground : null,
                                            border: Border.all(
                                                width: 0.8,
                                                color: Colors.black,
                                                style: BorderStyle.solid)),
                                      ),
                                      Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                              icon: const Icon(
                                                CupertinoIcons.clear_circled_solid,
                                                // color: Colors.white,
                                                color: Palette.umber,
                                                size: 25,
                                              ),
                                              onPressed: () => _removeFileFromList(e)))
                                    ],
                                  )),
                            )
                            .toList(),
                        GestureDetector(
                          onTap: () {
                            _showModalBottomSheet();
                          },
                          child: Container(
                            height: 110,
                            width: 110,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.blue[900],
                                  ),
                                  const Text('+'),
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.blue[900],
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    width: 0.8, color: Colors.black, style: BorderStyle.solid)),
                          ),
                        ),
                      ]),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: mQuery.width * 0.85,
                        child: dashedLine(Palette.blueAppBar),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        width: mQuery.width * 0.83,
                        height: 50.0,
                        child: TextFormField(
                          controller: _recordTitleController,
                          decoration: textFieldDesign(context, 'Title'),
                        ),
                      ),
                      _infoDropdown(_patientList, _defaultPatient, 'patient', mQuery),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        width: mQuery.width * 0.85,
                        height: 60,
                        child: Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: TypeAheadFormField<UserModel?>(
                              loadingBuilder: (context) => circularLoading(),
                              noItemsFoundBuilder: (context) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'No Doctor Found',
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                  ),
                                );
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _searchRelatedDoctorController,
                                decoration: textFieldDesign(context, 'Select Related Doctor',
                                    isIcon: true,
                                    theTextController: _searchRelatedDoctorController),
                              ),
                              suggestionsCallback: _getRelatedDoctorSuggession,
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
                                _relatedDoctor = userModel;
                                _sharedWithDoctorList
                                    .removeWhere((element) => userModel!.id == element.id);
                                _searchRelatedDoctorController.text = userModel!.name!;
                              }),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 5, left: 5),
                        width: mQuery.width * 0.85,
                        child: const Text(
                          'Share With Doctors:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      if (_selectedPatinetFileShare)
                        SizedBox(
                          width: mQuery.width * 0.90,
                          child: const ListTile(
                            title: Text(
                              'by default we share your medical record with all those doctors which you have booked or completed appts.',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                            subtitle: Text(
                                'To change the default, go to settings and change the default sharing file for all doctors'),
                          ),
                        ),
                      if (!_selectedPatinetFileShare)
                        SizedBox(
                          width: mQuery.width * 0.90,
                          child: Row(
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
                                  value: _shareWithAll,
                                  onToggle: (val) {
                                    setState(() {
                                      _shareWithAll = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!_selectedPatinetFileShare && !_shareWithAll)
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 10),
                              width: mQuery.width * 0.85,
                              height: 60,
                              child: Card(
                                elevation: 2.0,
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                      decoration: textFieldDesign(
                                          context, 'Select Doctors To Share',
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
                                      _addOrRemoveDoctor(userModel!, 'add', 'shared_doctor');
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
                                    if (_sharedWithDoctorList.isEmpty)
                                      const Center(
                                        child: Text(
                                          'Only Shared With Related Doctor',
                                          style:
                                              TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ..._sharedWithDoctorList.map((e) {
                                      return InputChip(
                                        label: Text(e.name!),
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        elevation: 5.0,
                                        deleteIconColor: Colors.white,
                                        // avatar: Icon(Icons.local_hospital),
                                        backgroundColor: Palette.blueAppBar,
                                        onDeleted: () =>
                                            _addOrRemoveDoctor(e, 'remove', 'shared_doctor'),
                                      );
                                    }).toList(),
                                  ]),
                            ),
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
                        height: 15,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            minimumSize: const Size(280, 42),
                            onPrimary: Colors.white,
                            primary: Palette.blueAppBar,
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                        onPressed: () => _submitData(context),
                        child: const Text(
                          'Save Record',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  FilePickerResult? fileResult;
  List<File>? _files = <File>[];

  Future<void> _getImageFile(String operation) async {
    try {
      if (operation == 'gallery') {
        fileResult = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
      } else {
        fileResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: true,
          allowedExtensions: ["pdf"],
        );
      }
      if (fileResult != null) {
        setState(() {
          for (var element in fileResult!.paths) {
            _filePaths!.add(element!);
          }
        });
      }
    } catch (e) {}
  }

  Future _getCameraImage(BuildContext ctx) async {
    try {
      PickedFile? _imagePickedFile;
      File? _image;
      final picker = ImagePicker();
      _imagePickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 85,
        // maxHeight: 300,
        // maxWidth: 300,
      );

      // add to file list
      setState(() {
        _image = File(_imagePickedFile!.path);
        _filePaths!.add(_image!.path);
      });
    } catch (e) {}
  }

  void _submitData(BuildContext ctx) async {
    bool _isDialogRunning = false;
    // create body
    if (!_isFormOkay()) {
      setState(() {
        isFormError = true;
      });
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
      _files = (_filePaths!.isEmpty || _filePaths == null)
          ? <File>[]
          : _filePaths!.map((path) => File(path)).toList();
      FormData _theBody = FormData.fromMap({
        'file': [
          ..._files!.map((e) => MultipartFile.fromFileSync(
                e.path,
                filename: e.path.split('/').last,
              ))
        ],
        'removed_files': _deletedFiles,
        'operation': 'edit',
        'title': _recordTitleController.text,
        'record_id': widget.medicalRecordModel.id,
        'patient': _defaultPatient,
        'related_doctor': _relatedDoctor!.id,
        'is_shared_to_all': _selectedPatinetFileShare ? true : (_shareWithAll ? true : false),
        'shared_with': _sharedWithDoctorList.map((e) => e.id).toList(),
      });

      var editResponse = await HttpService().postRequest(
        data: _theBody,
        isAuth: true,
        endPoint: CREATE_MEDICAL_RECORD_DATA,
      );
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!editResponse.error) {
        if (editResponse.data['message'] == 'success') {
          Navigator.of(context).pop();
          toastSnackBar('Saved Successfully');
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
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

  void _removeFileFromList(String thePath) {
    setState(() {
      _filePaths!.remove(thePath);
    });
  }

  void _removePreviousRecord(MedicalRecordFileModel theFile) {
    _deletedFiles!.add(theFile.id!);
    setState(() {
      widget.medicalRecordModel.recordFiles!.remove(theFile);
    });
  }

  bool _isFormOkay() {
    if (_defaultPatient == 'Select Patient') {
      _formErrorMessage = 'Select a patient';
      return false;
    }
    if (_recordTitleController.text == '') {
      _formErrorMessage = 'Title of medical recrod is required';
      return false;
    }
    if (_searchRelatedDoctorController.text == '' || _relatedDoctor == null) {
      _formErrorMessage = 'Related doctor is required';
      return false;
    }
    if (_filePaths!.isEmpty && widget.medicalRecordModel.recordFiles!.isEmpty) {
      _formErrorMessage = 'Import at least one file for this medical record';
      return false;
    }
    if (!_selectedPatinetFileShare && !_shareWithAll && _relatedDoctor == null) {
      _formErrorMessage = 'You did not select any doctor to share medical record with!';
      return false;
    }
    return true;
  }

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
                      _getCameraImage(context);
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
                      _getImageFile('gallery');
                    },
                    horizontalTitleGap: 0,
                    minLeadingWidth: 35,
                    leading: const Icon(
                      MdiIcons.viewGalleryOutline,
                      color: Palette.blueAppBar,
                    ),
                    title: const Text('Gallery'),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      _getImageFile('file');
                    },
                    horizontalTitleGap: 0,
                    minLeadingWidth: 35,
                    leading: const Icon(
                      Icons.drive_file_move_outline,
                      color: Palette.blueAppBar,
                    ),
                    title: const Text('File'),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          );
        });
  }

  void _addOrRemoveDoctor(UserModel userModel, String operation, String theType) {
    setState(() {
      if (operation == 'add') {
        if (_relatedDoctor!.id == userModel.id) {
          toastSnackBar('Already shared, as it is related doctor', lenghtShort: false);
          return;
        }
        _createMedicalRecordDataModel.myDoctors!.remove(userModel);
        _sharedWithDoctorList.add(userModel);
      } else {
        _sharedWithDoctorList.remove(userModel);
        _createMedicalRecordDataModel.myDoctors!.add(userModel);
      }
    });
  }

  List<UserModel> _getRelatedDoctorSuggession(String query) {
    _isReverse = true;
    return List.of(_relatedDoctorCollection).where((theVale) {
      final doctorName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return doctorName.contains(queryLower);
    }).toList();
  }

  List<UserModel> _getMyDoctorSuggession(String query) {
    _isReverse = false;
    return List.of(_createMedicalRecordDataModel.myDoctors!).where((theVale) {
      final doctorName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return doctorName.contains(queryLower);
    }).toList();
  }

  Widget _infoDropdown(theList, defaultVal, dropType, mQuery) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: mQuery.width * 0.83,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
        style: const TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w500),
        dropdownColor: Palette.imageBackground,
        underline: const SizedBox.shrink(),
        onChanged: (String? newValue) {
          setState(() {
            // if (dropType == 'patient') {
            _defaultPatient = newValue!;
            if (newValue != 'Me' || newValue != 'Select Patient') {
              final _isShareToAll = _createMedicalRecordDataModel.myRelatives!.firstWhere(
                  (element) => element.user!.name == newValue,
                  orElse: () => PatientModel(shareRecordToAll: true));
              //
              _selectedPatinetFileShare = _isShareToAll.shareRecordToAll!;
            } else {
              _selectedPatinetFileShare = DRAWER_DATA['share_record_to_all'];
            }
            // } else {
            //   _defaultRecordType = newValue!;
            // }
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
}
