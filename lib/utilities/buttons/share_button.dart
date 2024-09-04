import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            right: LivitContainerStyle.horizontalPadding,
            bottom: 10.sp,
            top: 10.sp,
          ),
          child: SizedBox(
            child: Icon(
              CupertinoIcons.share,
              color: LivitColors.mainBlueActive,
              size: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}
