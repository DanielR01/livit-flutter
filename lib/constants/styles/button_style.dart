import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LivitButtonStyle {
  static BorderRadius radius = BorderRadius.circular(32.sp);

  static double paddingValue = 16.sp;

  static EdgeInsets padding = EdgeInsets.symmetric(horizontal: paddingValue);

  static double iconPaddingValue = 16.sp;

  static EdgeInsets iconPadding = EdgeInsets.symmetric(horizontal: iconPaddingValue);

  static double height = 36.sp;

  static double get iconSize => 16.sp;
  static double get bigIconSize => 24.sp;
}
