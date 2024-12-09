import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';

enum ShadowType {
  strong,
  normal,
  weak, none,
}

class LivitBar extends StatelessWidget {
  final Widget child;
  final ShadowType shadowType;
  final bool noPadding;
  const LivitBar({super.key, required this.child, this.shadowType = ShadowType.normal, this.noPadding = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: LivitBarStyle.height),
      decoration: shadowType == ShadowType.strong
          ? LivitBarStyle.strongShadowDecoration
          : shadowType == ShadowType.normal
              ? LivitBarStyle.normalShadowDecoration
              : shadowType == ShadowType.weak
                  ? LivitBarStyle.weakShadowDecoration
                  : LivitBarStyle.normalDecoration,
      child: Padding(
        padding: noPadding ? EdgeInsets.zero : LivitContainerStyle.padding(),
        child: child,
      ),
    );
  }
}
