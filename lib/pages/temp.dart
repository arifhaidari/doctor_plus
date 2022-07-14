// import 'package:auto_size_text/auto_size_text.dart';
// import '../models/models.dart';
// import '../providers/provider_list.dart';
// import 'package:flutter/material.dart';
// import '../utils/utils.dart';
// import 'screens.dart';

// enum NotificationFilter { all, appointment, chat, cancelAppt, clearAll }

// class NotificationView extends StatefulWidget {
//   @override
//   _NotificationViewState createState() => _NotificationViewState();
// }

// class _NotificationViewState extends State<NotificationView> {
//   String theQuery = 'All';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//         backgroundColor: Palette.blueAppBar,
//         actions: [
//           _notificationSorter(),
//         ],
//       ),
//       body: FutureBuilder(
//         future: HttpService().getRequest(endPoint: NOTE_GET + '?q=$theQuery'),
//         builder: (context, AsyncSnapshot<APIResponse> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return LoadingPlaceHolder();
//           }
//           if (snapshot.hasError) {
//             return ErrorPlaceHolderPage(
//                 errorDetail: 'Check your internet connection and try again',
//                 errorTitle: 'Uknown Error');
//           }
//           if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//             if (snapshot.data!.error) {
//               if (snapshot.data!.errorMessage == NO_INTERNET_CONNECTION) {
//                 return ErrorPlaceHolderPage(
//                     errorDetail:
//                         'You have no internet connect. Turn on your data or connect to a wifi',
//                     errorTitle: 'Internet Connection Error');
//               }

//               return ErrorPlaceHolderPage(
//                 errorDetail: snapshot.data!.errorMessage.toString(),
//                 errorTitle: 'System Error',
//               );
//             }
//             // model all the data here
//             if (snapshot.data!.data == null) {
//               return ErrorPlaceHolderPage(
//                   errorDetail: 'Check your internet connection and try again',
//                   errorTitle: 'Uknown Error');
//             }
//             List<NotificationModel> notificationList = <NotificationModel>[];
//             if (snapshot.data!.data is List) {
//               snapshot.data!.data.forEach((patient) {
//                 NotificationModel patientModel = NotificationModel.fromJson(patient);
//                 notificationList.add(patientModel);
//               });
//             }

//             return notificationList.length == 0
//                 ? PlaceHolder(
//                     title: 'Notification',
//                     body: 'Notificaiton will be listed here',
//                   )
//                 : NotificationList(
//                     notificationList: notificationList,
//                   );
//             // sow both list here
//           }
//           return ErrorPlaceHolderPage(
//               errorDetail: 'Check your internet connection and try again',
//               errorTitle: 'Uknown Error');
//         },
//       ),
//     );
//   }

//   PopupMenuButton _notificationSorter() {
//     return PopupMenuButton<String>(
//       onSelected: (String result) {
//         setState(() {
//           theQuery = result;
//         });
//       },
//       icon: Icon(Icons.sort),
//       color: Palette.imageBackground,
//       itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//         const PopupMenuItem<String>(
//           value: 'All',
//           child: Text('All'),
//         ),
//         const PopupMenuItem<String>(
//           value: 'Appt',
//           child: Text('Appointment'),
//         ),
//         const PopupMenuItem<String>(
//           value: 'Review',
//           child: Text('Review'),
//         ),
//         const PopupMenuItem<String>(
//           value: 'Record',
//           child: Text('Record'),
//         ),
//         const PopupMenuItem<String>(
//           value: 'Clear',
//           child: Text('Clear All'),
//         ),
//       ],
//     );
//   }
// }

// class NotificationList extends StatefulWidget {
//   final List<NotificationModel> notificationList;
//   const NotificationList({
//     Key? key,
//     required this.notificationList,
//   }) : super(key: key);

//   @override
//   _NotificationListState createState() => _NotificationListState();
// }

// class _NotificationListState extends State<NotificationList> {
//   List<NotificationModel> noteList = <NotificationModel>[];

