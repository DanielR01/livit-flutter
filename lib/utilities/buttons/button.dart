import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';

enum ButtonType {
  main,
  secondary,
  secondaryIcon,
  secondaryRed,
  whiteText,
  redText,
  blueText,
  mainRed,
  grayText,
  icon,
}

class Button extends StatefulWidget {
  final bool isIconBig;
  final String? text;
  final VoidCallback onTap;
  final bool isActive;
  final bool? forceOnPressed;
  final bool isLoading;
  final double? width;
  final bool blueStyle;
  final bool isShadowActive;
  final bool transparent;
  final bool bold;
  final Color? activeBackgroundColor;
  final Color? activeTextColor;
  final Color? activeShadowColor;
  final Color? inactiveBackgroundColor;
  final Color? inactiveTextColor;
  final Color? inactiveShadowColor;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final List<BoxShadow>? boxShadow;
  final bool deactivateSplash;

  const Button({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
    this.isLoading = false,
    this.width,
    this.blueStyle = false,
    this.isShadowActive = true,
    this.transparent = false,
    this.bold = false,
    this.activeBackgroundColor,
    this.activeTextColor,
    this.activeShadowColor,
    this.inactiveBackgroundColor,
    this.inactiveTextColor,
    this.inactiveShadowColor,
    this.forceOnPressed,
    this.leftIcon,
    this.rightIcon,
    this.boxShadow,
    this.deactivateSplash = false,
    this.isIconBig = false,
  });

