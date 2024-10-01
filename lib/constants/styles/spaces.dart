import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LivitSpaces {
  static const double _goldenRatio = 1.618;
  static const double _baseSize = 16.0;

  static const double xsDouble = (_baseSize / (_goldenRatio * _goldenRatio));
  static const double sDouble = (_baseSize / _goldenRatio);
  static const double mDouble = _baseSize;
  static const double lDouble = (_baseSize * _goldenRatio);
  static const double xlDouble = (_baseSize * _goldenRatio * _goldenRatio);

  static SizedBox xs = SizedBox(
    height: xsDouble.sp,
    width: xsDouble.sp,
  );

  static SizedBox s = SizedBox(
    height: sDouble.sp,
    width: sDouble.sp,
  );

  static SizedBox m = SizedBox(
    height: mDouble.sp,
    width: mDouble.sp,
  );

  static SizedBox l = SizedBox(
    height: lDouble.sp,
    width: lDouble.sp,
  );

  static SizedBox xl = SizedBox(
    height: xlDouble.sp,
    width: xlDouble.sp,
  );
}
