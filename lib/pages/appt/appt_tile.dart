import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/models.dart';
import '../../pages/screens.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ApptTile extends StatefulWidget {
  // final List<ApptModel> myApptList;
  final Function(int, int, int, int) theFunc;
  final ApptModel apptModelObject;
  final bool isViewProfile;
  final PatientModel? patient;
  const ApptTile(
      {Key? key,
      required this.apptModelObject,
      this.isViewProfile = false,
      this.patient,
      required this.theFunc})
      : super(key: key);

  @override
  _ApptTileState createState() => _ApptTileState();
}

class _ApptTileState extends State<ApptTile> {
  @override
  Widget build(BuildContext context) {
    PatientModel patient = (widget.isViewProfile
        ? widget.patient
        : ((widget.apptModelObject.relative ?? widget.apptModelObject.patient))!)!;
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
          // mainAxisSize: MainAxisSize.min,
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
                            builder: (context) => ViewDoctorProfile(
                                doctorId: widget.apptModelObject.doctor!.user!.id ?? 0))),
                    child: ProfileAvatarSquare(
                      avatarLink: widget.apptModelObject.doctor!.user!.avatar,
                      gender: widget.apptModelObject.doctor!.user!.gender ?? 'Male',
                    ),
                  ),
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
                                  builder: (context) => ViewDoctorProfile(
                                      doctorId: widget.apptModelObject.doctor!.user!.id ?? 0))),
                          child: tileText(
                              "${widget.apptModelObject.doctor!.title!.title} ${widget.apptModelObject.doctor!.user!.name}",
                              'doctor_name'),
                        ),
                        tileText("Date: ${widget.apptModelObject.apptDate}", 'other'),
                        tileText(
                            "Duration: ${widget.apptModelObject.startApptTime} - ${widget.apptModelObject.endApptTime}",
                            'other'),
                        tileText("Patient: ${patient.user!.name}", 'other'),
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
                  MdiIcons.hospitalBuilding,
                  color: Palette.blueAppBar,
                  size: 20,
                ),
                Expanded(
                  child: AutoSizeText(
                    ' ${widget.apptModelObject.clinic!.clinicName}',
                    maxLines: 1,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 3,
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
                    '${widget.apptModelObject.clinic!.address}, ${widget.apptModelObject.clinic!.district!.name}, ${widget.apptModelObject.clinic!.city!.name}',
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
                      minimumSize: const Size(140, 35),
                    ),
                    onPressed: () => widget.apptModelObject.status == 'Booked'
                        ? questionDialogue(
                            context,
                            'Do you really want to cancel this appointment?',
                            'Cancel Appointment', () {
                            widget.theFunc(
                              widget.apptModelObject.id ?? 0,
                              widget.apptModelObject.clinic!.id ?? 0,
                              widget.apptModelObject.doctor!.user!.id ?? 0,
                              patient.user!.id ?? 0,
                            );
                          })
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookAppt(
                                doctorId: widget.apptModelObject.doctor!.user!.id ?? 0,
                                clinicId: widget.apptModelObject.clinic!.id ?? 0,
                                docotorName:
                                    "${widget.apptModelObject.doctor!.title!.title} ${widget.apptModelObject.doctor!.user!.name}",
                              ),
                            ),
                          ),
                    icon: Icon(
                      widget.apptModelObject.status == 'Booked'
                          ? Icons.clear
                          : CupertinoIcons.calendar_badge_minus,
                      color:
                          widget.apptModelObject.status == 'Booked' ? Colors.red : Colors.blue[900],
                      size: 20,
                    ),
                    label: Text(
                      widget.apptModelObject.status == 'Booked' ? 'Cancel Appt' : "Book Appt",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          color: widget.apptModelObject.status == 'Booked'
                              ? Colors.red
                              : Colors.blue[900]),
                    )),
                const Text(
                  '|',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(140, 35),
                    ),
                    onPressed: () => _getApptDetails(widget.apptModelObject.id!),
                    icon: Icon(
                      Icons.view_comfy_rounded,
                      size: 19,
                      color: Colors.blue[900],
                    ),
                    label: Text(
                      'View Summary',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _getApptDetails(int theId) async {
    final _apptDetailResponse =
        await HttpService().getRequest(endPoint: APPT_DETAIL_CANCEL + '$theId/', isAuth: true);

    if (!_apptDetailResponse.error) {
      try {
        final apptObject = ApptModel.fromJson(_apptDetailResponse.data);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BookingDetails(apptModel: apptObject)));
      } catch (e) {
        infoNoOkDialogue(
            context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);

      if (_apptDetailResponse.errorMessage == NO_INTERNET_CONNECTION) {
        infoNoOkDialogue(
            context, GlobalVariable.INTERNET_ISSUE_CONTENT, GlobalVariable.INTERNET_ISSUE_TITLE);
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    }
  }
}
