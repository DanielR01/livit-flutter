import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livit/constants/styles/container_style.dart';

class ArrowBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ArrowBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      // ignore: avoid_unnecessary_containers
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            right: LivitContainerStyle.horizontalPadding,
            bottom: 10,
            top: 10,
          ),
          child: SizedBox(
            height: 12,
            child: SvgPicture.asset(
              'assets/icons/arrow-back.svg',
              height: 12,
            ),
          ),
        ),
      ),
    );
  }
}
