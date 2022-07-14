import '../utils/utils.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.imageBackground,
      appBar: AppBar(
        title: const Text(
          'About Us',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.imageBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: mQuery.width * 0.80,
              child: const Center(
                child: Text(
                  'Doctor Plus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: mQuery.width * 0.85,
                child: const Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: mQuery.width * 0.80,
              child: const Center(
                child: Text(
                  'Doctor Practice',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: mQuery.width * 0.85,
                child: const Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: mQuery.width * 0.80,
              child: const Center(
                child: Text(
                  'Doctor Plus Partnership With Health Ministry Of Afghanistan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: mQuery.width * 0.85,
                child: const Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: mQuery.width * 0.80,
              child: const Center(
                child: Text(
                  'Our Long Term Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: mQuery.width * 0.85,
                child: const Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: mQuery.width * 0.80,
              child: const Center(
                child: Text(
                  'Contact Us',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: mQuery.width * 0.85,
                child: const Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
