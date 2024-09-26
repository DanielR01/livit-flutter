import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';

class LivitContainerStyle {
  static BorderRadius radius = BorderRadius.circular(16.sp);
  static BoxShadow activeWhiteShadow = const BoxShadow(
    color: Color.fromARGB(77, 255, 255, 255),
    blurRadius: 9,
    offset: Offset(0, 0),
  );

  static double verticalPadding = 16.sp;
  static double horizontalPadding = 16.sp;

  static EdgeInsets paddingFromScreen = EdgeInsets.symmetric(
    horizontal: 10.sp,
  );

  static EdgeInsets padding(List<double?>? padding) {
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
    borderRadius: LivitContainerStyle.radius,
    color: LivitColors.mainBlack,
  );
}
