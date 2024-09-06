import 'package:flutter/material.dart';
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

class Button extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
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
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  List<BoxShadow> _boxShadow = [];
  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      if (widget.isShadowActive) {
        if (widget.blueStyle) {
          _boxShadow = [LivitShadows.activeBlueShadow];
        } else {
          _boxShadow = [LivitShadows.activeWhiteShadow];
        }
      }
      return GestureDetector(
        child: Container(
          width: widget.width,
          height: LivitButtonStyle.height,
          decoration: BoxDecoration(
            borderRadius: LivitButtonStyle.radius,
            color: widget.transparent ? Colors.transparent : widget.activeBackgroundColor ?? LivitColors.mainBlack,
            boxShadow: _boxShadow,
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LivitText(
                  widget.text,
                  textType: TextType.regular,
                  color: widget.activeTextColor ?? (widget.blueStyle ? LivitColors.mainBlueActive : LivitColors.whiteActive),
                  fontWeight: widget.bold ? FontWeight.bold : null,
                )
              ],
            ),
          ),
        ),
        onTap: () async {
          widget.onPressed();
        },
      );
    } else {
      if (widget.isShadowActive) {
        if (widget.blueStyle) {
          _boxShadow = [LivitShadows.inactiveBlueShadow];
        } else {
          _boxShadow = [LivitShadows.inactiveWhiteShadow];
        }
      }
      return Container(
        width: widget.width,
        height: LivitButtonStyle.height,
        decoration: BoxDecoration(
          borderRadius: LivitButtonStyle.radius,
          color: widget.transparent ? Colors.transparent : widget.inactiveBackgroundColor,
          boxShadow: _boxShadow,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LivitText(
                widget.text,
                color: widget.inactiveTextColor ?? (widget.blueStyle ? LivitColors.mainBlueInactive : LivitColors.whiteInactive),
                fontWeight: widget.bold ? FontWeight.bold : null,
              ),
            ],
          ),
        ),
      );
    }
  }
}
