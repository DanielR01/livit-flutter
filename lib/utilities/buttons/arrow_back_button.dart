import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/utilities/buttons/button.dart';

class ArrowBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isIconBig;
  const ArrowBackButton({
    super.key,
    required this.onPressed,
    this.isIconBig = true,
  });

  @override
  Widget build(BuildContext context) {
    return Button.icon(
      activeBackgroundColor: Colors.transparent,
      inactiveBackgroundColor: Colors.transparent,
      isActive: true,
      onTap: onPressed,
      icon: CupertinoIcons.chevron_back,
      isIconBig: isIconBig,
      boxShadow: [],
    );
  }
}
