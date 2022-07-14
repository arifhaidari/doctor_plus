import 'dart:io';
import 'package:dio/dio.dart';
import 'package:doctor_plus/models/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import '../../widgets/widgets.dart';
import '../screens.dart';

class PatientProfileSetting extends StatefulWidget {
  const PatientProfileSetting({Key? key}) : super(key: key);

  @override
  _PatientProfileSettingState createState() => _PatientProfileSettingState();
}

class _PatientProfileSettingState extends State<PatientProfileSetting> {
  final dateFormatterPattern = DateFormat("yyyy-MM-dd");

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rtlNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  String _defaultBloodGroup = 'Blood Group';
  String _defaultGender = 'Male';
  String _errorMessage = '';
  String _formErrorMessage = '';
  String _theAvatar = '';

  File? _image;
  final picker = ImagePicker();
  late final ImageProvider _theImage;
  List<DistrictModel> _districtList = <DistrictModel>[];
  PatientModel? _patientModel;

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  bool _isUpdated = false;
  bool _isSharedToAll = false;
  bool _isReverse = false;

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  void _getInitialData() async {
    setState(() {
      _isLoading = true;
    });
    final _patientProfileResponse =
        await HttpService().getRequest(endPoint: PATIENT_PROFILE_SETTING, isAuth: true);

    if (!_patientProfileResponse.error) {
      try {
        setState(() {
          _patientModel = PatientModel.fromJson(_patientProfileResponse.data);
          _theImage = (_patientModel!.user!.avatar == null || _patientModel!.user!.avatar == '')
              ? AssetImage(_patientModel!.user!.gender == 'Male'
                  ? GlobalVariable.MALE_ICON
                  : GlobalVariable.FEMALE_ICON)
              : NetworkImage(MEDIA_LINK_NO_SLASH + _patientModel!.user!.avatar!) as ImageProvider;

          _nameController.text = _patientModel!.user!.name ?? "";
          _rtlNameController.text = _patientModel!.user!.rtlName ?? "";
          _dobController.text = _patientModel!.user!.dob ?? "";
          _defaultBloodGroup = _patientModel!.bloodGroup ?? 'Blood Group';
          _defaultGender = _patientModel!.user!.gender ?? 'Male';
          _isSharedToAll = _patientModel!.shareRecordToAll ?? true;
          _patientProfileResponse.data['district_list'].forEach((element) {
            _districtList.add(DistrictModel.fromJson(element));
          });
          _cityController.text = _patientProfileResponse.data['selected_city'];
          _districtController.text = _patientProfileResponse.data['selected_district'];
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
        if (_patientProfileResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _patientProfileResponse.errorMessage!;
        }
      });
    }
  }

  List<CityModel> getCitySuggessions(String query) {
    _isReverse = true;
    return List.of(CITIES).where((theVale) {
      final cityName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return cityName.contains(queryLower);
    }).toList();
  }

  List<DistrictModel> getDistrictSuggessions(String query) {
    _isReverse = true;
    return List.of(_districtList).where((theVale) {
      final districtName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return districtName.contains(queryLower);
    }).toList();
  }

  void _theSetState(String theMessage) {
    setState(() {
      _formErrorMessage = theMessage;
    });
  }

  void _createDistrictOptionalList(CityModel _cityModel) async {
    final _districtResponse = await HttpService()
        .getRequest(endPoint: PATIENT_DISTRICT_LIST + "?q=${_cityModel.id}", isAuth: true);

    if (!_districtResponse.error) {
      _districtList = [];
      try {
        setState(() {
          _districtController.text = '';
          _districtResponse.data.forEach((element) {
            _districtList.add(DistrictModel.fromJson(element));
          });
        });
      } catch (e) {
        infoNoOkDialogue(
            context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

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
            leading: IconButton(
              icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
              onPressed: () {
                // if it is changed then we send the value other wise we do not
                Map<String, dynamic> theMapData = {
                  'is_changed': _isUpdated,
                };
                if (_isUpdated) {
                  theMapData['name'] = _nameController.text;
                  theMapData['blood_group'] = _defaultBloodGroup;
                  theMapData['avatar_link'] = _theAvatar;
                  theMapData['is_shared_to_all'] = _isSharedToAll;
                  theMapData['city'] = _cityController.text;
                  theMapData['district'] = _districtController.text;
                }

                Navigator.of(context).pop(theMapData);
              },
            ),
            backgroundColor: Palette.blueAppBar,
            title: const Text(
              'Profile Setting',
              style: TextStyle(
                  fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
            ),
          ),
          body: Builder(
            builder: (ctx) {
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
                reverse: _isReverse,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(top: 10),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: mQuery.width * 0.95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _userProfile(),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: mQuery.width * 0.80,
                                  height: 50.0,
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: textFieldDesign(context, 'Full Name'),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: mQuery.width * 0.80,
                                  height: 50.0,
                                  child: TextFormField(
                                    controller: _rtlNameController,
                                    decoration: textFieldDesign(context, 'Full Name (Pashto/Dari)'),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: mQuery.width * 0.80,
                                  child: TypeAheadFormField<CityModel?>(
                                      loadingBuilder: (context) => circularLoading(),
                                      noItemsFoundBuilder: (context) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'No Province Found',
                                            style: TextStyle(
                                                fontSize: 16.0, fontWeight: FontWeight.w400),
                                          ),
                                        );
                                      },
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: _cityController,
                                        decoration: textFieldDesign(context, 'Select Province',
                                            isIcon: true, theTextController: _cityController),
                                      ),
                                      suggestionsCallback: getCitySuggessions,
                                      itemBuilder: (context, CityModel? cityName) => ListTile(
                                            title: Text(cityName!.name!),
                                          ),
                                      onSuggestionSelected: (CityModel? cityName) {
                                        _cityController.text = cityName!.name!;
                                        _createDistrictOptionalList(cityName);
                                      }),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: mQuery.width * 0.80,
                                  child: TypeAheadFormField<DistrictModel?>(
                                      loadingBuilder: (context) => circularLoading(),
                                      noItemsFoundBuilder: (context) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'No District Found',
                                            style: TextStyle(
                                                fontSize: 16.0, fontWeight: FontWeight.w400),
                                          ),
                                        );
                                      },
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: _districtController,
                                        decoration: textFieldDesign(context, 'Select District',
                                            isIcon: true, theTextController: _districtController),
                                      ),
                                      suggestionsCallback: getDistrictSuggessions,
                                      itemBuilder: (context, DistrictModel? districtModel) =>
                                          ListTile(
                                            title: Text(districtModel!.name!),
                                          ),
                                      onSuggestionSelected: (DistrictModel? districtModel) {
                                        _districtController.text = districtModel!.name!;
                                      }),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: mQuery.width * 0.80,
                                  height: 50.0,
                                  child: DateTimeField(
                                    controller: _dobController,
                                    decoration: textFieldDesign(context, 'Date Of Birth'),
                                    format: dateFormatterPattern,
                                    onShowPicker: (context, currentValue) {
                                      return showDatePicker(
                                          context: context,
                                          firstDate: DateTime(1945),
                                          initialDate: currentValue ?? DateTime.now(),
                                          lastDate: DateTime.now());
                                    },
                                  ),
                                ),
                                Container(
                                  width: mQuery.width * 0.80,
                                  margin: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _infoDropdown(GlobalDummyData.BLOOD_GROUP_LIST,
                                          _defaultBloodGroup, 'blood_group'),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      _infoDropdown(
                                          GlobalDummyData.GENDER_LIST, _defaultGender, 'gender'),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: mQuery.width * 0.80,
                                  margin: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                          child: Text(
                                              'Share Medical Record With All Doctors Which You Have Booked or Completed Appts.',
                                              style: TextStyle(
                                                  fontSize: 13, fontWeight: FontWeight.w400))),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5.0),
                                        child: FlutterSwitch(
                                          activeColor: Palette.blueAppBar,
                                          width: 50.0,
                                          height: 25.0,
                                          value: _isSharedToAll,
                                          onToggle: (val) {
                                            setState(() {
                                              _isSharedToAll = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_formErrorMessage != '')
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    width: mQuery.width * 0.80,
                                    padding: const EdgeInsets.symmetric(horizontal: 25),
                                    child: Text(
                                      _formErrorMessage,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                customElevatedButton(context, () {
                                  _updatePatientProfile(context);
                                }, 'Save'),
                                const SizedBox(
                                  height: 8.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Expanded _infoDropdown(theList, defaultVal, dropType) {
    return Expanded(
      child: Container(
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
          style: const TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w500),
          dropdownColor: Palette.imageBackground,
          underline: const SizedBox.shrink(),
          onChanged: (String? newValue) {
            setState(() {
              if (dropType == 'blood_group') {
                _defaultBloodGroup = newValue!;
              } else {
                _defaultGender = newValue!;
              }
            });
          },
          items: theList.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
                value: dropType == 'title' ? value.title : value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    dropType == 'title' ? value.title : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ));
          }).toList(),
        ),
      ),
    );
  }

  Future getImage(String mediaType) async {
    PickedFile? pickedFile;
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
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Card _userProfile() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      elevation: 10.0,
      child: GestureDetector(
        onTap: () {
          _showModalBottomSheet();
        },
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: _image != null
                ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                : DecorationImage(image: _theImage, fit: BoxFit.cover),
            color: Colors.white,
            border: Border.all(color: Palette.blueAppBar, width: 2.5),
          ),
          child: Align(
            alignment: const Alignment(1.1, 1.1),
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: Palette.blueAppBar,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    )),
                padding: const EdgeInsets.all(5.0),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
                      getImage('camera');
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
                      getImage('gallery');
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

  Future<void> _updatePatientProfile(BuildContext ctx) async {
    bool _isDialogRunning = false;
    final isFormValid = _formValidation();

    if (!isFormValid) {
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
      Map<String, int> _theMap = _validateCityDistrict();
      String avatarName = 'no_avatar';
      if (_image != null) {
        avatarName = _image!.path.split('/').last;
      }
      FormData body = FormData.fromMap({
        'name': _nameController.text,
        'rtl_name': _rtlNameController.text,
        'city_id': _theMap['city'],
        'district_id': _theMap['district'],
        'dob': _dobController.text,
        'blood_group': _defaultBloodGroup,
        'gender': _defaultGender,
        'is_shared_to_all': _isSharedToAll,
        'avatar': avatarName == 'no_avatar'
            ? 'no_avatar'
            : await MultipartFile.fromFile(
                _image!.path,
                filename: avatarName,
              ),
      });

      var profileSettingResponse = await HttpService()
          .postRequest(data: body, endPoint: PATIENT_PROFILE_SETTING, isAuth: true);
      Navigator.of(ctx).pop();
      _isDialogRunning = false;
      if (!profileSettingResponse.error) {
        if (profileSettingResponse.data['message'] == 'success') {
          _isUpdated = true;
          _theAvatar = profileSettingResponse.data['avatar'] ?? '';
          // update the shared preference
          Map<String, dynamic> briefMap = {
            "id": DRAWER_DATA['id'],
            "full_name": _nameController.text,
            "rtl_full_name": _rtlNameController.text,
            "share_record_to_all": _isSharedToAll,
            "phone": DRAWER_DATA['phone'],
            "gender": _defaultGender,
            "avatar": _theAvatar,
            "patient_completed_appt_no": DRAWER_DATA['patient_completed_appt_no'].toString(),
            "relative_completed_appt_no": DRAWER_DATA['relative_completed_appt_no'].toString(),
          };
          SharedPref().dashboardBriefSetter(briefMap);
          toastSnackBar('Updated Successfully');
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      print('value of erorororo');
      print(e);
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }

    //
  }

  Map<String, int> _validateCityDistrict() {
    final cityObject = CITIES.firstWhere((element) => element.name == _cityController.text,
        orElse: () => CityModel(id: 0));
    final districtObject = _districtList.firstWhere(
        (element) => element.name == _districtController.text,
        orElse: () => DistrictModel(id: 0));

    Map<String, int> theMap = {
      'city': cityObject.id ?? 0,
      'district': districtObject.id ?? 0,
    };
    return theMap;
  }

  bool _formValidation() {
    Map<String, int> _theMap = _validateCityDistrict();
    _theSetState('');
    if (_defaultBloodGroup == 'Blood Group') {
      _theSetState('Select a blood group');
      return false;
    }
    if (_nameController.text.trim() == '') {
      _theSetState('Please enter your name');
      return false;
    }
    if (_rtlNameController.text.trim() == '') {
      _theSetState('Please enter your name (Pashto/Dari)');
      return false;
    }

    if (_cityController.text.trim() == '') {
      _theSetState('Please select a city');
      return false;
    }

    if (_theMap['city'] == 0) {
      _theSetState('Please select a city from suggesstion with correct spelling');
      return false;
    }

    if (_districtController.text.trim() == '') {
      _theSetState('Please select a district');
      return false;
    }

    if (_theMap['district'] == 0) {
      _theSetState('Please select a district from suggesstion with correct spelling');
      return false;
    }

    if (_dobController.text == '') {
      _theSetState('Please Enter date of birth');
      return false;
    }

    // do validation of the image right here
    return true;
  }
}
