import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';

class HelpButton extends StatelessWidget {
  final VoidCallback onPressed;
  const HelpButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(LivitContainerStyle.horizontalPadding / 2),
          child: Icon(
            CupertinoIcons.question_circle_fill,
            color: LivitColors.whiteInactive,
            size: 16.sp,
          ),
        ),
      ),
    );
  }
}
