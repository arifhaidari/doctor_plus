import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../models/models.dart';
import '../../providers/provider_list.dart';
import '../../pages/screens.dart';
// import '../../providers/provider_list.dart';
import '../../widgets/widgets.dart';
import '../../utils/utils.dart';

class FindDoctor extends StatefulWidget {
  const FindDoctor({Key? key}) : super(key: key);

  @override
  _FindDoctorState createState() => _FindDoctorState();
}

class _FindDoctorState extends State<FindDoctor> {
  final _locationSearchController = TextEditingController();
  final _querySearchController = TextEditingController();
  bool isSpecialityHorizontal = false;

  bool _isUnknownError = false;
  final bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final List<SpecialityCategoryModel> _specialityCategoryList = <SpecialityCategoryModel>[];
  final List<DoctorModel> _doctorTileList = <DoctorModel>[];
  List<DoctorModel> _doctorTileSubList = <DoctorModel>[];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    final _findDoctorPageData = await HttpService().getRequest(endPoint: FIND_DOCTOR_DATA);

    if (!_findDoctorPageData.error) {
      try {
        setState(() {
          if (_findDoctorPageData.data is List && _findDoctorPageData.data.length != 0) {
            if (_findDoctorPageData.data.length > 0) {
              // get doctor tile
              if (_findDoctorPageData.data[0]['top_doctors'].length > 0) {
                _findDoctorPageData.data[0]['top_doctors'].forEach((response) {
                  final theObject = DoctorModel.fromJson(response);
                  theObject.user?.avatar = theObject.user!.avatar != null
                      ? MEDIA_LINK_NO_SLASH + theObject.user!.avatar!
                      : theObject.user!.avatar;
                  _doctorTileList.add(theObject);
                });
                _doctorTileSubList =
                    _doctorTileList.length > 3 ? _doctorTileList.sublist(0, 2) : _doctorTileList;
              }

              // get speciality category
              _findDoctorPageData.data[0]['speciality_categories'].forEach((response) {
                final theObject = SpecialityCategoryModel.fromJson(response);
                _specialityCategoryList.add(theObject);
              });
              // sub lit of doctor tile list
            }
            _isLoading = false;
          }
        });
        // check city, district and profile picture
        // if ((DRAWER_DATA['city'] == null || DRAWER_DATA['city']) &&
        //     (DRAWER_DATA['district'] == null || DRAWER_DATA['district']) &&
        //     (DRAWER_DATA['avatar'] == null || DRAWER_DATA['avatar'])) {
        //   questionDialogue(
        //       context,
        //       'Please complete your profile. It will take a minute but it help us to prvide you best user experience, service and recommendations',
        //       'Complete Your Profile',
        //       () => Navigator.push(
        //           context, MaterialPageRoute(builder: (_) => PatientProfileSetting())));
        // }
      } catch (e) {
        // print('value of top_doctors1');
        // print(e);
        setState(() {
          _isLoading = false;
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

  List<CityModel> _getProvinceSuggestion(String query) => List.of(CITIES).where((theVale) {
        final rtlClinicName = theVale.rtlName;
        final clinicNameLower = theVale.name!.toLowerCase();
        final queryLower = query.toLowerCase();
        return clinicNameLower.contains(queryLower)
            ? clinicNameLower.contains(queryLower)
            : rtlClinicName!.contains(query);
      }).toList();

  void _markApptCompleted(String theCode) async {
    FormData body = FormData.fromMap({
      'appt_id': theCode,
    });

    final _apptResponse =
        await HttpService().postRequest(endPoint: APPT_CREATE_LIST, isAuth: true, data: body);
    if (!_apptResponse.error) {
      try {
        if (_apptResponse.data['message'] == 'success') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavScreen()));
          toastSnackBar('Appointment is completed successfully', lenghtShort: false);
        } else if (_apptResponse.data['message'] == 'not_yours') {
          infoNoOkDialogue(context, 'Time slot is not booked by your account!', 'Oops Error');
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } catch (e) {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      if (_apptResponse.errorMessage == NO_INTERNET_CONNECTION) {
        infoNoOkDialogue(
            context, GlobalVariable.INTERNET_ISSUE_CONTENT, GlobalVariable.INTERNET_ISSUE_TITLE);
      } else {
        infoNoOkDialogue(context, _apptResponse.errorMessage.toString(), 'Error Occured');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Find Doctor',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          elevation: 0.0,
          actions: [
            IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const ApptQrScanner()))
                      .then((value) {
                    if (value['is_success']) {
                      _markApptCompleted(value['the_code']);
                    } else {
                      toastSnackBar('Process was not successfull');
                    }
                  });
                }),
          ],
        ),
        drawer: const CustomDrawer(),
        body: Builder(
          builder: (BuildContext ctx) {
            if (_isLoading) {
              return const LoadingPlaceHolder();
            }
            if (_isUnknownError || _isConnectionError) {
              if (_isConnectionError) {
                return const ErrorPlaceHolder(
                    isStartPage: true,
                    errorTitle: GlobalVariable.INTERNET_ISSUE_TITLE,
                    errorDetail: GlobalVariable.INTERNET_ISSUE_CONTENT);
              } else {
                return ErrorPlaceHolder(
                  isStartPage: true,
                  errorTitle: GlobalVariable.UNEXPECTED_ERROR,
                  errorDetail: _errorMessage,
                );
              }
            }
            return SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        color: Palette.blueAppBar,
                        height: 100,
                        // height: mQuery.height * 0.10,
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: mQuery.width * 0.94,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                width: mQuery.width * 0.80,
                                child: Row(
                                  children: [
                                    _finderIcon(CupertinoIcons.location),
                                    Expanded(
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
                                            // onChanged: (theVal) {
                                            //   _getSearchedClinic(theVal, context);
                                            // },
                                            controller: _locationSearchController,
                                            decoration: _searchInputDecoration(
                                                'Search Province (Ex. Kabul)'),
                                          ),
                                          suggestionsCallback: _getProvinceSuggestion,
                                          itemBuilder: (context, CityModel? cityModel) => ListTile(
                                                leading: const CircleAvatar(
                                                  radius: 18,
                                                  child: Icon(Icons.location_on),
                                                  backgroundColor: Palette.blueAppBar,
                                                ),
                                                title: Text(cityModel!.name!),
                                              ),
                                          onSuggestionSelected: (CityModel? cityModel) {
                                            _locationSearchController.text = cityModel!.name!;
                                            // on selection add it to agument of search which a province argument
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                width: mQuery.width * 0.80,
                                child: Row(
                                  children: [
                                    _finderIcon(Icons.local_hospital_outlined),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _querySearchController,
                                        decoration: _searchInputDecoration(
                                            'Disease, Doctor, Clinics and Symptoms'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 5.0,
                                    minimumSize: const Size(270, 39),
                                    onPrimary: Colors.white,
                                    primary: Palette.blueAppBar,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0))),
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FilterDoctor(
                                                doctorModelList: const <DoctorModel>[],
                                                specialityCategoryList: _specialityCategoryList,
                                                query: _querySearchController.text,
                                                provinceName: _locationSearchController.text,
                                              )));
                                },
                                child: const Text(
                                  'Search Now',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, bottom: 0.0),
                        child: Text(
                          'Specialities',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _specialityListDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0, bottom: 8.0),
                          child: Text(
                            'View All',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 182,
                    child: ListView.builder(
                        itemCount: _specialityCategoryList.length,
                        padding: const EdgeInsets.all(10.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilterDoctor(
                                    doctorModelList: const <DoctorModel>[],
                                    specialityCategoryList: _specialityCategoryList,
                                    speciality: _specialityCategoryList[index],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ProfileAvatarCircle(
                                  imageUrl:
                                      MEDIA_LINK_NO_SLASH + _specialityCategoryList[index].icon!,
                                  radius: 95,
                                ),
                                Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    width: 115,
                                    child: Text(
                                      _specialityCategoryList[index].name ?? 'Uknown Speciality',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14),
                                      // minFontSize: 10,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ))
                              ],
                            ),
                          );
                        }),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Palette.scaffoldBackground, borderRadius: BorderRadius.circular(30)),
                    // topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0, bottom: 0.0),
                              child: Text(
                                'Top Doctors',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (_doctorTileSubList.isNotEmpty)
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FilterDoctor(
                                      doctorModelList: _doctorTileList,
                                      specialityCategoryList: _specialityCategoryList,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0, bottom: 8.0),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[900]),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_doctorTileSubList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            child: const Center(
                              child: Text('There is no doctor available',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        if (_doctorTileSubList.isNotEmpty)
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _doctorTileSubList.length,
                              padding: const EdgeInsets.all(10.0),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return DoctorTile(
                                  doctorModel: _doctorTileSubList[index],
                                  userAvatar: _doctorTileSubList[index].user!.avatar!,
                                );
                              }),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  _specialityListDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
            child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Palette.blueAppBar,
            child: const Icon(Icons.clear),
          ),
          body: Container(
              alignment: Alignment.topCenter,
              // decoration:
              //     BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 5.0,
                      runSpacing: 5.0,
                      children: [
                        ..._specialityCategoryList
                            .map((specialityCategoryModel) => GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FilterDoctor(
                                        doctorModelList: const <DoctorModel>[],
                                        specialityCategoryList: _specialityCategoryList,
                                        speciality: specialityCategoryModel,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ProfileAvatarCircle(
                                        imageUrl:
                                            MEDIA_LINK_NO_SLASH + specialityCategoryModel.icon!,
                                        radius: 95,
                                      ),
                                      Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          width: 115,
                                          child: Text(
                                            specialityCategoryModel.name ?? 'Uknown Speciality',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 14),
                                            // minFontSize: 10,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ))
                                    ],
                                  ),
                                ))
                            .toList()
                      ],
                    ),
                  ],
                ),
              )),
        ));
      },
    );
  }

  InputDecoration _searchInputDecoration(String theHint) {
    return InputDecoration(
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(10),
      filled: true,
      hintText: theHint,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Colors.grey[500]),
    );
  }

  Card _finderIcon(IconData theIcon) {
    return Card(
      elevation: 3.0,
      // color: Palette.lighterBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: Container(
        decoration: const BoxDecoration(color: Palette.lighterBlue, shape: BoxShape.circle),
        // color: ,
        height: 38,
        width: 38,
        child: Icon(
          theIcon,
          color: Colors.grey,
          size: 30,
        ),
      ),
    );
  }
}
