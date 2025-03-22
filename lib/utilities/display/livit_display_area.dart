import 'dart:io';
import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/utilities/bars_containers_fields/keyboard_dismissible.dart';

class LivitDisplayArea extends StatelessWidget {
  final Widget child;
  final bool addHorizontalPadding;
  final bool addBottomPadding;
  final bool addTopPadding;
  final Color backgroundColor;

  const LivitDisplayArea({
    super.key,
    required this.child,
    this.addHorizontalPadding = true,
    this.addBottomPadding = true,
    this.addTopPadding = true,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return KeyboardDismissible(
        child: Container(
          color: backgroundColor,
          child: Padding(
            padding: EdgeInsets.only(
              left: addHorizontalPadding ? LivitContainerStyle.paddingFromScreen.left : 0,
              right: addHorizontalPadding ? LivitContainerStyle.paddingFromScreen.right : 0,
              top: addTopPadding ? LivitContainerStyle.paddingFromScreen.top : 0,
              bottom: addBottomPadding ? LivitContainerStyle.paddingFromScreen.bottom : 0,
            ),
            child: child,
          ),
        ),
      );
    }
    return KeyboardDismissible(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: addHorizontalPadding ? LivitContainerStyle.paddingFromScreen.left : 0,
            right: addHorizontalPadding ? LivitContainerStyle.paddingFromScreen.right : 0,
          ),
          color: backgroundColor,
          child: child,
        ),
      ),
    );
  }
}
