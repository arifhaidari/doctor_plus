// import 'dart:html';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import '../../providers/end_point.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../utils/utils.dart';
import '../pages/screens.dart';

// Widget customDrawer(mQuery, context) {
//   return CustomDrawer();
// }

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Drawer(
        child: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 300,
              // height: mQuery.height * 0.32,
              color: Palette.blueAppBar,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 45.0,
                  ),
                  ProfileAvatarCircle(
                    imageUrl: (DRAWER_DATA['avatar'] != null && DRAWER_DATA['avatar'] != '')
                        ? MEDIA_LINK_NO_SLASH + DRAWER_DATA['avatar']
                        : null,
                    isActive: true,
                    radius: 90,
                    onlinePosition: 6,
                    borderWidth: 2.5,
                    circleColor: Palette.heavyYellow,
                    male: DRAWER_DATA['gender'] == 'Male' ? true : false,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const SizedBox(
                    height: 3.0,
                  ),
                  AutoSizeText(
                    DRAWER_DATA['full_name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 14,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _profileAnalytics(
                          "Relative Appts", DRAWER_DATA['relative_completed_appt_no']),
                      _profileAnalytics("My Appts", DRAWER_DATA['patient_completed_appt_no']),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        //second child of stack
        Column(
          children: [
            Container(
              // height: Platform.isIOS ? 235 : 235
              height: 225,
              // height: mQuery.height * 0.28,
              color: Colors.transparent,
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 15.0),
              elevation: 3.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  // height: 470,
                  height: Platform.isIOS ? mQuery.height * 0.58 : mQuery.height * 0.53,
                  // height: mQuery.height * 0.52,
                  width: mQuery.width * 0.95,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5.0,
                        ),
                        _drawerItem(
                            "View Profile",
                            Icons.person,
                            context,
                            PatientProfile(
                              // patientId: 0,
                              patientId: int.tryParse(DRAWER_DATA['id']) ?? 0,
                            )),
                        _drawerItem(
                            "Favorite Doctor", Icons.favorite, context, const FavortieDoctor()),
                        _drawerItem("Family Profile", Icons.family_restroom_outlined, context,
                            const FamilyMember()),
                        _drawerItem("Notifications", Icons.notifications, context,
                            const NotificationView()),
                        _drawerItem("Blog", Icons.post_add, context, const Blog()),
                        _drawerItem("Languages", Icons.language, context, null),
                        _drawerItem("About Us", Icons.info, context, const AboutUs()),
                        _drawerItem("Settings", Icons.settings, context, const Settings()),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 25.0),
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  elevation: 8.0,
                                  primary: Palette.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  )),
                              onPressed: () async {
                                // print('logout happned ====');
                                questionDialogue(context, "Do you really want to logout", 'Logout',
                                    () async {
                                  await SharedPref().logout();
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) => const SignupLogin()));
                                });
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                'Logout',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              )),
                        ),
                      ],
                    ),
                  )),
            )
          ],
        )
      ],
    ));
  }

  Column _profileAnalytics(String item, String value) {
    return Column(
      children: [
        Text(
          item,
          style: const TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w400),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _drawerItem(String text, IconData icon, BuildContext context, page) {
    return InkWell(
      splashColor: Colors.black,
      onTap: () {
        // print('the inkwell got taped');
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        } else {
          simpleDialogueBox(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 28,
              width: 28,
              child: Icon(
                icon,
                color: Colors.yellow,
              ),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
            ),
            TextButton(
              onPressed: () {
                // print('text button');
                if (page != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
                } else {
                  simpleDialogueBox(context);
                }

                // print('//////////');
              },
              child: Text(
                text,
                style:
                    TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.blue[900]),
              ),
            ),
            if (page == null)
              const Text(
                '(EN)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                textAlign: TextAlign.end,
              )
          ],
        ),
      ),
    );
  }
}