//   @override
//   void initState() {
//     super.initState();
//     noteList = widget.notificationList;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         padding: EdgeInsets.only(top: 8, left: 5, right: 5),
//         itemCount: noteList.length,
//         itemBuilder: (context, index) {
//           return Dismissible(
//             key: ValueKey(noteList[index].id),
//             onDismissed: (dirction) {
//               _removeNote(noteList[index].id ?? 0);
//             },
//             background: Container(
//               padding: EdgeInsets.only(right: 30),
//               color: Colors.red,
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   'Clear Notification',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ),
//             child: Card(
//               elevation: 4,
//               color: Palette.imageBackground,
//               child: ListTile(
//                 leading: Icon(
//                   _noteTypeIcon(noteList[index].category ?? 'Appt'),
//                   size: 35,
//                   color: Colors.blue[900],
//                 ),
//                 title: AutoSizeText(
//                   noteList[index].title ?? 'Unknown Title',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
//                   maxLines: 1,
//                   minFontSize: 14,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 subtitle: Text(
//                   noteList[index].body ?? '',
//                   style: TextStyle(fontSize: 15, color: Colors.black87),
//                 ),
//               ),
//             ),
//           );
//         });
//   }

//   void _removeNote(int noteId) async {
//     var feedbackResponse = await HttpService().deleteRequest(
//       endPoint: NOTE_DETAIL + "$noteId/",
//     );

//     if (!feedbackResponse.error) {
//       toastSnackBar('Deleted Successfully');
//       setState(() {
//         noteList.removeWhere((element) => element.id == noteId);
//       });
//     } else {
//       infoNoOkDialogue(context, feedbackResponse.errorMessage.toString(), 'Oops Error!');
//     }
//   }

//   IconData _noteTypeIcon(String category) {
//     switch (category) {
//       case 'Appt':
//         return Icons.access_time;
//       // break; // it is a dead code
//       case 'Feedback':
//         return Icons.rate_review;
//       case 'Record':
//         return Icons.file_upload;
//       default:
//         return Icons.star;
//     }
//   }
// }

//  String _staffBehaior = 'Good';
//   String _doctorCheckup = 'Good';
//   String _clinicEnvironment = 'Good';
//   String _overallExperience = 'Good';
//   double _feedbackSumup = 2.5;
//   final _reviewController = TextEditingController();
//   double _calculateRating() {
//     double _initial = 0.0;
//     List<String> _optionList = [
//       _staffBehaior,
//       _doctorCheckup,
//       _clinicEnvironment,
//       _overallExperience
//     ];
//     for (var option in _optionList) {
//       _initial += option == 'Good' ? 0.625 : 1.25;
//     }
//     return _initial;
//   }

//   Future<void> _theFeedbackPopup(BuildContext context) async {
//     const theWidth = 350.0;
//     const TextStyle _titleTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
//     const TextStyle _optionTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
//     final BoxDecoration _boxDecoration = BoxDecoration(
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(width: 1, color: Palette.blueAppBar));
//     showDialog(
//         context: context,
//         builder: (BuildContext ctx) {
//           return Dialog(
//               backgroundColor: Colors.transparent,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               child: StatefulBuilder(
//                 builder: (BuildContext anotherCtx, StateSetter mySetState) {
//                   return SingleChildScrollView(
//                     child: Container(
//                       // height: 180,
//                       // color: Colors.white,
//                       width: theWidth,
//                       child: Stack(
//                         alignment: Alignment.topCenter,
//                         children: [
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 height: 25,
//                                 color: Colors.transparent,
//                               ),
//                               Container(
//                                 height: 40,
//                                 width: theWidth,
//                                 decoration: const BoxDecoration(
//                                     color: Palette.imageBackground,
//                                     borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(15),
//                                         topRight: Radius.circular(15))),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.only(top: 40),
//                                 decoration: const BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(15),
//                                       bottomRight: Radius.circular(15)),
//                                   color: Colors.white,
//                                 ),
//                                 width: theWidth,
//                                 child: Column(children: [
//                                   Center(
//                                     child: RatingBarIndicator(
//                                       rating: _feedbackSumup,
//                                       itemBuilder: (context, index) => const Icon(
//                                         Icons.star,
//                                         color: Palette.blueAppBar,
//                                       ),
//                                       itemCount: 5,
//                                       itemSize: 21.0,
//                                       unratedColor: Colors.grey[350],
//                                       direction: Axis.horizontal,
//                                     ),
//                                   ),
//                                   const Text(
//                                     'Dr. Khan Gul Jadoon',
//                                     maxLines: 1,
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 17,
//                                         fontWeight: FontWeight.w600,
//                                         color: Palette.blueAppBar),
//                                   ),

