part of '../../preview_field.dart';

class CustomerProductLoadingPreviewField extends StatelessWidget {
  const CustomerProductLoadingPreviewField({super.key});

  @override
  Widget build(BuildContext context) {
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Shimmer.fromColors(
        baseColor: LivitColors.whiteInactive.withOpacity(1),
        highlightColor: LivitColors.whiteActive.withOpacity(1),
        child: Padding(
          padding: LivitContainerStyle.padding(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallImageContainer.fromImageUrl(null),
              LivitSpaces.m,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          decoration: BoxDecoration(
                            color: LivitColors.whiteActive,
                            borderRadius: LivitContainerStyle.borderRadius,
                          ),
                          height: LivitTextStyle.smallTitleFontSize,
                          width: constraints.maxWidth,
                        );
                      },
                    ),
                    LivitSpaces.m,
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Icon(
                              CupertinoIcons.money_dollar_circle,
                              color: LivitColors.whiteActive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            Container(
                              decoration: BoxDecoration(
                                color: LivitColors.whiteActive,
                                borderRadius: LivitContainerStyle.borderRadius,
                              ),
                              height: LivitTextStyle.regularFontSize,
                              width: (constraints.maxWidth * 0.85) - LivitSpaces.xsDouble - LivitButtonStyle.iconSize,
                            ),
                          ],
                        );
                      },
                    ),
                    LivitSpaces.xs,
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Icon(
                              CupertinoIcons.cube_box,
                              color: LivitColors.whiteActive,
                              size: LivitButtonStyle.iconSize,
                            ),
                            LivitSpaces.xs,
                            Container(
                              decoration: BoxDecoration(
                                color: LivitColors.whiteActive,
                                borderRadius: LivitContainerStyle.borderRadius,
                              ),
                              height: LivitTextStyle.regularFontSize,
                              width: (constraints.maxWidth * 0.65) - LivitSpaces.xsDouble - LivitButtonStyle.iconSize,
                            ),
                          ],
                        );
                      },
                    ),
                    LivitSpaces.xs,
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: LivitColors.whiteActive,
                                borderRadius: LivitButtonStyle.radius,
                              ),
                              height: LivitButtonStyle.height,
                              width: (constraints.maxWidth),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
