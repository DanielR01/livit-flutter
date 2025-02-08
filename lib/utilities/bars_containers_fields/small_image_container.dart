import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';

class SmallImageContainer extends StatelessWidget {
  final String? filePath;
  static const double _goldenRatio = 1.618;
  static const double _baseSize = 16;

  const SmallImageContainer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final double height = _baseSize * pow(_goldenRatio, 4);
    final double width = height * 4 / 5;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: LivitContainerStyle.decoration,
      height: height,
      width: width,
      child: filePath != null
          ? Image.file(
              File(filePath!),
            )
          : Container(
              color: LivitColors.gray,
            ),
    );
  }
}
