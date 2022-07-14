import 'package:doctor_plus/pages/nav_screen.dart';
import 'package:flutter/material.dart';

class ErrorPlaceHolder extends StatelessWidget {
  final String errorDetail;
  final String errorTitle;
  final bool isStartPage;
  const ErrorPlaceHolder(
      {Key? key, required this.errorDetail, required this.errorTitle, this.isStartPage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Column(
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
              onPressed: () {
                if (isStartPage) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const NavScreen()));
                }
              }),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
