import '../../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

const double percentage = 0.7;

const Color circularColor = Palette.blueAppBar;

Widget theCircularIndicator({
  required IconData icon,
  required double thePercentage,
  required String text,
}) {
  return Center(
      // This Tween Animation Builder is Just For Demonstration, Do not use this AS-IS in Projects
      // Create and Animation Controller and Control the animation that way.
      child: CircularPercentIndicator(
    radius: 69,
    addAutomaticKeepAlive: true,
    animation: true,
    lineWidth: 6.0,
    animationDuration: 2000,
    percent: thePercentage / 100,
    progressColor: circularColor,
    center: Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: circularColor,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 42,
      ),
    ),
    footer: Column(
      children: [
        TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: (thePercentage / 100)),
            duration: const Duration(seconds: 2),
            builder: (context, double value, child) {
              int thePercentage = (value * 100).ceil();
              return Container(
                margin: const EdgeInsets.only(top: 4),
                height: 27,
                width: 52,
                child: Center(
                    child: Text(
                  '$thePercentage%',
                  style: const TextStyle(color: Colors.white),
                )),
                decoration: BoxDecoration(
                  color: circularColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    circularStrokeCap: CircularStrokeCap.round,
  ));
}
