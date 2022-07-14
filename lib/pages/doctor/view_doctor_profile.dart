import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/models.dart';
import '../../pages/screens.dart';
import '../../providers/provider_list.dart';
import '../../widgets/widgets.dart';
import '../../utils/utils.dart';
import 'package:flutter/material.dart';

class ViewDoctorProfile extends StatefulWidget {
  final int doctorId;
  const ViewDoctorProfile({Key? key, required this.doctorId}) : super(key: key);

  @override
  _ViewDoctorProfileState createState() => _ViewDoctorProfileState();
}

class _ViewDoctorProfileState extends State<ViewDoctorProfile> {
  DoctorModel? _doctorModel;
  FeedbackDataModel? _feedbackDataModel;
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  bool _isFavoiteDoctor = false;
  bool _isCompletedApptThere = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    final _doctorProfileInfo = await HttpService()
        .getRequest(endPoint: VIEW_DOCTOR_PROFILE_PLUS + "${widget.doctorId}/", isAuth: true);

    if (!_doctorProfileInfo.error) {
      try {
        setState(() {
          _doctorModel = DoctorModel.fromJson(_doctorProfileInfo.data['doctor_object']);
          _isCompletedApptThere = _doctorProfileInfo.data['is_completed_appt_there'];
          print('value fo _doctorModel.user.phone');
          print(_doctorModel!.user!.phone);
          _feedbackDataModel = FeedbackDataModel.fromJson(_doctorProfileInfo.data['feedback_data']);

          final isfavoriteExist = _feedbackDataModel!.favoiteDoctorList!
              .firstWhere((element) => element == _doctorModel!.user!.id, orElse: () => 0);
          if (isfavoriteExist != 0) {
            _isFavoiteDoctor = true;
          }
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
        if (_doctorProfileInfo.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _doctorProfileInfo.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        body: Builder(
          builder: (BuildContext ctx) {
            if (_isLoading) {
              return const LoadingPlaceHolderPage();
            }
            if (_isUnknownError || _doctorModel == null || _isConnectionError) {
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
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  // title: Text('Doctor Name'),
                  elevation: 0,
                  pinned: true,
                  // snap: true,
                  floating: true,
                  expandedHeight: 80.0,
                  backgroundColor: Palette.blueAppBar,
                  // collapsedHei3511
                  //ght: ,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _doctorModel!.user!.name ?? 'Uknown Doctor',
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                    ),
                    // background:
                  ),
                ),
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 130,
                            color: Palette.blueAppBar,
                          ),
                          Container(
                            height: 95,
                            decoration: const BoxDecoration(
                                color: Colors.transparent,
                                // color: Palette.red,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                          )
                        ],
                      ),
                      _profileAvatar(mQuery),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // if (index == 0) {
                      //   return
                      // }
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                theCircularIndicator(
                                  icon: Icons.star,
                                  text: "Overall\nExperience",
                                  thePercentage: _feedbackDataModel!.overallExperience ?? 35.0,
                                ),
                                theCircularIndicator(
                                  icon: Icons.local_hospital,
                                  text: "Doctor\nCheckup",
                                  thePercentage: _feedbackDataModel!.doctorCheckup ?? 35.0,
                                ),
                                theCircularIndicator(
                                  icon: Icons.people,
                                  text: "Staff\nBehavior",
                                  thePercentage: _feedbackDataModel!.staffBehavior ?? 35.0,
                                ),
                                theCircularIndicator(
                                  icon: Icons.clean_hands,
                                  text: "Clinic\nEnvironment",
                                  thePercentage: _feedbackDataModel!.clinicEnvironment ?? 35.0,
                                ),
                              ],
                            ),
                          ),
                          _customDivider(),
                          _mapAddress(_doctorModel!),
                          const Divider(),
                          _careServiceItem(mQuery, 'Specialities', _doctorModel!),
                          _customDivider(),
                          _careServiceItem(mQuery, 'Services', _doctorModel!),
                          _customDivider(),
                          _careServiceItem(mQuery, 'Conditions', _doctorModel!),
                          _customDivider(),
                          Column(
                            children: [
                              const Text(
                                'Biography',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 4.0,
                              ),
                              SizedBox(
                                width: mQuery.width * 0.85,
                                child: Text(
                                  _doctorModel!.bio ?? 'No Biography Available',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          DoctorMoreInfo(
                              mQuery: mQuery,
                              doctorModel: _doctorModel ?? DoctorModel(user: UserModel(id: null))),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            );
          },
        ));
  }

