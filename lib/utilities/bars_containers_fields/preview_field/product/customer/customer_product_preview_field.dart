part of '../../preview_field.dart';

class CustomerProductPreviewField extends StatefulWidget {
  final LocationProduct product;

  const CustomerProductPreviewField({super.key, required this.product});

  @override
  State<CustomerProductPreviewField> createState() => _CustomerProductPreviewFieldState();
}

class _CustomerProductPreviewFieldState extends State<CustomerProductPreviewField> {
  @override
  Widget build(BuildContext context) {
    final LocationProduct product = widget.product;
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallImageContainer.fromImageUrl(product.media.media.first?.url),
            LivitText(product.name),
          ],
        ),
      ),
    );
  }
}