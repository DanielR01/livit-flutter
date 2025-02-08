import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/shadows.dart';

enum ShadowType {
  strong,
  normal,
  weak,
  none,
}

class LivitBarStyle {
  static double height = 54.sp;

  static BorderRadius borderRadius = LivitContainerStyle.borderRadius;

  static BoxDecoration decoration({bool isTransparent = false, ShadowType shadowType = ShadowType.normal}) {
    late final Color color;
    if (isTransparent) {
      color = Colors.transparent;
    } else {
      color = LivitColors.mainBlack;
    }
    return BoxDecoration(
      borderRadius: borderRadius,
      color: color,
      boxShadow: shadowType == ShadowType.strong
          ? [LivitShadows.strongActiveWhiteShadow]
          : shadowType == ShadowType.normal
              ? [LivitShadows.activeWhiteShadow]
              : shadowType == ShadowType.weak
                  ? [LivitShadows.inactiveWhiteShadow]
                  : null,
    );
  }

  static BoxDecoration normalDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
  );

  static BoxDecoration weakShadowDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
    boxShadow: [
      LivitShadows.inactiveWhiteShadow,
    ],
  );

  static BoxDecoration normalShadowDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
    boxShadow: [
      LivitShadows.activeWhiteShadow,
    ],
  );

  static BoxDecoration strongShadowDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
    boxShadow: [
      LivitShadows.strongActiveWhiteShadow,
    ],
  );

  static BoxDecoration disabledShadowDecoration = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
    boxShadow: [
      LivitShadows.inactiveWhiteShadow,
    ],
  );
}
