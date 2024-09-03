import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';

class PromoterLoginBar extends StatelessWidget {
  const PromoterLoginBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.signInRoute,
          arguments: UserType.promoter,
        );
      },
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
