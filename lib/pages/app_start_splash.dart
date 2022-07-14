import 'package:flutter/material.dart';
import '../utils/utils.dart';

class StartSplashScreen extends StatelessWidget {
  const StartSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        // height: mQuery.height,
        // width: mQuery.width,
        // color: Palette.darkPurple,
        backgroundColor: Palette.darkPurple,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Center(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: const BoxDecoration(
                      // shape: BoxShape.circle,
                      color: Palette.darkPurple,
                    ),
                    child: Container(
                      height: 150,
                      // width: mQuery.width,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(GlobalVariable.LOGIN_BACKGROUND),
                            fit: BoxFit.fitHeight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
                child: SizedBox(
              width: mQuery.width * 0.75,
              child: Column(
                children: const [
                  Text(
                    'DOCTOR PLUS',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Best Doctor, Best Treatment',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
              // semanticsLabel: 'Semantic Lable',
              // semanticsValue: 'Semantic Value',
              // value: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
          ],
        ));
  }
}
