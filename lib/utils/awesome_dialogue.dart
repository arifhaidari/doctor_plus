import '../../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:progress_dialog/progress_dialog.dart';
// future_progress_dialog: ^0.2.0 # we may use this one instead of progress dialogue

Future<void> simpleDialogueBox(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text(
            'Select Language',
            textAlign: TextAlign.center,
          ),
          children: [
            Column(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "🇺🇸",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'English',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17, color: Palette.blueAppBar),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "🇦🇫",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Pashto',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17, color: Palette.blueAppBar),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "🇦🇫",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Dari',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17, color: Palette.blueAppBar),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      });
}

// Future<ProgressDialog> progressDialogue({BuildContext? context, bool show = true}) async {
//   print('isnd ethe progressDialogue =======');
//   final pd = ProgressDialog(
//     context,
//     type: ProgressDialogType.Normal,
//     isDismissible: false,
//   );
//   pd.style(message: 'Loading...');
//   return pd;
// }

void errorDialogue(BuildContext context) {
  AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.RIGHSLIDE,
          headerAnimationLoop: false,
          title: 'Error',
          desc: 'Dialog description here..................................................',
          btnOkOnPress: () {},
          btnOkIcon: Icons.cancel,
          btnOkColor: Colors.red)
      .show();
}

void successDialogue(BuildContext context) {
  AwesomeDialog(
    context: context,
    animType: AnimType.LEFTSLIDE,
    headerAnimationLoop: false,
    dialogType: DialogType.SUCCES,
    title: 'Succes',
    desc: 'Dialog description here..................................................',
    btnOkOnPress: () {
      debugPrint('OnClcik');
    },
    btnOkIcon: Icons.check_circle,
    // onDissmissCallback: () {
    //   debugPrint('Dialog Dissmiss from callback');
    // }
  ).show();
}

void infoSmallWidthDialogue(BuildContext context) {
  AwesomeDialog(
    context: context,
    borderSide: const BorderSide(color: Colors.green, width: 2),
    width: 280,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
    headerAnimationLoop: false,
    animType: AnimType.BOTTOMSLIDE,
    title: 'INFO',
    desc: 'Dialog description here...',
    showCloseIcon: true,
    btnCancelOnPress: () {},
    btnOkOnPress: () {},
  ).show();
}

void warningDialogue(BuildContext context, String desc, String title) {
  AwesomeDialog(
    context: context,
    keyboardAware: true,
    dismissOnBackKeyPress: true,
    dialogType: DialogType.WARNING,
    animType: AnimType.BOTTOMSLIDE,
    // btnCancelText: "Cancel Order",
    // btnOkText: "Yes, I will pay",
    title: title,
    padding: const EdgeInsets.all(16.0),
    desc: desc,
    btnCancelOnPress: () {},
    btnOkOnPress: () {},
  ).show();
}

void warningShortDialogue(BuildContext context) {
  AwesomeDialog(
          context: context,
          dialogType: DialogType.WARNING,
          headerAnimationLoop: false,
          animType: AnimType.TOPSLIDE,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Warning',
          desc: 'Dialog description here..................................................',
          btnCancelOnPress: () {},
          btnOkOnPress: () {})
      .show();
}

void autoHideInfoDialogue(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.INFO,
    animType: AnimType.SCALE,
    title: 'Auto Hide Dialog',
    desc: 'AutoHide after 2 seconds',
    autoHide: const Duration(seconds: 2),
  ).show();
}

void questionDialogue(BuildContext context, String description, String title, Function function) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.QUESTION,
    headerAnimationLoop: false,
    animType: AnimType.BOTTOMSLIDE,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
          ),
        ),
      ],
    ),
    buttonsTextStyle: const TextStyle(color: Colors.black),
    showCloseIcon: true,
    btnCancelOnPress: () {
      if (title == 'Not Today') {
        Navigator.of(context).pop({'error': false, 'message': 'Appt is not marked as visited'});
      }
    },
    btnOkOnPress: () {
      function();
    },
  ).show();
}

void infoNoOkDialogue(BuildContext context, String desc, String title) {
  AwesomeDialog(
    context: context,
    headerAnimationLoop: true,
    animType: AnimType.BOTTOMSLIDE,
    // title: title,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17.0),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    ),
    // desc: desc,
  ).show();
}

void formDataDialogue(BuildContext context) {
  AwesomeDialog(
    context: context,
    animType: AnimType.SCALE,
    dialogType: DialogType.INFO,
    keyboardAware: true,
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(
            'Form Data',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            elevation: 0,
            color: Colors.blueGrey.withAlpha(40),
            child: TextFormField(
              autofocus: true,
              minLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Title',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            elevation: 0,
            color: Colors.blueGrey.withAlpha(40),
            child: TextFormField(
              autofocus: true,
              keyboardType: TextInputType.multiline,
              // maxLengthEnforced: true,
              minLines: 2,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Description',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AnimatedButton(
              text: 'Close',
              pressEvent: () {
                // dialog.dissmiss();
              })
        ],
      ),
    ),
  ).show();
}
