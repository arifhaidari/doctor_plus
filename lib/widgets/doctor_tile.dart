import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../widgets/widgets.dart';
import '../models/models.dart';
import '../pages/screens.dart';
import '../utils/utils.dart';

class DoctorTile extends StatelessWidget {
  final DoctorModel doctorModel;
  final String userAvatar;
  const DoctorTile({Key? key, required this.doctorModel, required this.userAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Card(
      margin: const EdgeInsets.only(top: 5, bottom: 8),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
        width: mQuery.width * 0.94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewDoctorProfile(doctorId: doctorModel.user!.id ?? 0))),
                      child: ProfileAvatarSquare(
                        avatarLink: userAvatar,
                        gender: doctorModel.user!.gender ?? 'Male',
                      )),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewDoctorProfile(doctorId: doctorModel.user!.id ?? 0))),
                          child: tileText("${doctorModel.title!.title} ${doctorModel.user!.name}",
                              'doctor_name'),
                        ),
                        tileText(
                            (doctorModel.specialityList!.isNotEmpty
                                ? doctorModel.specialityList!.first.name
                                : "No Speciality")!,
                            'other'),
                        if (doctorModel.specialityList!.length > 1)
                          tileText(doctorModel.specialityList!.last.name!, 'other'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RatingBarIndicator(
                              rating: doctorModel.averageStar ?? 3.5,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amberAccent,
                              ),
                              itemCount: 5,
                              itemSize: 21.0,
                              unratedColor: Colors.grey[400],
                              direction: Axis.horizontal,
                            ),
                            tileText("(${doctorModel.reviewNo})", 'other'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Palette.blueAppBar,
                  size: 20,
                ),
                Expanded(
                  child: AutoSizeText(
                    '${doctorModel.clinicList!.first.district!.name!}, ${doctorModel.clinicList!.first.city!.name!}',
                    maxLines: 1,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            dashedLine(Palette.blueAppBar),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ViewDoctorProfile(doctorId: doctorModel.user!.id ?? 0))),
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Palette.imageBackground,
                      size: 20,
                    ),
                    label: const Text(
                      'View Profile',
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Palette.imageBackground),
                    )),
                const Text(
                  '|',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppt(
                                doctorId: doctorModel.user!.id ?? 0,
                                clinicId: doctorModel.clinicList!.first.id ?? 0,
                                docotorName:
                                    "${doctorModel.title!.title} ${doctorModel.user!.name}"),
                          ),
                        ),
                    icon: Icon(
                      Icons.date_range_outlined,
                      size: 20,
                      color: Colors.blue[900],
                    ),
                    label: Text(
                      'Book Appt',
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.blue[900]),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
