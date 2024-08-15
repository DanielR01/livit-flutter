import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/text_style.dart';

class MainActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final double? width;
  final bool blueStyle;

  const MainActionButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.width,
    this.blueStyle = false,
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
            color: widget.blueStyle
                ? LivitColors.mainBlueActive
                : LivitColors.whiteActive,
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LivitText(
                  widget.text,
                  color: LivitColors.mainBlack,
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
          color: LivitColors.whiteInactive,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: LivitTextStyle.regularBlackText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

class SecondaryActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final double? width;
  final bool blueStyle;
  final bool isShadowActive;
  final bool transparent;

  const SecondaryActionButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.width,
    this.blueStyle = false,
    this.isShadowActive = true,
    this.transparent = false,
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
            color: LivitColors.mainBlack,
            boxShadow: _boxShadow,
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.text,
                  style: widget.blueStyle
                      ? LivitTextStyle.regularBlueActiveText
                      : LivitTextStyle.regularWhiteActiveText,
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
          color: LivitColors.mainBlack,
          boxShadow: _boxShadow,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: widget.blueStyle
                    ? LivitTextStyle.regularBlueInactiveText
                    : LivitTextStyle.regularWhiteInactiveText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
