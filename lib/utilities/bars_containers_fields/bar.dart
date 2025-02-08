import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';

class LivitBar extends StatelessWidget {
  final Widget child;
  final ShadowType shadowType;
  final bool noPadding;
  final bool isTouchable;
  final bool isTransparent;
  final Function()? onTap;
  const LivitBar({super.key, required this.child, this.shadowType = ShadowType.normal, this.noPadding = false})
      : isTouchable = false,
        onTap = null,
        isTransparent = false;

  const LivitBar.touchable(
      {super.key,
      required this.child,
      this.shadowType = ShadowType.normal,
      this.noPadding = false,
      required this.onTap,
      this.isTouchable = true,
      this.isTransparent = false});

  @override
  Widget build(BuildContext context) {
    if (isTouchable) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: LivitBarStyle.height),
        decoration: LivitBarStyle.decoration(isTransparent: isTransparent, shadowType: shadowType),
        child: Material(
          color: isTransparent ? Colors.transparent : LivitColors.mainBlack,
          borderRadius: LivitBarStyle.borderRadius,
          child: InkWell(
            borderRadius: LivitBarStyle.borderRadius,
            onTap: onTap,
            child: child,
          ),
        ),
      );
    }

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