  Container _careServiceItem(mQuery, String title, DoctorModel modelObject) {
    final theList = modelObject.specialityList;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          const SizedBox(
            height: 3,
          ),
          if (theList == null || theList.isEmpty)
            const Text(
              "No Item",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
              ),
            ),
          if (theList != null && theList.isNotEmpty)
            ...theList.map(
              (e) => Row(children: [
                const Icon(
                  Icons.check,
                  color: Palette.blueAppBar,
                ),
                Text(
                  e.name ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                  ),
                ),
              ]),
            )
        ],
      ),
    );
  }

  Widget _mapAddress(DoctorModel modelObject) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 22,
              ),
              Text(
                modelObject.user!.address != null
                    ? '${modelObject.user!.address!.district!.name ?? ""}, ${modelObject.user!.address!.city!.name ?? ""}'
                    : 'No Address Available',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(
            height: 5.0,
          ),
          Container(
              height: 200,
              decoration: BoxDecoration(
                color: Palette.imageBackground,
                border: Border.all(width: 3, color: Palette.imageBackground),
              ),
              child: GoogleMapWidget(
                mapType: 'view_doctor_profile',
                clinicObjectList: modelObject.clinicList ?? <ClinicModel>[],
              )),
        ],
      ),
    );
  }

  Container _customDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: dashedLine(Colors.blue),
    );
  }

  Container _profileAvatar(mQuery) {
    return Container(
      // height: 150,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                color: Colors.transparent,
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: mQuery.width * 0.88,
                  height: 180,
                  decoration:
                      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: Colors.blue[900],
                              ),
                              onPressed: () {
                                _isCompletedApptThere
                                    ? _isMeCanChat(
                                        ChatUserModel(
                                            phone: _doctorModel?.user!.phone ?? '',
                                            name: _doctorModel?.user!.name,
                                            rtlName: _doctorModel?.user!.name,
                                            avatar:
                                                MEDIA_LINK_NO_SLASH + _doctorModel!.user!.avatar!,
                                            lastText: LastChatText(timestamp: '')),
                                        true)
                                    : _isMeCanChat(ChatUserModel(), false);
                              }),
                          IconButton(
                              icon: Icon(
                                _isFavoriteLoading ? MdiIcons.progressCheck : Icons.favorite,
                                color: _isFavoiteDoctor ? Colors.red[900] : Colors.blue[900],
                              ),
                              onPressed: () => !_isFavoriteLoading
                                  ? (!_isFavoiteDoctor
                                      ? _addToFavorite(_doctorModel!.user!.id!, 'add')
                                      : _addToFavorite(_doctorModel!.user!.id!, 'remove'))
                                  : null),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RatingBarIndicator(
                            rating: _feedbackDataModel!.averageStar ?? 3.5,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 21.0,
                            unratedColor: Colors.grey[500],
                            direction: Axis.horizontal,
                          ),
                          tileText("(${_feedbackDataModel!.feedbackNo})", 'other'),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: _rowAnalitics(_feedbackDataModel!.patientNo!, 'Patients')),
                          const SizedBox(
                            height: 25,
                            child: VerticalDivider(
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                              child: _rowAnalitics(_feedbackDataModel!.completedApptNo!, 'Appts')),
                          const SizedBox(
                            height: 25,
                            child: VerticalDivider(
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                              child: _rowAnalitics(
                                  _feedbackDataModel!.experienceYear!, 'Experience',
                                  experience: true)),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 3.0,
                            minimumSize: const Size(270, 38),
                            onPrimary: Colors.white,
                            primary: Palette.imageBackground,
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppt(
                                doctorId: _doctorModel!.user!.id ?? 0,
                                clinicId: _doctorModel!.clinicList!.first.id ?? 0,
                                docotorName:
                                    "${_doctorModel!.title!.title} ${_doctorModel!.user!.name}"),
                          ),
                        ),
                        child: const Text(
                          'Book Appointment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          ProfileAvatarCircle(
            imageUrl: MEDIA_LINK_NO_SLASH + _doctorModel!.user!.avatar!,
            radius: 108,
            circleColor: Palette.imageBackground,
          )
        ],
      ),
    );
  }

  void _isMeCanChat(ChatUserModel _chatUserModel, bool isCanChat) async {
    if (isCanChat) {
      final theToken = await SharedPref().getToken();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              ChatMessage(theToken: theToken.toString(), chatUserModel: _chatUserModel)));
    } else {
      toastSnackBar('You have no completed appointment with this doctor to start chat',
          lenghtShort: false);
    }
  }

  bool _isFavoriteLoading = false;
  void _addToFavorite(int userId, String operation) async {
    FormData body = FormData.fromMap({
      'doctor_id': userId,
      'operation': operation,
    });
    setState(() {
      _isFavoriteLoading = true;
    });
    var _favoriteDoctorResponse = await HttpService()
        .postRequest(data: body, endPoint: FAVORITE_DOCTOR_CREATE_LIST, isAuth: true);

    // await progressObject.hide();
    if (!_favoriteDoctorResponse.error) {
      try {
        setState(() {
          _isFavoriteLoading = false;
          if (_favoriteDoctorResponse.data['message'] == 'added_successfully') {
            _isFavoiteDoctor = true;
            _feedbackDataModel!.favoiteDoctorList!.add(userId);
            infoNoOkDialogue(
                context,
                'You can see this doctor profile from your favorite doctor list',
                'Added Successfully!');
          }
          if (_favoriteDoctorResponse.data['message'] == 'removed_successfully') {
            _isFavoiteDoctor = false;
            _feedbackDataModel!.favoiteDoctorList!.remove(userId);
            infoNoOkDialogue(
                context,
                'This doctor will not be enlisted to your favorite doctor list anymore',
                'Removed Successfully!');
          }
          if (_favoriteDoctorResponse.data['message'] == 'failed') {
            infoNoOkDialogue(
                context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
          }
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

  Column _rowAnalitics(int theDigit, String theTitle, {bool experience = false}) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
              text: theDigit.toString(),
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
              children: [
                if (experience)
                  const TextSpan(
                      text: ' Year(s)',
                      style:
                          TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black))
              ]),
        ),
        Text(
          theTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
