import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/utilities/route_generator.dart';

class PhoneLoginBar extends StatelessWidget {
  const PhoneLoginBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          RouteGenerator.generateRoute(
            const RouteSettings(
              name: Routes.authRoute,
              arguments: UserType.customer,
            ),
          ),
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
