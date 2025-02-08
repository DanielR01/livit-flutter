import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/shadows.dart';

class LivitContainerStyle {
  static BorderRadius borderRadius = BorderRadius.circular(16.sp);

  static double verticalPadding = 16.sp;
  static double horizontalPadding = 16.sp;

  static EdgeInsets paddingFromScreen = EdgeInsets.symmetric(
    horizontal: 10.sp,
    vertical: 10.sp,
  );

  static EdgeInsets horizontalPaddingFromScreen = EdgeInsets.symmetric(
    horizontal: 10.sp,
  );

  static EdgeInsets padding({List<double?>? padding}) {
    if (padding == null) {
      return EdgeInsets.all(verticalPadding);
    } else {
      return EdgeInsets.only(
        top: padding[0] ?? verticalPadding,
        right: padding[1] ?? horizontalPadding,
        bottom: padding[2] ?? verticalPadding,
        left: padding[3] ?? horizontalPadding,
      );
    }
  }

  static BoxDecoration decoration = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
  );

  static BoxDecoration decorationWithActiveShadow = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
    boxShadow: [LivitShadows.activeWhiteShadow],
  );

  static BoxDecoration decorationWithInactiveShadow = BoxDecoration(
    borderRadius: LivitContainerStyle.borderRadius,
    color: LivitColors.mainBlack,
    boxShadow: [LivitShadows.inactiveWhiteShadow],
  );
}
