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
}

class Button extends StatefulWidget {
  final String? text;
  final VoidCallback onPressed;
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
  final IconData? leftIcon; // New property for the left icon
  final IconData? rightIcon; // New property for the right icon
  final List<BoxShadow>? boxShadow;

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
    this.activeShadowColor,
    this.inactiveBackgroundColor,
    this.inactiveTextColor,
    this.inactiveShadowColor,
    this.forceOnPressed,
    this.leftIcon, // Add left icon to the constructor
    this.rightIcon, // Add right icon to the constructor
    this.boxShadow,
  });

  factory Button.fromType({
    required ButtonType type,
    required String text,
    required VoidCallback onPressed,
    required bool isActive,
    bool? bold,
    bool? blueStyle,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
  }) {
    switch (type) {
      case ButtonType.main:
        return Button.main(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );

      case ButtonType.secondary:
        return Button.secondary(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.secondaryIcon:
        return Button.secondaryIcon(
          onPressed: onPressed,
          isActive: isActive,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.whiteText:
        return Button.whiteText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? true,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.redText:
        return Button.redText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? true,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.blueText:
        return Button.blueText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.mainRed:
        return Button.mainRed(
          text: text,
          isActive: isActive,
          onPressed: onPressed,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.secondaryRed:
        return Button.secondaryRed(
          text: text,
          isActive: isActive,
          onPressed: onPressed,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
      case ButtonType.grayText:
        return Button.grayText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? false,
          forceOnPressed: forceOnPressed,
          leftIcon: leftIcon, // Pass left icon
          rightIcon: rightIcon, // Pass right icon
          boxShadow: boxShadow,
        );
    }
  }

  factory Button.main({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    double? width,
    bool blueStyle = false,
    bool isLoading = false,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
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
      width: width,
      isLoading: isLoading,
      activeBackgroundColor: activeBackgroundColor,
      activeTextColor: LivitColors.mainBlack,
      inactiveBackgroundColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.mainBlack,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
    );
  }

  factory Button.secondary({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    bool blueStyle = false,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
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
      isLoading: isLoading,
      forceOnPressed: forceOnPressed,
      width: width,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
    );
  }

  factory Button.secondaryIcon({
    required bool isActive,
    required VoidCallback onPressed,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
    double? width,
  }) {
    return Button(
      text: null,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: true,
      transparent: false,
      bold: false,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
      width: width,
    );
  }

  factory Button.secondaryRed({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool blueStyle = false,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
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
      activeTextColor: LivitColors.red,
      inactiveBackgroundColor: LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
      activeShadowColor: LivitColors.red,
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
    );
  }

  factory Button.redText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
    double? width,
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
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
      width: width,
    );
  }

  factory Button.whiteText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
    double? width,
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
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
      width: width,
    );
  }

  factory Button.blueText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
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
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
    );
  }

  factory Button.mainRed({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
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
      forceOnPressed: forceOnPressed,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
    );
  }

  factory Button.grayText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool bold = false,
    bool? forceOnPressed,
    IconData? leftIcon, // Add left icon parameter
    IconData? rightIcon, // Add right icon parameter
    List<BoxShadow>? boxShadow,
  }) {
    return Button(
      text: text,
      onPressed: onPressed,
      isActive: isActive,
      blueStyle: false,
      isShadowActive: false,
      transparent: true,
      bold: bold,
      activeTextColor: LivitColors.whiteInactive,
      inactiveTextColor: LivitColors.whiteInactive,
      forceOnPressed: forceOnPressed,
      isLoading: isLoading,
      leftIcon: leftIcon, // Pass left icon
      rightIcon: rightIcon, // Pass right icon
      boxShadow: boxShadow,
    );
  }

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  late AnimationController _dotsAnimationController;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _dotsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotsAnimation = IntTween(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _dotsAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dotsAnimationController.dispose();
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.text != null ? _calculateMinWidth(context, textColor) : 0,
              ),
              child: Material(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: LivitButtonStyle.radius,
                ),
                child: InkWell(
                  borderRadius: LivitButtonStyle.radius,
                  onTap: (widget.forceOnPressed ?? false)
                      ? widget.onPressed
                      : (widget.isActive && !widget.isLoading)
                          ? widget.onPressed
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
                            child: Icon(widget.leftIcon, color: textColor, size: 16.sp),
                          ),
                        if (widget.text != null)
                          if (!widget.isLoading)
                            Flexible(
                              child: LivitText(
                                widget.text!,
                                textType: LivitTextType.regular,
                                color: textColor,
                                fontWeight: widget.bold ? FontWeight.bold : null,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LivitText(
                                  widget.text!,
                                  textType: LivitTextType.regular,
                                  color: textColor,
                                  fontWeight: widget.bold ? FontWeight.bold : null,
                                ),
                                AnimatedBuilder(
                                  animation: _dotsAnimation,
                                  builder: (context, child) {
                                    return LivitText(
                                      '.' * _dotsAnimation.value,
                                      textType: LivitTextType.regular,
                                      color: textColor,
                                      fontWeight: widget.bold ? FontWeight.bold : null,
                                    );
                                  },
                                ),
                              ],
                            ),
                        if (widget.rightIcon != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.text != null) LivitSpaces.xs,
                              Icon(widget.rightIcon, color: textColor, size: 16.sp),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateMinWidth(BuildContext context, Color textColor) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '${widget.text}...',
        style: TextStyle(
          fontSize: LivitTextStyle.regularFontSize,
          fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.width +
        LivitButtonStyle.paddingValue * 2 +
        (widget.leftIcon != null ? 16 + LivitSpaces.xsDouble : 0) +
        (widget.rightIcon != null ? 16 + LivitSpaces.xsDouble : 0);
  }
}
