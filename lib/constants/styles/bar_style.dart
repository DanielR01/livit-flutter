import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/shadows.dart';

class LivitBarStyle {
  static double height = 54.sp;

  static BorderRadius borderRadius = LivitContainerStyle.radius;

  static BoxDecoration normalDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.radius,
    color: LivitColors.mainBlack,
  );

  static BoxDecoration shadowDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.radius,
    color: LivitColors.mainBlack,
    boxShadow: [
      LivitShadows.activeWhiteShadow,
    ],
  );

  static BoxDecoration strongShadowDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.radius,
    color: LivitColors.mainBlack,
    boxShadow: [
      LivitShadows.strongActiveWhiteShadow,
    ],
  );
}
