import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(
            LivitContainerStyle.horizontalPadding,
          ),
          child: SizedBox(
            height: 16.sp,
            width: 16.sp,
            child: SvgPicture.asset(
              'assets/icons/arrow-back.svg',
              height: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
