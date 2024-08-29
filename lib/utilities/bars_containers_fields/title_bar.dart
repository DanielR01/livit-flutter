import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';

class TitleBar extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isBackEnabled;
  const TitleBar({
    super.key,
    required this.title,
    this.onPressed,
    this.isBackEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 14.sp,
      ),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: LivitButtonStyle.horizontalPadding,
            child: LivitText(
              title,
              textType: TextType.normalTitle,
            ),
          ),
          isBackEnabled
              ? Positioned(
                  left: 0,
                  child: ArrowBackButton(
                    onPressed: onPressed ?? () => Navigator.of(context).pop(),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
