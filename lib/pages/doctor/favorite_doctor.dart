// import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/models.dart';
import '../../providers/provider_list.dart';
import '../../widgets/widgets.dart';
import '../../utils/utils.dart';
import '../screens.dart';
// import '../../widgets/widgets.dart';

class FavortieDoctor extends StatefulWidget {
  const FavortieDoctor({Key? key}) : super(key: key);

  @override
  _FavortieDoctorState createState() => _FavortieDoctorState();
}

class _FavortieDoctorState extends State<FavortieDoctor> {
  final List<DoctorModel> _doctorModelList = <DoctorModel>[];
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final _scrollController = ScrollController();
  String _nextPage = '';
  int _itemCount = 0;
  @override
  void initState() {
    super.initState();
    _getData();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= _doctorModelList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(nextPage: true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _getData({bool nextPage = false}) async {
    List<DoctorModel> _tempDoctorList = <DoctorModel>[];
    setState(() {
      _isLoading = true;
    });
    final _favoriteDoctorResponse = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : FAVORITE_DOCTOR_CREATE_LIST,
        isAuth: true);

    if (!_favoriteDoctorResponse.error) {
      try {
        if (_favoriteDoctorResponse.data['results'] is List &&
            _favoriteDoctorResponse.data['results'].length != 0) {
          _itemCount = _favoriteDoctorResponse.data['count'];
          _nextPage = _favoriteDoctorResponse.data['next'] ?? '';
          setState(() {
            _favoriteDoctorResponse.data['results'].forEach((response) {
              final theObject = DoctorModel.fromJson(response);
              _tempDoctorList.add(theObject);
            });

            if (!nextPage) {
              _doctorModelList.clear();
              _doctorModelList.addAll(_tempDoctorList);
            } else {
              _doctorModelList.addAll(_tempDoctorList);
            }

            _isLoading = false;
          });
        }
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
        if (_favoriteDoctorResponse.errorMessage == NO_INTERNET_CONNECTION) {
          // print('connection error ');
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _favoriteDoctorResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Favorite Doctors',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
        ),
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
              return _doctorModelList.isEmpty
                  ? const PlaceHolder(
                      title: 'No Doctor Available',
                      body: 'Your favorite doctors will be listed here')
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _doctorModelList.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _doctorModelList.length) {
                          return DoctorTile(
                            doctorModel: _doctorModelList[index],
                            userAvatar: _doctorModelList[index].user!.avatar!,
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            child: Center(
                              child: _itemCount <= _doctorModelList.length
                                  ? null
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        }
                      });
            },
          ),
        ));
  }
}
