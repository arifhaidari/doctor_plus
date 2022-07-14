import 'package:flutter/material.dart';

class PlaceHolder extends StatelessWidget {
  final String title;
  final String body;
  const PlaceHolder({Key? key, required this.title, required this.body
      // this.title = 'No Item', this.body = 'Add Item To Start'
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        Center(
          child: Container(
            width: mQuery.width * 0.90,
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              body,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
