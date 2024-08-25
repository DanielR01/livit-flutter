import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/text_style.dart';

class MainActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final double? width;
  final bool blueStyle;
  final Color? activeBackgroundColor;
  final Color? activeTextColor;
  final Color? inactiveBackgroundColor;
  final Color? inactiveTextColor;

  const MainActionButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.width,
    this.blueStyle = false,
    this.activeBackgroundColor,
    this.activeTextColor,
    this.inactiveBackgroundColor,
    this.inactiveTextColor,
  });

  @override
  State<MainActionButton> createState() => _MainActionButtonState();
}

class _MainActionButtonState extends State<MainActionButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      return GestureDetector(
        child: Container(
          width: widget.width,
          height: LivitButtonStyle.height,
          decoration: BoxDecoration(
            borderRadius: LivitButtonStyle.radius,
            color: widget.activeBackgroundColor ??
                (widget.blueStyle
                    ? LivitColors.mainBlueActive
                    : LivitColors.whiteActive),
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LivitText(
                  widget.text,
                  color: widget.activeTextColor ?? LivitColors.mainBlack,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          widget.onPressed();
        },
      );
    } else {
      return Container(
        width: widget.width,
        height: LivitButtonStyle.height,
        decoration: BoxDecoration(
          borderRadius: LivitButtonStyle.radius,
          color: widget.inactiveBackgroundColor ?? LivitColors.whiteInactive,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LivitText(
                widget.text,
                color: widget.inactiveTextColor ?? LivitColors.mainBlack,
              ),
            ],
          ),
        ),
      );
    }
  }
}
