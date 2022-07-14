import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class ErrorPlaceHolderPage extends StatelessWidget {
  final String errorDetail;
  final String errorTitle;
  final bool isStartPage;
  const ErrorPlaceHolderPage(
      {Key? key, required this.errorDetail, required this.errorTitle, this.isStartPage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Error',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.blueAppBar,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 120,
            ),
          ),
          Center(
              child: SizedBox(
            width: mQuery.width * 0.75,
            child: Column(
              children: [
                Text(
                  errorTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  errorDetail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )),
          Center(
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: 35,
                color: Colors.blue[900],
              ),
              onPressed: () => isStartPage
                  ? Navigator.pushReplacementNamed(context, '/')
                  : Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
