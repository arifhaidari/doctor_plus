import 'package:flutter/material.dart';

class Palette {
  // My Custom Colors
  static const Color blueAppBar = Color(0xFF105B8C);
  static const Color darkGreen = Color(0xFF858585);
  static const Color lightYellow = Color(0xFFF8df66);
  static const Color heavyYellow = Color(0xFFFBBC3F);
  static const Color lightGreen = Color(0xFF9D9D9D);
  static const Color red = Color(0xFFE5473E);
  static const Color black = Color(0xFF000000);
  static const Color allECollor = Color(0xFFEEEEEE);
  static const Color lighterBlue = Color(0xFFDAF1F9);
  static const Color scaffoldBackground = Color(0xFFF3F3F3);
  static const Color lightBlue = Color(0xFFBCE7F4);
  static const Color cardBackground = Color(0xFFB9B9B9);
  static const Color containerBackground = Color(0xFFF6F6F6);
  static const Color imageBackground = Color(0xFF00A9B2);
  static const Color etonBlue = Color(0xFF9BC59D);
  static const Color umber = Color(0xFF6C5A49);
  static const Color darkPurple = Color(0xFF271F30);

  // Other colors
  // static const Color scaffold = Color(0xFFF0F2F5);

  // static const Color facebookBlue = Color(0xFF1777F2);

  static const LinearGradient createRoomGradient = LinearGradient(
    colors: [Color(0xFF496AE1), Color(0xFFCE48B1)],
  );

  static const Color online = Color(0xFF4BCB1F);

  static LinearGradient regularGradient = LinearGradient(
    colors: [
      Colors.blue.withOpacity(0.2),
      Colors.purple.withOpacity(0.6),
    ],
    begin: Alignment.topCenter,
    // end: Alignment.bottomCenter,
    stops: const [0.0, 1.0],
  );

  static LinearGradient frontGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.0, 1.0],
    colors: [imageBackground.withOpacity(0.8), imageBackground],
  );

  static const LinearGradient storyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black26],
  );

  static LinearGradient tabGradient = LinearGradient(
    colors: [
      Colors.redAccent.withOpacity(0.7),
      Colors.orangeAccent,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
