import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/shadows.dart';

class SecondaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;
  final double? width;
  final bool strongShadow;

  const SecondaryActionButton({
    super.key,
    required this.text,
    required this.isActive,
    this.onPressed,
    this.width,
    this.strongShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          width: width,
          height: LivitButtonStyle.height,
          decoration: BoxDecoration(
            borderRadius: LivitButtonStyle.radius,
            color: LivitColors.mainBlack,
            boxShadow: strongShadow
                ? [LivitShadows.strongActiveWhiteShadow]
                : [LivitShadows.activeWhiteShadow],
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: LivitButtonStyle().secondaryActiveTextStyle,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: width,
        height: LivitButtonStyle.height,
        decoration: BoxDecoration(
          borderRadius: LivitButtonStyle.radius,
          color: LivitColors.mainBlack,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: LivitButtonStyle().secondaryInactiveTextStyle,
              ),
            ],
          ),
        ),
      );
    }
  }
}
