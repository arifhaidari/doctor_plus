// // Card(
//                         margin: EdgeInsets.only(top: 5, bottom: 8),
//                         elevation: 3.0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Container(
//                           padding: EdgeInsets.only(top: 8, right: 8, left: 8),
//                           width: mQuery.width * 0.94,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10.0),
//                             color: Colors.white,
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     ProfileAvatarSquare(
                                      // avatarLink: MEDIA_LINK_NO_SLASH +
                                      //     _doctorModelList[index].user!.avatar!,
//                                       gender: _doctorModelList[index].user!.gender ?? 'Male',
//                                     ),
//                                     SizedBox(
//                                       width: 10.0,
//                                     ),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           tileText(
//                                               "${_doctorModelList[index].title!.title} ${_doctorModelList[index].user!.name}",
//                                               'doctor_name'),
//                                           tileText(
//                                               (_doctorModelList[index].specialityList!.length > 0
//                                                   ? _doctorModelList[index]
//                                                       .specialityList!
//                                                       .first
//                                                       .name
//                                                   : "No Speciality")!,
//                                               'other'),
//                                           if (_doctorModelList[index].specialityList!.length > 1)
//                                             tileText(
//                                                 _doctorModelList[index].specialityList!.last.name!,
//                                                 'other'),
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.start,
//                                             children: [
//                                               RatingBarIndicator(
//                                                 rating: _doctorModelList[index].averageStar ?? 3.5,
//                                                 itemBuilder: (context, index) => Icon(
//                                                   Icons.star,
//                                                   color: Colors.amberAccent,
//                                                 ),
//                                                 itemCount: 5,
//                                                 itemSize: 21.0,
//                                                 unratedColor: Colors.grey[400],
//                                                 direction: Axis.horizontal,
//                                               ),
//                                               tileText(
//                                                   "(${_doctorModelList[index].reviewNo})", 'other'),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(
//                                     Icons.location_on,
//                                     color: Palette.blueAppBar,
//                                     size: 20,
//                                   ),
//                                   Expanded(
//                                     child: AutoSizeText(
//                                       '${_doctorModelList[index].clinicList!.first.district!.name!}, ${_doctorModelList[index].clinicList!.first.city!.name!}',
//                                       maxLines: 1,
//                                       minFontSize: 12,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               dashedLine(Palette.blueAppBar),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   TextButton.icon(
//                                       style: TextButton.styleFrom(
//                                         minimumSize: Size(150, 40),
//                                       ),
//                                       onPressed: () => Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) => ViewDoctorProfile(
//                                                   doctorId:
//                                                       _doctorModelList[index].user!.id ?? 0))),
//                                       icon: Icon(
//                                         Icons.remove_red_eye,
//                                         color: Palette.imageBackground,
//                                         size: 20,
//                                       ),
//                                       label: Text(
//                                         'View Profile',
//                                         style: TextStyle(
//                                             fontSize: 15.5,
//                                             fontWeight: FontWeight.w700,
//                                             color: Palette.imageBackground),
//                                       )),
//                                   Text(
//                                     '|',
//                                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                                   ),
//                                   TextButton.icon(
//                                       style: TextButton.styleFrom(
//                                         minimumSize: Size(150, 40),
//                                       ),
//                                       onPressed: () => Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => BookAppt(
//                                                   doctorId: _doctorModelList[index].user!.id ?? 0,
//                                                   clinicId: _doctorModelList[index]
//                                                           .clinicList!
//                                                           .first
//                                                           .id ??
//                                                       0,
//                                                   docotorName:
//                                                       "${_doctorModelList[index].title!.title} ${_doctorModelList[index].user!.name}"),
//                                             ),
//                                           ),
//                                       icon: Icon(
//                                         Icons.date_range_outlined,
//                                         size: 20,
//                                         color: Colors.blue[900],
//                                       ),
//                                       label: Text(
//                                         'Book Appt',
//                                         style: TextStyle(
//                                             fontSize: 15.5,
//                                             fontWeight: FontWeight.w700,
//                                             color: Colors.blue[900]),
//                                       )),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
