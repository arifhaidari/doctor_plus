import '../../providers/provider_list.dart';

import '../../models/models.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class PatientProfile extends StatefulWidget {
  final int patientId;
  final bool isPatient;
  const PatientProfile({Key? key, required this.patientId, this.isPatient = true})
      : super(key: key);
  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  int tabIndex = 0;
  PatientModel? _patientModel;
  //
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _getData(widget.isPatient ? 'Me' : 'All');
  }

  Future<void> _getData(String sortingKey) async {
    setState(() {
      _isLoading = true;
    });
    final patientProfileResponse = await HttpService().getRequest(
        endPoint: PATIENT_RELATIVE_PROFILE + "${widget.patientId}/?q=$sortingKey", isAuth: true);

    if (!patientProfileResponse.error) {
      try {
        setState(() {
          _patientModel = PatientModel.fromJson(patientProfileResponse.data);
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Palette.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              widget.isPatient ? "My Profile" : "Relative Profile",
              style: const TextStyle(
                  fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Palette.blueAppBar,
            actions: [
              if (tabIndex == 0 && widget.isPatient)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const PatientProfileSetting()))
                              .then((value) {
                            if (value['is_changed']) {
                              setState(() {
                                _patientModel!.bloodGroup = value['blood_group'];
                                _patientModel!.user!.name = value['name'];
                                _patientModel!.user!.avatar = value['avatar_link'];
                                _patientModel!.user!.address!.city!.name = value['city'];
                                _patientModel!.user!.address!.district!.name = value['district'];
                                _patientModel!.shareRecordToAll = value['is_shared_to_all'];
                              });
                            }
                          })),
                ),
            ],
            bottom: TabBar(
              onTap: (value) => _activeTab(value),
              // isScrollable: true,
              unselectedLabelColor: Colors.yellowAccent,
              labelColor: Palette.blueAppBar,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: Palette.tabGradient,
                // color: Colors.white,
                color: Palette.scaffoldBackground,
              ),
              tabs: [
                patientProfileTab('Overview'),
                patientProfileTab('Appts'),
                patientProfileTab('Records'),
              ],
            ),
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
              return TabBarView(
                // physics: NeverScrollableScrollPhysics(),
                children: [
                  PatientOverview(
                    isPatient: widget.isPatient,
                    patientModel: _patientModel ?? PatientModel(user: UserModel(id: null)),
                  ),

                  PatientApptSlot(
                    isPatient: widget.isPatient,
                    patient: _patientModel ?? PatientModel(user: UserModel(id: null)),
                  ),
                  MedicalRecord(
                    patient: _patientModel ?? PatientModel(user: UserModel(id: null)),
                    isPatient: widget.isPatient,
                  ),
                  // FamilyMember(),
                ],
              );
            },
          )),
    );
  }

  void _activeTab(int index) {
    setState(() {
      tabIndex = index;
    });
  }
}
