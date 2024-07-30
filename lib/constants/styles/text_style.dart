import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';

class LivitTextStyle {
  final TextStyle smallTextStyle;
  final TextStyle regularTextStyle;
  final TextStyle bigTitleTextStyle;
  final TextStyle normalTitleTextStyle;

  LivitTextStyle({
    textColor = LivitColors.mainBlack,
    FontWeight? textWeight,
  })  : smallTextStyle = TextStyle(
          fontFamily: 'HelveticaNowDisplay',
          fontSize: 11,
          fontWeight: textWeight ?? FontWeight.w500,
          color: textColor,
        ),
        regularTextStyle = TextStyle(
          fontFamily: 'HelveticaNowDisplay',
          fontSize: 12,
          fontWeight: textWeight ?? FontWeight.w500,
          color: textColor,
        ),
        bigTitleTextStyle = TextStyle(
          fontFamily: 'HelveticaNowDisplay',
          fontSize: 36,
          fontWeight: textWeight ?? FontWeight.bold,
          color: textColor,
        ),
        normalTitleTextStyle = TextStyle(
          fontFamily: 'HelveticaNowDisplay',
          fontSize: 24,
          fontWeight: textWeight ?? FontWeight.bold,
          color: textColor,
        );
}
