import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/livit_text.dart';

enum ButtonType {
  main,
  secondary,
  whiteText,
  redText,
  blueText,
  mainRed,
}

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isLoading;
  final double? width;
  final bool blueStyle;
  final bool isShadowActive;
  final bool transparent;
  final bool bold;
  final Color? activeBackgroundColor;
  final Color? activeTextColor;
  final Color? inactiveBackgroundColor;
  final Color? inactiveTextColor;

  const Button({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.blueStyle = false,
    this.isShadowActive = true,
    this.transparent = false,
    this.bold = false,
    this.activeBackgroundColor,
    this.activeTextColor,
    this.inactiveBackgroundColor,
    this.inactiveTextColor,
  });

  factory Button.fromType({
    required ButtonType type,
    required String text,
    required VoidCallback onPressed,
    required bool isActive,
    bool? bold,
    bool? blueStyle,
  }) {
    switch (type) {
      case ButtonType.main:
        return Button.main(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
        );

      case ButtonType.secondary:
        return Button.secondary(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
        );
      case ButtonType.whiteText:
        return Button.whiteText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? true,
        );
      case ButtonType.redText:
        return Button.redText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? true,
        );
      case ButtonType.blueText:
        return Button.blueText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? false,
        );
      case ButtonType.mainRed:
        return Button.mainRed(
          text: text,
          isActive: isActive,
          onPressed: onPressed,
        );
    }
  }

  factory Button.main({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool blueStyle = false,
  }) {
    Color activeBackgroundColor = blueStyle ? LivitColors.mainBlueActive : LivitColors.whiteActive;
    return Button(
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: blueStyle,
      isShadowActive: false,
      transparent: false,
      bold: false,
      activeBackgroundColor: activeBackgroundColor,
      activeTextColor: LivitColors.mainBlack,
      inactiveBackgroundColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.mainBlack,
    );
  }

  factory Button.secondary({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool blueStyle = false,
  }) {
    return Button(
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: blueStyle,
      isShadowActive: true,
      transparent: false,
      bold: false,
      activeBackgroundColor: LivitColors.mainBlack,
      activeTextColor: LivitColors.whiteActive,
      inactiveBackgroundColor: LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
    );
  }

  factory Button.redText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
  }) {
    return Button(
      //activeBackgroundColor: LivitColors.red,
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.red, //LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
    );
  }

  factory Button.whiteText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
  }) {
    return Button(
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.whiteActive,
      inactiveTextColor: LivitColors.whiteInactive,
    );
  }

  factory Button.blueText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
  }) {
    return Button(
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.mainBlueActive,
      inactiveTextColor: LivitColors.whiteInactive,
    );
  }

  factory Button.mainRed({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Button(
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: false,
      bold: true,
      activeBackgroundColor: LivitColors.red,
      activeTextColor: LivitColors.mainBlack,
      inactiveBackgroundColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.mainBlack,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? (transparent ? Colors.transparent : activeBackgroundColor ?? LivitColors.mainBlack)
        : (transparent ? Colors.transparent : inactiveBackgroundColor);

    final textColor = isActive
        ? (activeTextColor ?? (blueStyle ? LivitColors.mainBlueActive : LivitColors.whiteActive))
        : (inactiveTextColor ?? (blueStyle ? LivitColors.mainBlueInactive : LivitColors.whiteInactive));

    final List<BoxShadow> boxShadow = isActive && isShadowActive
        ? [blueStyle ? LivitShadows.activeBlueShadow : LivitShadows.activeWhiteShadow]
        : (isShadowActive ? [blueStyle ? LivitShadows.inactiveBlueShadow : LivitShadows.inactiveWhiteShadow] : []);

    return Container(
      width: width,
      height: LivitButtonStyle.height,
      decoration: BoxDecoration(
        borderRadius: LivitButtonStyle.radius,
        color: backgroundColor,
        boxShadow: boxShadow,
      ),
      child: IntrinsicWidth(
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: LivitButtonStyle.radius,
          ),
          child: InkWell(
            borderRadius: LivitButtonStyle.radius,
            onTap: (isActive && !isLoading) ? onPressed : null,
            child: Padding(
              padding: LivitButtonStyle.horizontalPadding,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LivitText(
                      text,
                      textType: TextType.regular,
                      color: textColor,
                      fontWeight: bold ? FontWeight.bold : null,
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          color: textColor,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
