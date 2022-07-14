import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class LoadingPlaceHolder extends StatelessWidget {
  const LoadingPlaceHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey,
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(Palette.blueAppBar),
          // valueColor: AnimatedColor,
        ),
      ),
    );
  }
}
