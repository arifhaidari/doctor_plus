import 'package:flutter/material.dart';

class ProgressPopupDialog extends StatelessWidget {
  final String message;
  const ProgressPopupDialog({Key? key, this.message = 'Loading...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
          height: 80,
          width: 100,
          // decoration: BoxDecoration(
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 35,
                width: 35,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          )),
    );
  }
}
