import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';

class GlassContainer extends StatelessWidget {
  final BorderRadius? borderRadius;
  final Widget child;
  final Color? backgroundColor;
  final double? opacity;
  final String? titleBarText;
  final Key? titleBarKey;
  final bool hasPadding;
  final bool wrapPaddingWithFlexible;

  const GlassContainer({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.opacity,
    required this.child,
    this.titleBarText,
    this.titleBarKey,
    this.hasPadding = true,
    this.wrapPaddingWithFlexible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (titleBarText != null) {
      return ClipRRect(
        borderRadius: borderRadius ?? LivitContainerStyle.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ?? LivitColors.mainBlack).withOpacity(opacity ?? 0),
              borderRadius: LivitContainerStyle.borderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleBar(title: titleBarText!, key: titleBarKey),
                if (hasPadding && wrapPaddingWithFlexible)
                  Flexible(
                    child: Padding(
                      padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                      child: child,
                    ),
                  ),
                if (hasPadding && !wrapPaddingWithFlexible)
                  Padding(
                    padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                    child: child,
                  ),
                if (!hasPadding) child,
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? LivitContainerStyle.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? LivitColors.mainBlack).withOpacity(opacity ?? 0),
            borderRadius: LivitContainerStyle.borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