  factory Button.fromType({
    required ButtonType type,
    required String text,
    required VoidCallback onTap,
    required bool isActive,
    bool? bold,
    bool? blueStyle,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    switch (type) {
      case ButtonType.main:
        return Button.main(
          text: text,
          onTap: onTap,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );

      case ButtonType.secondary:
        return Button.secondary(
          text: text,
          onTap: onTap,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.secondaryIcon:
        return Button.secondaryIcon(
          onTap: onTap,
          isActive: isActive,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.whiteText:
        return Button.whiteText(
          text: text,
          onTap: onTap,
          isActive: isActive,
          bold: bold ?? true,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.redText:
        return Button.redText(
          text: text,
          onTap: onTap,
          isActive: isActive,
          bold: bold ?? true,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.blueText:
        return Button.blueText(
          text: text,
          onTap: onTap,
          isActive: isActive,
          bold: bold ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.mainRed:
        return Button.mainRed(
          text: text,
          isActive: isActive,
          onTap: onTap,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.secondaryRed:
        return Button.secondaryRed(
          text: text,
          isActive: isActive,
          onTap: onTap,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.grayText:
        return Button.grayText(
          text: text,
          onTap: onTap,
          isActive: isActive,
          bold: bold ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
      case ButtonType.icon:
        return Button.icon(
          isActive: isActive,
          onTap: onTap,
          icon: rightIcon,
          forceOnPressed: forceOnPressed,
          boxShadow: boxShadow,
          deactivateSplash: deactivateSplash,
          isIconBig: isIconBig,
        );
    }
  }

  factory Button.main({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    double? width,
    bool blueStyle = false,
    bool isLoading = false,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    Color activeBackgroundColor = blueStyle ? LivitColors.mainBlueActive : LivitColors.whiteActive;
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: blueStyle,
      isShadowActive: false,
      transparent: false,
      bold: false,
      width: width,
      isLoading: isLoading,
      activeBackgroundColor: activeBackgroundColor,
      activeTextColor: LivitColors.mainBlack,
      inactiveBackgroundColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.mainBlack,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.secondary({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool isLoading = false,
    double? width,
    bool blueStyle = false,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: blueStyle,
      isShadowActive: true,
      transparent: false,
      bold: false,
      activeBackgroundColor: LivitColors.mainBlack,
      activeTextColor: LivitColors.whiteActive,
      inactiveBackgroundColor: LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
      isLoading: isLoading,
      forceOnPressed: forceOnPressed,
      width: width,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.secondaryIcon({
    required bool isActive,
    required VoidCallback onTap,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    double? width,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: null,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: true,
      transparent: false,
      bold: false,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      width: width,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.secondaryRed({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool blueStyle = false,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: blueStyle,
      isShadowActive: true,
      transparent: false,
      bold: false,
      activeBackgroundColor: LivitColors.mainBlack,
      activeTextColor: LivitColors.red,
      inactiveBackgroundColor: LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
      activeShadowColor: LivitColors.red,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.redText({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool bold = true,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    double? width,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      //activeBackgroundColor: LivitColors.red,
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.red, //LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      width: width,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.whiteText({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool bold = true,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    double? width,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.whiteActive,
      inactiveTextColor: LivitColors.whiteInactive,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      width: width,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.blueText({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool bold = true,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.mainBlueActive,
      inactiveTextColor: LivitColors.whiteInactive,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.mainRed({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: false,
      bold: true,
      activeBackgroundColor: LivitColors.red,
      activeTextColor: LivitColors.mainBlack,
      inactiveBackgroundColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.mainBlack,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.grayText({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    bool isLoading = false,
    bool bold = false,
    bool? forceOnPressed,
    IconData? leftIcon,
    IconData? rightIcon,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = false,
  }) {
    return Button(
      text: text,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.whiteInactive,
      forceOnPressed: forceOnPressed,
      isLoading: isLoading,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
    );
  }

  factory Button.icon({
    required bool isActive,
    required VoidCallback onTap,
    IconData? icon,
    bool? forceOnPressed,
    List<BoxShadow>? boxShadow,
    bool deactivateSplash = false,
    bool isIconBig = true,
    Color? activeColor,
    Color? inactiveColor,
    Color? activeBackgroundColor,
    Color? inactiveBackgroundColor,
    bool isShadowActive = false,
    bool isLoading = false,
  }) {
    return Button(
      text: null,
      onTap: onTap,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: isShadowActive,
      transparent: false,
      bold: false,
      rightIcon: icon,
      forceOnPressed: forceOnPressed,
      boxShadow: boxShadow,
      deactivateSplash: deactivateSplash,
      isIconBig: isIconBig,
      activeTextColor: activeColor ?? LivitColors.whiteActive,
      inactiveTextColor: inactiveColor ?? LivitColors.whiteInactive,
      activeBackgroundColor: activeBackgroundColor ?? LivitColors.mainBlack,
      inactiveBackgroundColor: inactiveBackgroundColor ?? LivitColors.mainBlack,
      isLoading: isLoading,
    );
  }

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isActive
        ? (widget.transparent ? Colors.transparent : widget.activeBackgroundColor ?? LivitColors.mainBlack)
        : (widget.transparent ? Colors.transparent : widget.inactiveBackgroundColor);

    final textColor = widget.isActive
        ? (widget.activeTextColor ?? (widget.blueStyle ? LivitColors.mainBlueActive : LivitColors.whiteActive))
        : (widget.inactiveTextColor ?? (widget.blueStyle ? LivitColors.mainBlueInactive : LivitColors.whiteInactive));

    final List<BoxShadow> boxShadow = widget.boxShadow ??
        (widget.isActive && widget.isShadowActive
            ? [
                widget.blueStyle
                    ? LivitShadows.activeBlueShadow
                    : (widget.activeShadowColor != null)
                        ? LivitShadows.shadow(widget.activeShadowColor!)
                        : LivitShadows.activeWhiteShadow
              ]
            : (widget.isShadowActive ? [widget.blueStyle ? LivitShadows.inactiveBlueShadow : LivitShadows.inactiveWhiteShadow] : []));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: widget.width,
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
                splashColor: widget.deactivateSplash ? Colors.transparent : null,
                highlightColor: widget.deactivateSplash ? Colors.transparent : null,
                borderRadius: LivitButtonStyle.radius,
                onTap: (widget.forceOnPressed ?? false)
                    ? widget.onTap
                    : (widget.isActive && !widget.isLoading)
                        ? widget.onTap
                        : null,
                child: Padding(
                  padding: LivitButtonStyle.padding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: widget.isLoading ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      if (widget.leftIcon != null)
                        Padding(
                          padding: EdgeInsets.only(right: 4.sp),
                          child: Icon(
                            widget.leftIcon,
                            color: textColor,
                            size: widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize,
                          ),
                        ),
                      if (widget.text != null)
                        Flexible(
                          child: LivitText(
                            widget.text!,
                            textType: LivitTextType.regular,
                            color: textColor,
                            fontWeight: widget.bold ? FontWeight.bold : null,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (widget.rightIcon != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.text != null) LivitSpaces.xs,
                            if (!widget.isLoading)
                              Icon(
                                widget.rightIcon,
                                color: textColor,
                                size: widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize,
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LivitSpaces.xs,
                                  SizedBox(
                                    width: (widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize) / 2,
                                    height: (widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize) / 2,
                                    child: CupertinoActivityIndicator(
                                      color: textColor,
                                      radius: (widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize) / 2,
                                    ),
                                  ),
                                ],
                              )
                          ],
                        )
                      else if (widget.isLoading)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.text != null) LivitSpaces.s,
                            SizedBox(
                              width: (widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize) / 2,
                              height: (widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize) / 2,
                              child: CupertinoActivityIndicator(
                                color: textColor,
                                radius: (widget.isIconBig ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize) / 2,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
