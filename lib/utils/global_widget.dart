import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
import 'utils.dart';

Widget circularLoading() {
  return const SizedBox(
      height: 40,
      width: 40,
      child: Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      )));
}

InputDecoration searchFieldDecoation(
    BuildContext context, String theHintText, TextEditingController theController) {
  return InputDecoration(
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(10),
    filled: true,
    suffixIcon: IconButton(
      icon: const Icon(Icons.cancel),
      onPressed: () {
        theController.clear();
        FocusScope.of(context).unfocus();
      },
    ),
    hintText: theHintText,
    hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.grey[500]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide.none,
    ),
  );
}

InputDecoration textFieldDesign(BuildContext context, String label,
    {bool isIcon = false, TextEditingController? theTextController}) {
  return InputDecoration(
    labelText: label,
    suffixIcon: isIcon
        ? IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Palette.imageBackground,
            ),
            onPressed: () {
              theTextController!.clear();
              FocusScope.of(context).unfocus();
            },
          )
        : null,
    labelStyle: const TextStyle(fontSize: 16, color: Palette.imageBackground),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Palette.imageBackground, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        color: Palette.blueAppBar,
        width: 1.5,
      ),
    ),
  );
}

void traditionalSnackBar(String text, context, {int duration = 2}) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: Duration(seconds: duration),
      content: Text(text),
    ));
}

ElevatedButton customElevatedButton(BuildContext context, Function? function, String title) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        elevation: 7.0,
        minimumSize: const Size(280, 43),
        onPrimary: Colors.white,
        primary: Palette.blueAppBar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
    onPressed: () {
      FocusScope.of(context).unfocus();
      function!();
    },
    child: Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
    ),
  );
}

void toastSnackBar(String text,
    {bool note = true, bool positionCenter = true, bool lenghtShort = true}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: text,
      toastLength: lenghtShort ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: positionCenter ? ToastGravity.CENTER : ToastGravity.BOTTOM,
      timeInSecForIosWeb: lenghtShort ? 2 : 4,
      backgroundColor: note ? Palette.imageBackground : Colors.red.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: 16.0);
}

Column tileText(String title, String operation) {
  return Column(
    children: [
      AutoSizeText(
        title,
        maxLines: 1,
        minFontSize: operation == 'other' ? 13 : 15,
        overflow: TextOverflow.ellipsis,
        style: operation == 'other'
            ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
            : TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
      ),
      const SizedBox(
        height: 2.0,
      ),
    ],
  );
}

Widget cardDetailItem(String text, IconData icon, {int maxLine = 1}) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: Row(children: [
      Icon(
        icon,
        size: 22.0,
        color: Colors.blue[900],
      ),
      const SizedBox(
        width: 3.0,
      ),
      Expanded(
        child: AutoSizeText(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
          minFontSize: 13,
          maxLines: maxLine,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]),
  );
}

DottedLine dashedLine(Color color) {
  return DottedLine(
    direction: Axis.horizontal,
    lineLength: double.infinity,
    lineThickness: 1.0,
    dashLength: 4.0,
    dashColor: color,
    dashRadius: 0.0,
    dashGapLength: 5.0,
    dashGapColor: Colors.transparent,
    dashGapRadius: 0.0,
  );
}

AppBar myAppBar(String title,
    {IconData icon = Icons.notifications, VoidCallback? function, bool isAction = false}) {
  return AppBar(
    title: Text(
      title,
      style:
          const TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
    ),
    backgroundColor: Palette.blueAppBar,
    actions: [
      if (isAction)
        IconButton(
          icon: Icon(
            icon,
          ),
          onPressed: function,
        ),
    ],
  );
}

Tab patientProfileTab(String text) {
  return Tab(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(width: 2, color: Palette.heavyYellow),
      ),
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          minFontSize: 13,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}
