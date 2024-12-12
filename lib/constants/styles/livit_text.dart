// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';

enum LivitTextType {
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
  final LivitTextType textType;
  final String text;
  final TextAlign textAlign;
  final bool isLineThrough;
  final TextOverflow? overflow;

  const LivitText(
    this.text, {
    super.key,
    this.color = LivitColors.whiteActive,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.textType = LivitTextType.regular,
    this.textAlign = TextAlign.center,
    this.isLineThrough = false,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    const String fontFamily = 'HelveticaNowDisplay';
    late double _fontSize;
    late FontWeight _fontWeight;
    late double? _height;

    switch (textType) {
      case LivitTextType.small:
        _fontSize = fontSize ?? LivitTextStyle.smallFontSize;
        _fontWeight = fontWeight ?? FontWeight.w500;
        _height = null;
        break;
      case LivitTextType.regular:
        _fontSize = fontSize ?? LivitTextStyle.regularFontSize;
        _fontWeight = fontWeight ?? FontWeight.w500;
        _height = 1.2;
        break;
      case LivitTextType.smallTitle:
        _fontSize = fontSize ?? LivitTextStyle.smallTitleFontSize;
        _fontWeight = fontWeight ?? FontWeight.bold;
        _height = 1.2;
        break;
      case LivitTextType.normalTitle:
        _fontSize = fontSize ?? LivitTextStyle.normalTitleFontSize;
        _fontWeight = fontWeight ?? FontWeight.bold;
        _height = 1.2;
        break;
      case LivitTextType.bigTitle:
        _fontSize = fontSize ?? LivitTextStyle.bigTitleFontSize;
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
      overflow: overflow,
    );
  }
}

class LivitTextStyle {
  static const double _goldenRatio = 1.618;
  static final double regularFontSize = 13.sp;
  static final double smallFontSize = regularFontSize * (_goldenRatio - 1) * 1.5;
  static final double smallTitleFontSize = regularFontSize * (_goldenRatio - 1) * 2;
  static final double normalTitleFontSize = regularFontSize * (_goldenRatio - 1) * 3;
  static final double bigTitleFontSize = regularFontSize * (_goldenRatio - 1) * 5;

  static TextStyle regularWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontWeight: FontWeight.w500,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: regularFontSize,
  );
  static TextStyle regularWhiteActiveBoldText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: regularFontSize,
  );
  static TextStyle regularWhiteInactiveText = TextStyle(
    color: LivitColors.whiteInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: regularFontSize,
  );
  static TextStyle regularWhiteInactiveBoldText = TextStyle(
    color: LivitColors.whiteInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: regularFontSize,
  );
  static TextStyle regularBlackText = TextStyle(
    color: LivitColors.mainBlack,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.w500,
    fontSize: regularFontSize,
  );
  static TextStyle regularBlackBoldText = TextStyle(
    color: LivitColors.mainBlack,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: regularFontSize,
  );
  static TextStyle regularBlueActiveText = TextStyle(
    color: LivitColors.mainBlueActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: regularFontSize,
  );
  static TextStyle regularBlueBoldActiveText = TextStyle(
    color: LivitColors.mainBlueActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: regularFontSize,
    fontWeight: FontWeight.bold,
  );
  static TextStyle regularBlueInactiveText = TextStyle(
    color: LivitColors.mainBlueInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: regularFontSize,
  );
  static TextStyle regularBlueBoldInactiveText = TextStyle(
    color: LivitColors.mainBlueInactive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: regularFontSize,
    fontWeight: FontWeight.bold,
  );
  static TextStyle smallWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: smallFontSize,
  );
  static TextStyle smallWhiteActiveBoldText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontWeight: FontWeight.bold,
    fontSize: smallFontSize,
  );
  static TextStyle smallTitleWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: smallTitleFontSize,
    fontWeight: FontWeight.bold,
  );
  static TextStyle normalTitleWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: normalTitleFontSize,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bigTitleWhiteActiveText = TextStyle(
    color: LivitColors.whiteActive,
    fontFamily: 'HelveticaNowDisplay',
    fontSize: bigTitleFontSize,
    fontWeight: FontWeight.bold,
  );
}
