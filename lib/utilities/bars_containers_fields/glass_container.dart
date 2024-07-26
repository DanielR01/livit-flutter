import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';

class GlassContainer extends StatelessWidget {
  final BorderRadius? borderRadius;
  final Widget child;
  final Color? backgroundColor;
  final double? opacity;
  const GlassContainer({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? LivitContainerStyle.radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? LivitColors.mainBlack)
                .withOpacity(opacity ?? 0.4),
            borderRadius: LivitContainerStyle.radius,
          ),
          child: child,
        ),
      ),
    );
  }
}
