import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/shadows.dart';

class DropdownButtonStyle {
    static BorderRadius borderRadius = LivitContainerStyle.borderRadius;

    static BoxShadow activeShadow = LivitShadows.activeWhiteShadow;
    static BoxShadow inactiveShadow = LivitShadows.inactiveWhiteShadow;

    static BoxDecoration activeDecoration = BoxDecoration(
      borderRadius: borderRadius,
      color: LivitColors.mainBlack,
      boxShadow: [
        activeShadow,
      ],
    );

    static BoxDecoration inactiveDecoration = BoxDecoration(
      borderRadius: borderRadius,
      color: LivitColors.mainBlack,
      boxShadow: [
        inactiveShadow,
      ],
    );

    
  }
    

