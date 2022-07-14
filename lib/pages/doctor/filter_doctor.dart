import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../models/models.dart';
import '../../pages/screens.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class FilterDoctor extends StatefulWidget {
  final List<DoctorModel> doctorModelList;
  final List<SpecialityCategoryModel> specialityCategoryList;
  final String? provinceName;
  final String? query;
  final SpecialityCategoryModel? speciality;
  const FilterDoctor({
    Key? key,
    required this.doctorModelList,
    required this.specialityCategoryList,
    this.provinceName,
    this.query,
    this.speciality,
  }) : super(key: key);

  @override
  _FilterDoctorState createState() => _FilterDoctorState();
}

class _FilterDoctorState extends State<FilterDoctor> {
  final _searchController = TextEditingController();

  List<DoctorModel> _doctorModelList = <DoctorModel>[];

  String _defaultLocation = 'Select Province';
  String _defaultSpeciality = 'Select Speciality';
  final List<String> _locationList = ['Select Province'];
  final List<String> _specialtyList = ['Select Speciality'];

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
            : _theSearchFactory(_searchController.text, _defaultLocation, _defaultSpeciality,
                operation: 'search_anyway', nextPage: true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _getData() {
    // initialize
    _locationList.addAll(CITIES.map((e) => e.name!.toString()).toList());
    _specialtyList.addAll(widget.specialityCategoryList.map((e) => e.name!).toList());
    // initialize speciality
    if (widget.speciality != null) {
      // search by speciality from here
      _defaultSpeciality = widget.speciality!.name!;
      _theSearchFactory('', '', _defaultSpeciality, operation: 'search_anyway');
    } else if (widget.doctorModelList.isNotEmpty) {
      // no seaarch in here just load the top doctors
      _doctorModelList = widget.doctorModelList;
    } else {
      // search by query and province
      // initialize city
      final isProvinceExist = CITIES.firstWhere((element) => element.name == widget.provinceName,
          orElse: () => CityModel(name: null));
      _defaultLocation = ((widget.provinceName != null && isProvinceExist.name != null)
          ? widget.provinceName
          : _defaultLocation)!;

      _searchController.text = ((widget.query != null && widget.query != '') ? widget.query : '')!;
      _theSearchFactory(_searchController.text, _defaultLocation, _defaultSpeciality,
          operation: 'search_anyway');
    }
    // call the search funciton
  }

  void _theSearchFactory(String query, String province, String speciality,
      {String operation = 'other', bool nextPage = false}) async {
    List<DoctorModel> _tempDoctorModleList = <DoctorModel>[];
    if (query.length % 3 == 0 && query != '' || operation == 'search_anyway') {
      // print('query.length % 3 == 0 && _clinicNo <= 3 ture ');
      // if the search field is empty but the province field or speciality field is selected then send a a reqeust to server
      // by those criteria
      final body = {
        'query': query,
        'province': province != 'Select Province' ? province : '',
        'speciality': speciality != 'Select Speciality' ? speciality : ''
      };
      var _searchResponse = await HttpService().getRequest(
          queryMap: body, endPoint: (nextPage && _nextPage != '') ? _nextPage : SEARCH_DOCTOR);

      if (!_searchResponse.error) {
        if (_searchResponse.data['results'] is List &&
            _searchResponse.data['results'].length != 0) {
          _itemCount = _searchResponse.data['count'];
          _nextPage = _searchResponse.data['next'] ?? '';
          _searchResponse.data['results'].forEach((response) {
            final theObject = DoctorModel.fromJson(response);
            _tempDoctorModleList.add(theObject);
          });
        }
        setState(() {
          if (!nextPage) {
            _doctorModelList.clear();
            _doctorModelList.addAll(_tempDoctorModleList);
          } else {
            _doctorModelList.addAll(_tempDoctorModleList);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Palette.blueAppBar,
        title: const Text(
          'Filter Doctor',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        // actions: [_notificationSorter()],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 0, top: 15),
                width: mQuery.width * 0.95,
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoDropdown(_locationList, _defaultLocation, 'location'),
                    const SizedBox(
                      width: 10.0,
                    ),
                    _infoDropdown(_specialtyList, _defaultSpeciality, 'speciality'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                width: mQuery.width * 0.95,
                height: 50.0,
                child: TextFormField(
                  onChanged: (theVal) {
                    _theSearchFactory(theVal, _defaultLocation, _defaultSpeciality,
                        operation: theVal.isEmpty ? 'search_anyway' : 'other');
                  },
                  controller: _searchController,
                  decoration: textFieldDesign(
                      context, 'Search Clinic, Doctor, Disease, Symptoms ...',
                      isIcon: true, theTextController: _searchController),
                ),
              ),
              if (_doctorModelList.isEmpty)
                const PlaceHolder(
                  title: 'No Doctor Found',
                  body:
                      'Try another query to find doctor. Available query parameters i.e. doctor name, discease, location, sympoms , speciality and few more.',
                ),
              if (_doctorModelList.isNotEmpty)
                ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                    }),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Expanded _infoDropdown(theList, defaultVal, dropType) {
    return Expanded(
      child: Container(
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
          iconSize: 26,
          isExpanded: true,
          elevation: 12,
          style: const TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400),
          dropdownColor: Palette.imageBackground,
          underline: const SizedBox.shrink(),
          onChanged: (String? newValue) {
            setState(() {
              if (dropType == 'location') {
                _defaultLocation = newValue!;
                _theSearchFactory(_searchController.text, newValue, _defaultSpeciality,
                    operation: 'search_anyway');
              } else {
                _defaultSpeciality = newValue!;
                _theSearchFactory(_searchController.text, _defaultLocation, newValue,
                    operation: 'search_anyway');
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

  // PopupMenuButton _notificationSorter() {
  //   return PopupMenuButton<String>(
  //     onSelected: (String result) {
  //       // if (result != 'Clear') {
  //       //   setState(() {
  //       //     theQuery = result;
  //       //   });
  //       // } else {
  //       //   _remvoeAllNotes();
  //       // }
  //     },
  //     icon: const Icon(Icons.sort),
  //     color: Palette.imageBackground,
  //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
  //       const PopupMenuItem<String>(
  //         value: 'A-Z',
  //         child: Text('A-Z'),
  //       ),
  //       const PopupMenuItem<String>(
  //         value: 'Z-A',
  //         child: Text('Z-A'),
  //       ),
  //       const PopupMenuItem<String>(
  //         value: 'Top Rated',
  //         child: Text('Top Rated'),
  //       ),
  //       const PopupMenuItem<String>(
  //         value: 'Experienced',
  //         child: Text('Experienced'),
  //       ),
  //       const PopupMenuItem<String>(
  //         value: 'Previously Booked',
  //         child: Text('Previously Booked'),
  //       ),
  //     ],
  //   );
  // }
}
