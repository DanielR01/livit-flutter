import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';

class Bar extends StatelessWidget {
  final Widget child;
  final bool shadow;
  const Bar({super.key, required this.child, this.shadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: LivitBarStyle.height,
      decoration: shadow
          ? LivitBarStyle.shadowDecoration
          : LivitBarStyle.normalDecoration,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: child,
      ),
    );
  }
}
