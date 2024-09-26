import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';

class TitleBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final String title;
  final bool isBackEnabled;
  const TitleBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.isBackEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16.sp,
      ),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: LivitButtonStyle.horizontalPadding * 2,
            child: LivitText(
              title,
              textStyle: TextType.normalTitle,
            ),
          ),
          isBackEnabled
              ? Positioned(
                  left: 0,
                  child: ArrowBackButton(
                    onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
