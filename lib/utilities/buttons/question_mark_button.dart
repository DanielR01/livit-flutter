import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';

class QuestionMarkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double verticalOffset;

  const QuestionMarkButton({
    super.key,
    required this.onPressed,
    this.verticalOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            top: LivitContainerStyle.verticalPadding + verticalOffset,
            left: LivitContainerStyle.horizontalPadding,
            right: LivitContainerStyle.horizontalPadding,
            bottom: LivitContainerStyle.verticalPadding,
          ),
          child: Icon(
            CupertinoIcons.question_circle_fill,
            color: LivitColors.whiteActive,
            size: 16.sp,
          ),
        ),
      ),
    );
  }
}
