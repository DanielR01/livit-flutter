import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/text_style.dart';

class LivitButtonStyle {
  static BorderRadius radius = BorderRadius.circular(32);

  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: 16);

  static const double height = 33;

  static final main = _LivitButtonVariant(
    white: _LivitButtonColorVariant(
      textStyle: _LivitButtonTextStyle(
        active: LivitTextStyle(
          textColor: LivitColors.mainBlack,
        ).regularTextStyle,
        inactive: LivitTextStyle(
          textColor: LivitColors.mainBlack,
        ).regularTextStyle,
      ),
      shadow: _LivitButtonShadow(
        active: null,
        inactive: null,
      ),
      backgroundColor: _LivitButtonBackgroundColor(
        active: LivitColors.whiteActive,
        inactive: LivitColors.whiteInactive,
      ),
    ),
    blue: _LivitButtonColorVariant(
      textStyle: _LivitButtonTextStyle(
        active: LivitTextStyle(
          textColor: LivitColors.mainBlack,
        ).regularTextStyle,
        inactive: LivitTextStyle(
          textColor: LivitColors.mainBlack,
        ).regularTextStyle,
      ),
      shadow: _LivitButtonShadow(
        active: null,
        inactive: null,
      ),
      backgroundColor: _LivitButtonBackgroundColor(
        active: LivitColors.mainBlueActive,
        inactive: LivitColors.mainBlueInactive,
      ),
    ),
  );

  static final secondary = _LivitButtonVariant(
    white: _LivitButtonColorVariant(
      textStyle: _LivitButtonTextStyle(
        active: LivitTextStyle(
          textColor: LivitColors.whiteActive,
        ).regularTextStyle,
        inactive: LivitTextStyle(
          textColor: LivitColors.whiteInactive,
        ).regularTextStyle,
      ),
      shadow: _LivitButtonShadow(
        active: LivitShadows.activeWhiteShadow,
        inactive: LivitShadows.inactiveWhiteShadow,
      ),
      backgroundColor: _LivitButtonBackgroundColor(
        active: LivitColors.mainBlack,
        inactive: LivitColors.mainBlack,
      ),
    ),
    blue: _LivitButtonColorVariant(
      textStyle: _LivitButtonTextStyle(
        active: LivitTextStyle(
          textColor: LivitColors.mainBlueActive,
        ).regularTextStyle,
        inactive: LivitTextStyle(
          textColor: LivitColors.mainBlueInactive,
        ).regularTextStyle,
      ),
      shadow: _LivitButtonShadow(
        active: LivitShadows.activeBlueShadow,
        inactive: null,
      ),
      backgroundColor: _LivitButtonBackgroundColor(
        active: LivitColors.mainBlack,
        inactive: LivitColors.mainBlack,
      ),
    ),
  );
}

class _LivitButtonColorVariant {
  final _LivitButtonTextStyle textStyle;
  final _LivitButtonShadow shadow;
  final _LivitButtonBackgroundColor backgroundColor;
  _LivitButtonColorVariant({
    required this.textStyle,
    required this.shadow,
    required this.backgroundColor,
  });
}

class _LivitButtonVariant {
  final _LivitButtonColorVariant blue;
  final _LivitButtonColorVariant white;

  _LivitButtonVariant({
    required this.blue,
    required this.white,
  });
}

class _LivitButtonTextStyle {
  final TextStyle active;
  final TextStyle inactive;

  _LivitButtonTextStyle({
    required this.active,
    required this.inactive,
  });
}

class _LivitButtonShadow {
  final BoxShadow? active;
  final BoxShadow? inactive;

  _LivitButtonShadow({
    this.active,
    this.inactive,
  });
}

class _LivitButtonBackgroundColor {
  final Color active;
  final Color inactive;

  _LivitButtonBackgroundColor({
    required this.active,
    required this.inactive,
  });
}