//                                   const Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 8.0),
//                                     child: Divider(
//                                       thickness: 1.3,
//                                     ),
//                                   ),
//                                   // staff behavior
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Expanded(
//                                             child: Text('Staff Behavior:', style: _titleTextStyle)),
//                                         Expanded(
//                                             child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.end,
//                                           children: [
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _staffBehaior = 'Good';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration:
//                                                     _staffBehaior == 'Good' ? _boxDecoration : null,
//                                                 child: const Text('Good',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                             const SizedBox(
//                                               width: 5,
//                                             ),
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _staffBehaior = 'Better';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _staffBehaior == 'Better'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Better',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                           ],
//                                         )),
//                                       ],
//                                     ),
//                                   ),
//                                   // Doctor checkup
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Expanded(
//                                             child: Text('Doctor Checkup:', style: _titleTextStyle)),
//                                         Expanded(
//                                             child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.end,
//                                           children: [
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _doctorCheckup = 'Good';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _doctorCheckup == 'Good'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Good',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                             const SizedBox(
//                                               width: 5,
//                                             ),
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _doctorCheckup = 'Better';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _doctorCheckup == 'Better'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Better',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                           ],
//                                         )),
//                                       ],
//                                     ),
//                                   ),
//                                   // Clinic Environment
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Expanded(
//                                             child: Text('Clinic Environment:',
//                                                 style: _titleTextStyle)),
//                                         Expanded(
//                                             child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.end,
//                                           children: [
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _clinicEnvironment = 'Good';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _clinicEnvironment == 'Good'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Good',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                             const SizedBox(
//                                               width: 5,
//                                             ),
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _clinicEnvironment = 'Better';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _clinicEnvironment == 'Better'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Better',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                           ],
//                                         )),
//                                       ],
//                                     ),
//                                   ),
//                                   // Overall Experience
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Expanded(
//                                             child: Text('Overall Experience:',
//                                                 style: _titleTextStyle)),
//                                         Expanded(
//                                             child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.end,
//                                           children: [
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _overallExperience = 'Good';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _overallExperience == 'Good'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Good',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                             const SizedBox(
//                                               width: 5,
//                                             ),
//                                             Expanded(
//                                                 child: GestureDetector(
//                                               onTap: () => mySetState(() {
//                                                 _overallExperience = 'Better';
//                                                 _feedbackSumup = _calculateRating();
//                                               }),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(4),
//                                                 decoration: _overallExperience == 'Better'
//                                                     ? _boxDecoration
//                                                     : null,
//                                                 child: const Text('Better',
//                                                     textAlign: TextAlign.center,
//                                                     style: _optionTextStyle),
//                                               ),
//                                             )),
//                                           ],
//                                         )),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 3,
//                                   ),
//                                   // TextField
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                                     child: TextFormField(
//                                       maxLength: 255,
//                                       maxLines: 2,
//                                       controller: _reviewController,
//                                       decoration: textFieldDesign(context, 'Review (Optional)'),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: customElevatedButton(context, () {
//                                       // _submitFeedback()
//                                     }, 'Submit'),
//                                   ),
//                                   const SizedBox(
//                                     height: 8,
//                                   )
//                                 ]),
//                               ),
//                             ],
//                           ),
//                           const Positioned(
//                               top: 0,
//                               child: ProfileAvatarCircle(
//                                 imageUrl: '',
//                                 radius: 100,
//                                 male: true,
//                                 circleColor: Palette.imageBackground,
//                               )),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ));
//         });
//   }
