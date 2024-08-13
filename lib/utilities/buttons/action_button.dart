import 'package:flutter/material.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/colors.dart';
import 'package:path/path.dart';

class ActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final double? width;
  final bool mainAction;
  final bool blueStyle;
  final bool isShadowActive;

  const ActionButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.width,
    required this.mainAction,
    this.blueStyle = false,
    this.isShadowActive = true,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late Color buttonColor;
  late TextStyle textStyle;
  late BoxShadow? shadow;
  late List<BoxShadow>? shadowList;

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      buttonColor = widget.blueStyle
          ? widget.mainAction
              ? LivitButtonStyle.main.blue.backgroundColor.active
              : LivitButtonStyle.secondary.blue.backgroundColor.active
          : widget.mainAction
              ? LivitButtonStyle.main.white.backgroundColor.active
              : LivitButtonStyle.secondary.white.backgroundColor.active;
      textStyle = widget.blueStyle
          ? widget.mainAction
              ? LivitButtonStyle.main.blue.textStyle.active
              : LivitButtonStyle.secondary.blue.textStyle.active
          : widget.mainAction
              ? LivitButtonStyle.main.white.textStyle.active
              : LivitButtonStyle.secondary.white.textStyle.active;
      shadow = widget.mainAction
          ? widget.blueStyle
              ? LivitButtonStyle.main.blue.shadow.active
              : LivitButtonStyle.main.white.shadow.active
          : widget.blueStyle
              ? LivitButtonStyle.secondary.blue.shadow.active
              : LivitButtonStyle.secondary.white.shadow.active;
      shadow == null || !widget.isShadowActive
          ? shadowList = []
          : shadowList = [shadow!];
      return GestureDetector(
        child: Container(
          width: widget.width,
          height: LivitButtonStyle.height,
          decoration: BoxDecoration(
            borderRadius: LivitButtonStyle.radius,
            color: buttonColor,
            boxShadow: shadowList,
          ),
          child: Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.text,
                  style: textStyle,
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
      buttonColor = widget.blueStyle
          ? widget.mainAction
              ? LivitButtonStyle.main.blue.backgroundColor.inactive
              : LivitButtonStyle.secondary.blue.backgroundColor.inactive
          : widget.mainAction
              ? LivitButtonStyle.main.white.backgroundColor.inactive
              : LivitButtonStyle.secondary.white.backgroundColor.inactive;
      textStyle = widget.blueStyle
          ? widget.mainAction
              ? LivitButtonStyle.main.blue.textStyle.inactive
              : LivitButtonStyle.secondary.blue.textStyle.inactive
          : widget.mainAction
              ? LivitButtonStyle.main.white.textStyle.inactive
              : LivitButtonStyle.secondary.white.textStyle.inactive;

      shadow = widget.mainAction
          ? widget.blueStyle
              ? LivitButtonStyle.main.blue.shadow.inactive
              : LivitButtonStyle.main.white.shadow.inactive
          : widget.blueStyle
              ? LivitButtonStyle.secondary.blue.shadow.inactive
              : LivitButtonStyle.secondary.white.shadow.inactive;
      shadow == null || !widget.isShadowActive
          ? shadowList = []
          : shadowList = [shadow!];

      return Container(
        width: widget.width,
        height: LivitButtonStyle.height,
        decoration: BoxDecoration(
          borderRadius: LivitButtonStyle.radius,
          color: buttonColor,
          boxShadow: shadowList,
        ),
        child: Padding(
          padding: LivitButtonStyle.horizontalPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
