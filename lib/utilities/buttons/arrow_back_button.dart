import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/utilities/buttons/button.dart';

class ArrowBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isIconBig;
  const ArrowBackButton({
    super.key,
    required this.onPressed,
    this.isIconBig = true,
  });

  @override
  Widget build(BuildContext context) {
    return Button.icon(
      isActive: true,
      onTap: onPressed,
      icon: CupertinoIcons.chevron_back,
      isIconBig: isIconBig,
      boxShadow: [],
    );
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(
            LivitContainerStyle.horizontalPadding,
          ),
          child: Icon(
            CupertinoIcons.chevron_back,
            size: isIconBig! ? LivitButtonStyle.bigIconSize : LivitButtonStyle.iconSize,
            color: LivitColors.whiteActive,
          ),
        ),
      ),
    );
  }
}
