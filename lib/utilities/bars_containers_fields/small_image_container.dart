import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';

class SmallImageContainer extends StatelessWidget {
  final String? filePath;
  final String? imageUrl;
  final bool noImage;
  static const double _goldenRatio = 1.618;
  static const double _baseSize = 16;

  const SmallImageContainer({super.key, required this.filePath, required this.imageUrl, this.noImage = false});

  factory SmallImageContainer.fromFilePath(String? filePath) {
    return SmallImageContainer(filePath: filePath, imageUrl: null);
  }

  factory SmallImageContainer.fromImageUrl(String? imageUrl) {
    return SmallImageContainer(filePath: null, imageUrl: imageUrl);
  }

  factory SmallImageContainer.noImage() {
    return SmallImageContainer(filePath: null, imageUrl: null, noImage: true);
  }

  @override
  Widget build(BuildContext context) {
    final double height = _baseSize * pow(_goldenRatio, 4);
    final double width = height * 4 / 5;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: LivitContainerStyle.decoration,
      height: height,
      width: width,
      child: noImage
          ? Container(
              color: LivitColors.mainBlack,
              child: Center(
                child: Icon(
                  CupertinoIcons.photo,
                  color: LivitColors.whiteInactive,
                  size: LivitButtonStyle.iconSize,
                ),
              ),
            )
          : filePath != null
              ? Image.file(
                  fit: BoxFit.cover,
                  File(filePath!),
                )
              : imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CupertinoActivityIndicator(
                            radius: LivitButtonStyle.iconSize / 2,
                            color: LivitColors.whiteActive,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: LivitColors.mainBlack,
                      child: Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          color: LivitColors.whiteInactive,
                          size: LivitButtonStyle.iconSize,
                        ),
                      ),
                    ),
    );
  }
}
