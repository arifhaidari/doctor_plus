import 'package:flutter/material.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';
import '../screens.dart';

class MedicalRecord extends StatefulWidget {
  final PatientModel? patient;
  final bool isPatient;
  const MedicalRecord({Key? key, this.patient, this.isPatient = false}) : super(key: key);

  @override
  _MedicalRecordState createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  final List<MedicalRecordModel> _medicalRecordList = <MedicalRecordModel>[];
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _nextPage = '';
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _getData(widget.isPatient ? 'Me' : 'All', false);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= _medicalRecordList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(widget.isPatient ? 'Me' : 'All', true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _getData(String sortingKey, bool nextPage) async {
    List<MedicalRecordModel> _tempMedicalRecordList = <MedicalRecordModel>[];
    Map<String, dynamic> _theMap = {
      "q": sortingKey,
      "is_profile": 'yes',
      "user_id": widget.patient?.user!.id ?? 0,
    };

    final _medicalRecordResponse = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : ALL_MEDICAL_RECORD,
        queryMap: _theMap);

    if (!_medicalRecordResponse.error) {
      try {
        setState(() {
          if (_medicalRecordResponse.data['results'] is List &&
              _medicalRecordResponse.data['results'].length != 0) {
            _itemCount = _medicalRecordResponse.data['count'];
            _nextPage = _medicalRecordResponse.data['next'] ?? '';
            _medicalRecordResponse.data['results'].forEach((element) {
              _tempMedicalRecordList.add(MedicalRecordModel.fromJson(element));
            });
          }

          if (!nextPage) {
            _medicalRecordList.clear();
            _medicalRecordList.addAll(_tempMedicalRecordList);
          } else {
            _medicalRecordList.addAll(_tempMedicalRecordList);
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
        if (_medicalRecordResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _medicalRecordResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _getData(widget.isPatient ? 'Me' : 'All', false);
      },
      child: Builder(
        builder: (BuildContext ctx) {
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
          return _medicalRecordList.isEmpty
              ? const PlaceHolder(
                  title: 'No Medical Record Available',
                  body: 'Medical record of you and your family members will be listed here',
                )
              : ListView.builder(
                  itemCount: _medicalRecordList.length + 1,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    if (index < _medicalRecordList.length) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        color: Colors.white,
                        // color: Palette.imageBackground,
                        child: ListTile(
                          onLongPress: () => questionDialogue(
                              context,
                              'Do you really want to delete this medical record',
                              'Delete Medical Record', () {
                            _deleteMedicalRecord(_medicalRecordList[index].id!);
                          }),
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Palette.blueAppBar,
                            child: Icon(
                              Icons.medical_services_outlined,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Text('${_medicalRecordList[index].recordFileNo} File(s)'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MedicalRecordDetail(
                                        recordId: _medicalRecordList[index].id ?? 0,
                                      ))).then((value) => _updateTileData(value)),
                          title: Text(
                            _medicalRecordList[index].title ?? 'No Title',
                            maxLines: 1,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              tileText(
                                  "Doctor: ${_medicalRecordList[index].relatedDoctor!.user!.name}",
                                  'other'),
                              tileText("Patient: ${_medicalRecordList[index].patient!.user!.name}",
                                  'other'),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25.0),
                        child: Center(
                          child: _itemCount <= _medicalRecordList.length
                              ? null
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }
                  });
        },
      ),
    );
  }

  void _deleteMedicalRecord(int id) async {
    var deleteResponse = await HttpService().deleteRequest(
      isAuth: true,
      endPoint: MEDICAL_RECORD_DETAIL + "$id/",
    );

    if (!deleteResponse.error) {
      try {
        if (deleteResponse.data['message'] == 'success') {
          toastSnackBar('Deleted Successfully');
          setState(() {
            _medicalRecordList.removeWhere((element) => element.id == id);
            _itemCount -= 1;
          });
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } catch (e) {
        infoNoOkDialogue(
            context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

  void _updateTileData(Map<String, dynamic> theMap) {
    final theElement =
        _medicalRecordList.firstWhere((element) => element.id == theMap['record_id']);
    theElement.recordFileNo = theMap['file_no'];
    theElement.title = theMap['title'];
    theElement.relatedDoctor!.user!.name = theMap['related_doctor'];
    theElement.patient!.user!.name = theMap['patient'];
    setState(() {
      _medicalRecordList[_medicalRecordList
          .indexWhere((element) => element.id == theMap['record_id'])] = theElement;
      // _medicalRecordList.insert(0, theElement);
    });
  }
}
