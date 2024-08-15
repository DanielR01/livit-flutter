import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/text_style.dart';

class PromoterLoginBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BuildContext parentContext;
  final VoidCallback onPressed;

  const PromoterLoginBar({
    super.key,
    required this.parentContext,
    required this.scaffoldKey,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54.sp,
        width: double.infinity,
        decoration: BoxDecoration(
          color: LivitColors.mainBlack,
          borderRadius: LivitBarStyle.borderRadius,
          boxShadow: [LivitShadows.activeWhiteShadow],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 16.sp,
              child: Icon(
                Icons.add_business_rounded,
                color: LivitColors.whiteActive,
                size: 18.sp,
              ),
            ),
            const LivitText(
              'Continuar como promocionador',
            ),
          ],
        ),
      ),
    );
  }
}
