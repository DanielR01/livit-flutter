// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';

enum TextType {
  small,
  regular,
  smallTitle,
  normalTitle,
  bigTitle,
}

class LivitText extends StatelessWidget {
  final Color color;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextType textStyle;
  final String text;
  final TextAlign textAlign;
  final bool isLineThrough;

  const LivitText(
    this.text, {
    super.key,
    this.color = LivitColors.whiteActive,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.textStyle = TextType.regular,
    this.textAlign = TextAlign.center,
    this.isLineThrough = false,
  });

  @override
  Widget build(BuildContext context) {
    const String fontFamily = 'HelveticaNowDisplay';
    late double _fontSize;
    late FontWeight _fontWeight;
    late double? _height;

    switch (textStyle) {
      case TextType.small:
        _fontSize = fontSize ?? 11.sp;
        _fontWeight = fontWeight ?? FontWeight.w500;
        _height = null;
        break;
      case TextType.regular:
        _fontSize = fontSize ?? 13.sp;
        _fontWeight = fontWeight ?? FontWeight.w500;
        _height = 1.2;
        break;
      case TextType.smallTitle:
        _fontSize = fontSize ?? 18.sp;
        _fontWeight = fontWeight ?? FontWeight.bold;
        _height = 1.2;
        break;
      case TextType.normalTitle:
        _fontSize = fontSize ?? 26.sp;
        _fontWeight = fontWeight ?? FontWeight.bold;
        _height = 1.2;
        break;
      case TextType.bigTitle:
        _fontSize = fontSize ?? 36.sp;
        _fontWeight = fontWeight ?? FontWeight.bold;
        _height = 1.2;
        break;
    }
    return Text(
      textAlign: textAlign,
      text,
      style: TextStyle(
        decoration: isLineThrough ? TextDecoration.lineThrough : null,
        decorationColor: color,
        color: color,
        fontSize: _fontSize,
        fontWeight: _fontWeight,
        height: _height,
        fontFamily: fontFamily,
      ),
    );
  }
}

class LivitTextStyle {
  static TextStyle regularWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontWeight: FontWeight.w500,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 13.sp,
  );
  static TextStyle regularWhiteActiveBoldText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: 13.sp,
  );
  static TextStyle regularWhiteInactiveText = TextStyle(
    color: LivitColors.whiteInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 13.sp,
  );
  static TextStyle regularWhiteInactiveBoldText = TextStyle(
    color: LivitColors.whiteInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: 13.sp,
  );
  static TextStyle regularBlackText = TextStyle(
    color: LivitColors.mainBlack,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.w500,
    fontSize: 13.sp,
  );
  static TextStyle regularBlackBoldText = TextStyle(
    color: LivitColors.mainBlack,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: 13.sp,
  );
  static TextStyle regularBlueActiveText = TextStyle(
    color: LivitColors.mainBlueActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 13.sp,
  );
  static TextStyle regularBlueBoldActiveText = TextStyle(
    color: LivitColors.mainBlueActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 13.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle regularBlueInactiveText = TextStyle(
    color: LivitColors.mainBlueInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 13.sp,
  );
  static TextStyle regularBlueBoldInactiveText = TextStyle(
    color: LivitColors.mainBlueInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 13.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle smallWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: 12.sp,
  );
  static TextStyle smallWhiteActiveBoldText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: 12.sp,
  );
}
