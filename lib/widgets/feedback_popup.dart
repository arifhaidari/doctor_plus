import 'package:dio/dio.dart';
import 'package:doctor_plus/models/appt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../providers/provider_list.dart';
import '../utils/utils.dart';
import 'widgets.dart';

class FeedbackPopup extends StatefulWidget {
  final ApptModel apptModel;
  final int noteId;
  const FeedbackPopup({Key? key, required this.apptModel, required this.noteId}) : super(key: key);

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  @override
  void initState() {
    super.initState();
    if (widget.apptModel.id == null) {
      Navigator.of(context).pop();
    }
  }

  String _staffBehaior = 'Good';
  String _doctorCheckup = 'Good';
  String _clinicEnvironment = 'Good';
  String _overallExperience = 'Good';
  double _feedbackSumup = 2.5;
  final _reviewController = TextEditingController();
  double _calculateRating() {
    double _initial = 0.0;
    List<String> _optionList = [
      _staffBehaior,
      _doctorCheckup,
      _clinicEnvironment,
      _overallExperience
    ];
    for (var option in _optionList) {
      _initial += option == 'Good' ? 0.625 : 1.25;
    }
    return _initial;
  }

  bool _isReverse = false;

  static const theWidth = 350.0;
  static const TextStyle _titleTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle _optionTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
  final BoxDecoration _boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(width: 1, color: Palette.blueAppBar));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _isReverse = false;
        });
      },
      child: FutureBuilder(builder: (BuildContext ctx, AsyncSnapshot snap) {
        return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: StatefulBuilder(
              builder: (BuildContext anotherCtx, StateSetter mySetState) {
                return SingleChildScrollView(
                  reverse: _isReverse ? true : false,
                  child: SizedBox(
                    width: theWidth,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 25,
                              color: Colors.transparent,
                            ),
                            Container(
                              height: 40,
                              width: theWidth,
                              decoration: const BoxDecoration(
                                  color: Palette.imageBackground,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15), topRight: Radius.circular(15))),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 40),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                                color: Colors.white,
                              ),
                              width: theWidth,
                              child: Column(children: [
                                Center(
                                  child: RatingBarIndicator(
                                    rating: _feedbackSumup,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Palette.blueAppBar,
                                    ),
                                    itemCount: 5,
                                    itemSize: 21.0,
                                    unratedColor: Colors.grey[352],
                                    direction: Axis.horizontal,
                                  ),
                                ),
                                Text(
                                  "${widget.apptModel.doctor?.title!.title} ${widget.apptModel.doctor?.user!.name}",
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Palette.blueAppBar),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Divider(
                                    thickness: 1.3,
                                  ),
                                ),
                                // staff behavior
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                          child: Text('Staff Behavior:', style: _titleTextStyle)),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _staffBehaior = 'Good';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration:
                                                  _staffBehaior == 'Good' ? _boxDecoration : null,
                                              child: const Text('Good',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _staffBehaior = 'Better';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration:
                                                  _staffBehaior == 'Better' ? _boxDecoration : null,
                                              child: const Text('Better',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                                // Doctor checkup
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                          child: Text('Doctor Checkup:', style: _titleTextStyle)),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _doctorCheckup = 'Good';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration:
                                                  _doctorCheckup == 'Good' ? _boxDecoration : null,
                                              child: const Text('Good',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _doctorCheckup = 'Better';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: _doctorCheckup == 'Better'
                                                  ? _boxDecoration
                                                  : null,
                                              child: const Text('Better',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                                // Clinic Environment
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                          child:
                                              Text('Clinic Environment:', style: _titleTextStyle)),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _clinicEnvironment = 'Good';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: _clinicEnvironment == 'Good'
                                                  ? _boxDecoration
                                                  : null,
                                              child: const Text('Good',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _clinicEnvironment = 'Better';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: _clinicEnvironment == 'Better'
                                                  ? _boxDecoration
                                                  : null,
                                              child: const Text('Better',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                                // Overall Experience
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                          child:
                                              Text('Overall Experience:', style: _titleTextStyle)),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _overallExperience = 'Good';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: _overallExperience == 'Good'
                                                  ? _boxDecoration
                                                  : null,
                                              child: const Text('Good',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () => mySetState(() {
                                              _overallExperience = 'Better';
                                              _feedbackSumup = _calculateRating();
                                            }),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: _overallExperience == 'Better'
                                                  ? _boxDecoration
                                                  : null,
                                              child: const Text('Better',
                                                  textAlign: TextAlign.center,
                                                  style: _optionTextStyle),
                                            ),
                                          )),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                // TextField
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: TextFormField(
                                    onTap: () {
                                      setState(() {
                                        _isReverse = true;
                                      });
                                    },
                                    maxLength: 255,
                                    maxLines: 2,
                                    controller: _reviewController,
                                    decoration: textFieldDesign(context, 'Review (Optional)'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: customElevatedButton(context, () {
                                    _submitFeedback(context);
                                  }, 'Submit'),
                                ),
                                const SizedBox(
                                  height: 8,
                                )
                              ]),
                            ),
                          ],
                        ),
                        Positioned(
                            top: 0,
                            child: ProfileAvatarCircle(
                              imageUrl: widget.apptModel.doctor?.user!.avatar ?? '',
                              radius: 100,
                              male: true,
                              circleColor: Palette.imageBackground,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ));
      }),
    );
  }

  void _submitFeedback(BuildContext ctx) async {
    bool _isDialogRunning = false;
    FormData body = FormData.fromMap({
      'appt_id': widget.apptModel.id,
      'note_id': widget.noteId,
      'review': _reviewController.text,
      'staff_behavior': _staffBehaior,
      'doctor_checkup': _doctorCheckup,
      'clinic_environment': _clinicEnvironment,
      'overall_experience': _overallExperience,
    });
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    var profileSettingResponse =
        await HttpService().postRequest(data: body, endPoint: NOTE_GET, isAuth: true);
    Navigator.of(ctx).pop();
    _isDialogRunning = false;
    if (!profileSettingResponse.error) {
      try {
        if (profileSettingResponse.data['message'] == 'success') {
          Navigator.of(context).pop(
              {'is_success': true, 'review': _reviewController.text, 'rating': _feedbackSumup});
          toastSnackBar('Submitted Successfully', lenghtShort: false);
        } else {
          Navigator.of(context).pop({'is_success': false});
          toastSnackBar(GlobalVariable.UNEXPECTED_ERROR, lenghtShort: false);
        }
      } catch (e) {
        _isDialogRunning ? Navigator.of(ctx).pop() : null;
        Navigator.of(context).pop({'is_success': true});
        toastSnackBar(GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, lenghtShort: false);
      }
    } else {
      Navigator.of(context).pop({'is_success': true});
      toastSnackBar(GlobalVariable.UNEXPECTED_ERROR, lenghtShort: false);
    }
  }
}
