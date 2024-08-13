import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';

class LivitShadows {
  static BoxShadow inactiveWhiteShadow = const BoxShadow(
    color: Color.fromARGB(40, 255, 255, 255),
    blurRadius: 9,
    offset: Offset(0, 0),
  );

  static BoxShadow activeWhiteShadow = const BoxShadow(
    color: Color.fromARGB(77, 255, 255, 255),
    blurRadius: 9,
    offset: Offset(0, 0),
  );

  static BoxShadow strongActiveWhiteShadow = const BoxShadow(
    color: Color.fromARGB(169, 255, 255, 255),
    blurRadius: 10,
    offset: Offset(0, 0),
  );
  static BoxShadow activeBlueShadow = const BoxShadow(
    color: LivitColors.mainBlueActive,
    blurRadius: 9,
    offset: Offset(0, 0),
  );
  static BoxShadow inactiveBlueShadow = const BoxShadow(
    color: LivitColors.mainBlueInactive,
    blurRadius: 9,
    offset: Offset(0, 0),
  );
}
