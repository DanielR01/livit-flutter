import 'package:flutter/material.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/colors.dart';

class MainActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final double? width;

  const MainActionButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.width,
  });

  @override
  State<MainActionButton> createState() => _MainActionButtonState();
}

class _MainActionButtonState extends State<MainActionButton> {
  Color buttonColor = LivitColors.mainBlueActive;

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      return GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: widget.width,
          height: LivitButtonStyle.height,
          decoration: BoxDecoration(
            borderRadius: LivitButtonStyle.radius,
            color: buttonColor,
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.text,
                  style: LivitButtonStyle().mainActiveTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: widget.width,
        height: LivitButtonStyle.height,
        decoration: BoxDecoration(
          borderRadius: LivitButtonStyle.radius,
          color: LivitColors.whiteInactive,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: LivitButtonStyle().mainInactiveTextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
