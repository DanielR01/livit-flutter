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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: verticalOffset,
          child: GestureDetector(
            onTap: onPressed,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(LivitContainerStyle.horizontalPadding),
              child: Icon(
                CupertinoIcons.question_circle_fill,
                color: LivitColors.whiteInactive,
                size: 16.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
