// import 'package:doctor_panel/utils/utils.dart';
// import 'package:doctor_panel/widgets/widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../pages/screens.dart';
import '../../providers/end_point.dart';
import '../../utils/utils.dart';

import '../../models/models.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class PatientOverview extends StatelessWidget {
  final PatientModel patientModel;
  final bool isPatient;

  const PatientOverview({Key? key, required this.patientModel, required this.isPatient})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    final isYesNo = patientModel.shareRecordToAll! ? "Yes" : "No";
    return patientModel.user!.id == null
        ? const PlaceHolder(
            title: "User Does Not Exist",
            body:
                "Unexpected error occured. Please try again and check your internet conneciton as well.")
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: mQuery.width * 0.94,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 3.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfileAvatarCircle(
                              imageUrl: patientModel.user!.avatar != null
                                  ? (MEDIA_LINK_NO_SLASH + patientModel.user!.avatar!)
                                  : null,
                              isActive: true,
                              radius: 90,
                              male: patientModel.user?.gender == "Male" ? true : false,
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          patientModel.user?.name ?? 'Unknown',
                                          maxLines: 1,
                                          minFontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3.0,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          '${patientModel.user?.age == "" ? "Unknown Age" : patientModel.user?.age} ${patientModel.user?.age == "" ? "" : "Years"}, Blood Group (${patientModel.bloodGroup ?? "Unknown"}) ',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          minFontSize: 14,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Palette.darkGreen),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.phone_enabled_outlined,
                                        size: 20,
                                        color: Colors.blue[900],
                                      ),
                                      Expanded(
                                        child: AutoSizeText(
                                          patientModel.user?.phone ?? "No Phone",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 15,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.only(top: 8.0, left: 8.0, right: 5.0, bottom: 5.0),
                        child: Column(
                          children: [
                            cardDetailItem('Completed Appts: ${patientModel.totalBookedAppt}',
                                Icons.date_range),
                            cardDetailItem(
                                'Last Appointment: ${patientModel.lastCompletedAppt ?? "No Appt Yet"}',
                                Icons.access_time),
                            if (isPatient)
                              cardDetailItem('Family Members: ${patientModel.familyMemberNo}',
                                  Icons.family_restroom_outlined),
                            cardDetailItem('Medical Records: ${patientModel.medicalRecordNo}',
                                Icons.medical_services_outlined),
                            cardDetailItem(
                                'Medical Record Share To All: $isYesNo', Icons.share_outlined),
                            cardDetailItem(
                                patientModel.user?.address != null
                                    ? "${patientModel.user?.address?.district!.name ?? ''}, ${patientModel.user?.address?.city!.name ?? ''}"
                                    : "Address Not Available",
                                Icons.room,
                                maxLine: 2),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
