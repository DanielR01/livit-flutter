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
  });

  factory Button.fromType({
    required ButtonType type,
    required String text,
    required VoidCallback onPressed,
    required bool isActive,
    bool? bold,
    bool? blueStyle,
    bool? forceOnPressed,
  }) {
    switch (type) {
      case ButtonType.main:
        return Button.main(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
          forceOnPressed: forceOnPressed,
        );

      case ButtonType.secondary:
        return Button.secondary(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          blueStyle: blueStyle ?? false,
          forceOnPressed: forceOnPressed,
        );
      case ButtonType.whiteText:
        return Button.whiteText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? true,
          forceOnPressed: forceOnPressed,
        );
      case ButtonType.redText:
        return Button.redText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? true,
          forceOnPressed: forceOnPressed,
        );
      case ButtonType.blueText:
        return Button.blueText(
          text: text,
          onPressed: onPressed,
          isActive: isActive,
          bold: bold ?? false,
          forceOnPressed: forceOnPressed,
        );
      case ButtonType.mainRed:
        return Button.mainRed(
          text: text,
          isActive: isActive,
          onPressed: onPressed,
          forceOnPressed: forceOnPressed,
        );
      case ButtonType.secondaryRed:
        return Button.secondaryRed(
          text: text,
          isActive: isActive,
          onPressed: onPressed,
          forceOnPressed: forceOnPressed,
        );
    }
  }

  factory Button.main({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool blueStyle = false,
    bool isLoading = false,
    bool? forceOnPressed,
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
      forceOnPressed: forceOnPressed,
    );
  }

  factory Button.secondary({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool blueStyle = false,
    bool? forceOnPressed,
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
    );
  }

  factory Button.secondaryRed({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool blueStyle = false,
    bool? forceOnPressed,
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
    );
  }

  factory Button.redText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
    bool? forceOnPressed,
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
    );
  }

  factory Button.whiteText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
    bool? forceOnPressed,
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
    );
  }

  factory Button.blueText({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool bold = true,
    bool? forceOnPressed,
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
    );
  }

  factory Button.mainRed({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    bool? forceOnPressed,
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
                        LivitText(
                          widget.text,
                          textType: TextType.regular,
                          color: textColor,
                          fontWeight: widget.bold ? FontWeight.bold : null,
                        ),
                        if (widget.isLoading)
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _dotsAnimation,
                              builder: (context, child) {
                                return LivitText(
                                  '.' * _dotsAnimation.value,
                                  textType: TextType.regular,
                                  color: textColor,
                                  fontWeight: widget.bold ? FontWeight.bold : null,
                                );
                              },
                            ),
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
