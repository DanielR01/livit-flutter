import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';

class LivitRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const LivitRefreshIndicator({super.key, required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: LivitColors.whiteActive,
      backgroundColor: LivitColors.mainBlack,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
