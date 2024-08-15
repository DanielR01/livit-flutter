import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/text_style.dart';

class AppleLoginBar extends StatelessWidget {
  const AppleLoginBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 54.sp,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: LivitBarStyle.borderRadius,
          boxShadow: [LivitShadows.activeWhiteShadow],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: SvgPicture.asset(
                'assets/logos/apple-logo-black.svg',
                height: 54.sp,
              ),
            ),
            const LivitText(
               'Continuar con Apple',
            ),
          ],
        ),
      ),
    );
  }
}
