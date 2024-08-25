import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/text_style.dart';

class SecondaryActionButton extends StatefulWidget {
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

  const SecondaryActionButton({
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

  @override
  State<SecondaryActionButton> createState() => _SecondaryActionButtonState();
}

class _SecondaryActionButtonState extends State<SecondaryActionButton> {
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
            color: widget.transparent
                ? Colors.transparent
                : widget.activeBackgroundColor ?? LivitColors.mainBlack,
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
                  color: widget.activeTextColor ??
                      (widget.blueStyle
                          ? LivitColors.mainBlueActive
                          : LivitColors.whiteActive),
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
          color:
              widget.transparent ? Colors.transparent : LivitColors.mainBlack,
          boxShadow: _boxShadow,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LivitText(
                widget.text,
                color: widget.inactiveTextColor ??
                    (widget.blueStyle
                        ? LivitColors.mainBlueInactive
                        : LivitColors.whiteInactive),
                fontWeight: widget.bold ? FontWeight.bold : null,
              ),
            ],
          ),
        ),
      );
    }
  }
}
