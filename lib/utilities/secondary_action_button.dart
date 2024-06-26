import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/colors.dart';

class SecondaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;
  final double? width;

  const SecondaryActionButton({
    super.key,
    required this.text,
    required this.isActive,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: width,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: LivitColors.mainBlack,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(77, 255, 255, 255),
                  blurRadius: 9,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 7.5,
                horizontal: 16,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: LivitColors.whiteActive,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: LivitColors.mainBlack,
            border: Border.all(
              color: LivitColors.borderGray,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 7.5,
              horizontal: 16,
            ),
            child: Text(
              text,
              style: const TextStyle(
                  color: LivitColors.borderGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
}
