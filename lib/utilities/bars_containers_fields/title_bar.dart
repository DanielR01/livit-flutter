import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
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
      color: Colors.transparent,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: LivitContainerStyle.verticalPadding,
              horizontal: LivitContainerStyle.horizontalPadding * 3,
            ),
            child: LivitText(
              title,
              textType: LivitTextType.normalTitle,
            ),
          ),
          isBackEnabled
              ? Positioned(
                  left: 0,
                  top: LivitContainerStyle.verticalPadding / 2,
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
