import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/enums.dart';

class PhoneLoginBar extends StatelessWidget {
  final UserType userType;
  const PhoneLoginBar({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.loginPhoneNumberRoute,
          arguments: {'userType': userType},
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
                Icons.phone_rounded,
                color: LivitColors.whiteActive,
                size: 18.sp,
              ),
            ),
            const LivitText('Continuar con número de teléfono'),
          ],
        ),
      ),
    );
  }
}
