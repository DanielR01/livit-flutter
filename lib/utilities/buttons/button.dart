import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/livit_text.dart';

enum ButtonType {
  main,
  secondary,
  secondaryRed,
  whiteText,
  redText,
  blueText,
  mainRed,
}

class Button extends StatefulWidget {
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
  final Color? activeShadowColor;
  final Color? inactiveBackgroundColor;
  final Color? inactiveTextColor;
  final Color? inactiveShadowColor;

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
      case ButtonType.secondaryRed:
        return Button.secondaryRed(
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
    bool isLoading = false,
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
      isLoading: isLoading,
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
    bool isLoading = false,
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

  factory Button.secondaryRed({
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
      activeTextColor: LivitColors.red,
      inactiveBackgroundColor: LivitColors.mainBlack,
      inactiveTextColor: LivitColors.whiteInactive,
      activeShadowColor: LivitColors.red,
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

    final List<BoxShadow> boxShadow = widget.isActive && widget.isShadowActive
        ? [
            widget.blueStyle
                ? LivitShadows.activeBlueShadow
                : (widget.activeShadowColor != null)
                    ? LivitShadows.shadow(widget.activeShadowColor!)
                    : LivitShadows.activeWhiteShadow
          ]
        : (widget.isShadowActive ? [widget.blueStyle ? LivitShadows.inactiveBlueShadow : LivitShadows.inactiveWhiteShadow] : []);

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
                minWidth: _calculateMinWidth(context, textColor),
              ),
              child: Material(
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: LivitButtonStyle.radius,
                ),
                child: InkWell(
                  borderRadius: LivitButtonStyle.radius,
                  onTap: (widget.isActive && !widget.isLoading) ? widget.onPressed : null,
                  child: Padding(
                    padding: LivitButtonStyle.padding,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LivitText(
                            widget.text,
                            textStyle: TextType.regular,
                            color: textColor,
                            fontWeight: widget.bold ? FontWeight.bold : null,
                          ),
                          if (widget.isLoading)
                            AnimatedBuilder(
                              animation: _dotsAnimation,
                              builder: (context, child) {
                                return LivitText(
                                  '.' * _dotsAnimation.value,
                                  textStyle: TextType.regular,
                                  color: textColor,
                                  fontWeight: widget.bold ? FontWeight.bold : null,
                                );
                              },
                            ),
                        ],
                      ),
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
        text: widget.text + '...',
        style: TextStyle(
          fontSize: LivitTextStyle.regularFontSize,
          fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.width + LivitButtonStyle.paddingValue * 2;
  }
}
