part of '../../preview_field.dart';

class CustomerEventPreviewField extends StatefulWidget {
  final LivitEvent event;
  const CustomerEventPreviewField({super.key, required this.event});

  @override
  State<CustomerEventPreviewField> createState() => _CustomerEventPreviewFieldState();
}

class _CustomerEventPreviewFieldState extends State<CustomerEventPreviewField> {
  @override
  Widget build(BuildContext context) {
    final LivitEvent event = widget.event;
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallImageContainer.fromImageUrl(event.media.media.first?.url),
            LivitText(event.name),
          ],
        ),
      ),
    );
  }
}
