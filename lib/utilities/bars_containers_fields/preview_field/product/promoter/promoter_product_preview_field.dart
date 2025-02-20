part of '../../preview_field.dart';

class PromoterProductPreviewField extends StatefulWidget {
  final LocationProduct product;

  const PromoterProductPreviewField({super.key, required this.product});

  @override
  State<PromoterProductPreviewField> createState() => _PromoterProductPreviewFieldState();
}

class _PromoterProductPreviewFieldState extends State<PromoterProductPreviewField> {
  @override
  Widget build(BuildContext context) {
    final LocationProduct product = widget.product;
    return LivitBar.touchable(
      onTap: () {},
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (product.media.media.isNotEmpty)
              SmallImageContainer.fromImageUrl(product.media.media.first?.url)
            else
              Container(
                decoration: LivitContainerStyle.decorationWithInactiveShadow,
                child: SmallImageContainer.noImage(),
              ),
            LivitSpaces.m,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LivitText(product.name, textType: LivitTextType.smallTitle),
                  // LivitText(product.description),
                  LivitSpaces.m,
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.money_dollar_circle,
                        color: LivitColors.mainBlueActive,
                        size: LivitButtonStyle.iconSize,
                      ),
                      LivitSpaces.xs,
                      LivitText('${product.price.formatPrice()} ${product.price.currency}', color: LivitColors.mainBlueActive),
                    ],
                  ),
                  LivitSpaces.xs,
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.cube_box,
                        color: LivitColors.whiteActive,
                        size: LivitButtonStyle.iconSize,
                      ),
                      LivitSpaces.xs,
                      LivitText('${product.stock} unidades'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
