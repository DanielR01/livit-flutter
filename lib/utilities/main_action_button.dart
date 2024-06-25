import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';

class MainActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;

  const MainActionButton({
    super.key,
    required this.text,
    required this.isActive,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            LivitColors.mainBlueActive,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: LivitColors.mainBlack,
          ),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
            side: const BorderSide(
          color: LivitColors.borderGray,
        )),
        child: Text(
          text,
          style: const TextStyle(
            color: LivitColors.borderGray,
          ),
        ),
      );
    }
  }
}
