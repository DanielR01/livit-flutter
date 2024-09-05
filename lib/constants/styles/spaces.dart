import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LivitSpaces {
  static const double _goldenRatio = 1.618;
  static const double _baseSize = 16.0;

  static SizedBox xs = SizedBox(
    height: (_baseSize / (_goldenRatio * _goldenRatio)).sp,
    width: (_baseSize / (_goldenRatio * _goldenRatio)).sp,
  );

  static SizedBox s = SizedBox(
    height: (_baseSize / _goldenRatio).sp,
    width: (_baseSize / _goldenRatio).sp,
  );

  static SizedBox m = SizedBox(
    height: _baseSize.sp,
    width: _baseSize.sp,
  );

  static SizedBox l = SizedBox(
    height: (_baseSize * _goldenRatio).sp,
    width: (_baseSize * _goldenRatio).sp,
  );

  static SizedBox xl = SizedBox(
    height: (_baseSize * _goldenRatio * _goldenRatio).sp,
    width: (_baseSize * _goldenRatio * _goldenRatio).sp,
  );
}
