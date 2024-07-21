import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/text_style.dart';

class LivitButtonStyle {
  static BorderRadius radius = BorderRadius.circular(32);

  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: 16);

  static const double height = 33;

  final mainActiveTextStyle = LivitTextStyle(
    textColor: LivitColors.mainBlack,
  ).regularTextStyle;

  final mainInactiveTextStyle = LivitTextStyle(
    textColor: LivitColors.mainBlack,
  ).regularTextStyle;

  final secondaryActiveTextStyle = LivitTextStyle(
    textColor: LivitColors.whiteActive,
  ).regularTextStyle;

  final secondaryInactiveTextStyle = LivitTextStyle(
    textColor: LivitColors.whiteInactive,
  ).regularTextStyle;
}
