import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../providers/provider_list.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/models.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import '../../pages/screens.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
// import '../../models/dummy_data.dart';

class FamilyMember extends StatefulWidget {
  const FamilyMember({Key? key}) : super(key: key);

  @override
  _FamilyMemberState createState() => _FamilyMemberState();
}

class _FamilyMemberState extends State<FamilyMember> {
  final List<PatientModel> _patientModelList = <PatientModel>[];
  //
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
    final _relativeListResponse =
        await HttpService().getRequest(endPoint: FAMILY_MEMBER_TILE, isAuth: true);
    if (!_relativeListResponse.error) {
      try {
        setState(() {
          _relativeListResponse.data.forEach((element) {
            _patientModelList.add(
              PatientModel.fromJson(element),
            );
            // _relativeModelList.add(PatientModel.fromJson(element));
          });
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
        if (_relativeListResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _relativeListResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Family Members',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const AddFamilyMember()))
                        .then((value) {
                      // add a new fancy card to the list
                      if (value['is_added']) {
                        print('it is added bro');
                        setState(() {
                          _patientModelList.insert(
                            0,
                            PatientModel(
                                user: UserModel(
                                  id: value['id'],
                                  name: value['full_name'],
                                  rtlName: value['rtl_full_name'],
                                  avatar: value['avatar'],
                                  gender: value['gender'],
                                ),
                                relativeRelation:
                                    RelativeRelationModel(relation: value['relation']),
                                shareRecordToAll: value['share_record_to_all']),
                          );
                        });
                      }
                    })),
          ],
        ),
        backgroundColor: Palette.scaffoldBackground,
        body: RefreshIndicator(
          onRefresh: () async {
            _getData();
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
              return _patientModelList.isEmpty
                  ? const PlaceHolder(
                      title: 'No Family Member Available',
                      body:
                          'You can create profile for your family member and sync to your account. You can book appt and store the medical record of your family member and they will be listed here',
                    )
                  : StackedCardCarousel(
                      initialOffset: 30,
                      spaceBetweenItems: 250,
                      // items: _patientModelList,
                      items: _patientModelList.map((thePatient) {
                        final isYesNo = thePatient.shareRecordToAll! ? "Yes" : "No";
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  width: mQuery.width * 0.80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => questionDialogue(
                                            context,
                                            'Do you really want to delete this family member?',
                                            'Delete Family Member', () {
                                          _deleteFamilyMember(thePatient.user!.id ?? 0, context);
                                        }),
                                        color: Colors.blue[900],
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PatientProfile(
                                                      patientId: thePatient.user!.id ?? 0,
                                                      isPatient: false,
                                                    ))),
                                        child: ProfileAvatarCircle(
                                          imageUrl: thePatient.user!.avatar ?? '',
                                          radius: 120,
                                          male: thePatient.user!.gender == 'Male' ? true : false,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => EditFamilyMember(
                                                      patientModel: thePatient,
                                                    ))).then((value) {
                                          if (value['is_changed']) {
                                            setState(() {
                                              thePatient.user!.name = value['full_name'];
                                              thePatient.user!.rtlName = value['rtl_full_name'];
                                              thePatient.user!.gender = value['gender'];
                                              thePatient.relativeRelation!.relation =
                                                  value['relation'];
                                              thePatient.shareRecordToAll =
                                                  value['share_record_to_all'];
                                              thePatient.user!.avatar = value['avatar'];
                                            });
                                          }
                                        }),
                                        color: Colors.blue[900],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PatientProfile(
                                                patientId: thePatient.user!.id ?? 0,
                                                isPatient: false,
                                              ))),
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    width: mQuery.width * 0.80,
                                    child: AutoSizeText(
                                      thePatient.user!.name!,
                                      maxLines: 1,
                                      minFontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.pinkAccent,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: mQuery.width * 0.80,
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      cardDetailItem(
                                          'Relation: ${thePatient.relativeRelation!.relation}',
                                          Icons.family_restroom_outlined),
                                      cardDetailItem('Medical Record Shared To All: $isYesNo',
                                          Icons.share_outlined),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
            },
          ),
        ));
  }

  void _deleteFamilyMember(int relativeId, BuildContext ctx) async {
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      FormData body = FormData.fromMap({'id': relativeId, 'operation': 'delete'});

      final _deleteResponse =
          await HttpService().postRequest(endPoint: FAMILY_MEMBER_TILE, isAuth: true, data: body);

      Navigator.of(ctx).pop();
      _isDialogRunning = false;
      if (!_deleteResponse.error) {
        if (_deleteResponse.data['message'] == 'success') {
          toastSnackBar('Deleted Successfully');
          setState(() {
            _patientModelList.removeWhere((element) => element.user!.id == relativeId);
          });
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        if (_deleteResponse.errorMessage == NO_INTERNET_CONNECTION) {
          infoNoOkDialogue(
              context, GlobalVariable.INTERNET_ISSUE_CONTENT, GlobalVariable.INTERNET_ISSUE_TITLE);
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }
}
