import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/models.dart';
import '../../pages/screens.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class BookingDetails extends StatefulWidget {
  final ApptModel apptModel;
  final bool isSummary;
  const BookingDetails({
    Key? key,
    required this.apptModel,
    this.isSummary = false,
  }) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  void _checkFeedback() async {
    showDialog(
        context: context,
        builder: (_) {
          return FeedbackPopup(
            apptModel: widget.apptModel,
            noteId: 0,
          );
        }).then((value) {
      try {
        if (value['is_success']) {
          setState(() {
            widget.apptModel.review = value['review'];
            widget.apptModel.feedback = value['rating'];
            widget.apptModel.isFeedbackGiven = true;
          });
        }
      } catch (e) {
        print('value fo erorororo000----');
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.apptModel.relative == null
        ? widget.apptModel.patient!.user!.name
        : widget.apptModel.relative!.user!.name;
    return WillPopScope(
      onWillPop: () async {
        widget.isSummary
            ? Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const NavScreen()))
            : Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Booking Summary',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          leading: IconButton(
            icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
            onPressed: () => widget.isSummary
                ? Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const NavScreen()))
                : Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  children: [
                    cardDetailItem(
                        widget.isSummary
                            ? "Doctor: ${widget.apptModel.doctor!.user!.name}"
                            : 'Doctor: ${widget.apptModel.doctor!.title!.title} ${widget.apptModel.doctor!.user!.name}',
                        MdiIcons.doctor),
                    cardDetailItem('Clinic: ${widget.apptModel.clinic!.clinicName}',
                        MdiIcons.hospitalBuilding),
                    cardDetailItem(
                        widget.apptModel.clinic!.address != null
                            ? "${widget.apptModel.clinic!.address ?? ''}, ${widget.apptModel.clinic!.district!.name ?? ''}, ${widget.apptModel.clinic!.city!.name ?? ''}"
                            : "Address Not Available",
                        Icons.room_outlined,
                        maxLine: 2),
                    cardDetailItem(
                        'Selected Slot: ${widget.apptModel.startApptTime} - ${widget.apptModel.endApptTime}',
                        Icons.date_range),
                    cardDetailItem(
                        'Day: ${widget.apptModel.dayPattern == null ? "Unknown" : widget.apptModel.dayPattern!.weekDay!.weekDay}',
                        MdiIcons.viewWeekOutline),
                    cardDetailItem('Date: ${widget.apptModel.apptDate}', MdiIcons.calendar),
                    cardDetailItem('Patient: $patientName', Icons.sick_outlined),
                    cardDetailItem('Status: ${widget.apptModel.status}',
                        widget.apptModel.status == 'Completed' ? Icons.done_all : Icons.done),
                    if (widget.apptModel.status == 'Booked')
                      cardDetailItem(
                          'Note: Be present at the clinic before your appointment time is started. Make sure you have your cellphone to mark visited your appointment',
                          Icons.note_add_outlined,
                          maxLine: 4),
                    if (widget.apptModel.status == 'Completed')
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_border_outlined,
                                size: 22.0,
                                color: Colors.blue[900],
                              ),
                              const SizedBox(
                                width: 3.0,
                              ),
                              RatingBarIndicator(
                                rating: widget.apptModel.isFeedbackGiven
                                    ? widget.apptModel.feedback ?? 3.5
                                    : 0.0,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Palette.blueAppBar,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                unratedColor: Colors.grey[352],
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                          cardDetailItem(
                              'Condition Treated: ${widget.apptModel.conditionTreated!.isEmpty ? "No Conditin Treated Entered" : widget.apptModel.conditionTreated!.map((e) => e.name).toList().join(",")}',
                              MdiIcons.bedOutline,
                              maxLine: 4),
                          cardDetailItem(
                              'Remarks: ${widget.apptModel.remark ?? "Remark Is Not Entered By Doctor"}',
                              CupertinoIcons.signature,
                              maxLine: 10),
                          cardDetailItem(
                              'Review: ${widget.apptModel.review ?? "No Review Has Been Given"}',
                              Icons.rate_review_outlined,
                              maxLine: 15),
                        ],
                      )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.apptModel.isFeedbackGiven && widget.apptModel.status == 'Completed')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 5.0,
                          minimumSize: const Size(165, 40),
                          onPrimary: Colors.white,
                          primary: Palette.blueAppBar,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                      onPressed: () => _checkFeedback(),
                      child: const Text(
                        'Give Feedback',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  if (!widget.apptModel.isFeedbackGiven && widget.apptModel.status == 'Completed')
                    const SizedBox(
                      width: 5,
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        minimumSize: const Size(165, 40),
                        onPrimary: Colors.white,
                        primary: Palette.blueAppBar,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                    onPressed: () => widget.isSummary
                        ? Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (_) => const NavScreen()))
                        : (widget.apptModel.status == 'Booked'
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookAppt(
                                    doctorId: widget.apptModel.doctor!.user!.id ?? 0,
                                    clinicId: widget.apptModel.clinic!.id ?? 0,
                                    docotorName:
                                        "${widget.apptModel.doctor!.title!.title} ${widget.apptModel.doctor!.user!.name}",
                                    patientName: DRAWER_DATA['full_name'] == patientName
                                        ? "Me"
                                        : patientName,
                                  ),
                                ),
                              )
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookAppt(
                                    doctorId: widget.apptModel.doctor!.user!.id ?? 0,
                                    clinicId: widget.apptModel.clinic!.id ?? 0,
                                    docotorName:
                                        "${widget.apptModel.doctor!.title!.title} ${widget.apptModel.doctor!.user!.name}",
                                  ),
                                ),
                              )),
                    child: Text(
                      widget.isSummary
                          ? 'Back Home'
                          : (widget.apptModel.status == 'Booked'
                              ? 'Reschedule'
                              : 'Book Appointment'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
