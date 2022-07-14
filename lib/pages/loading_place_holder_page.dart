import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class LoadingPlaceHolderPage extends StatelessWidget {
  const LoadingPlaceHolderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Loading ...',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.blueAppBar,
      ),
      body: const Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey,
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(Palette.blueAppBar),
            // valueColor: AnimatedColor,
          ),
        ),
      ),
    );
  }
}
