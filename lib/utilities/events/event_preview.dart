import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/cloud/cloud_event.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/share_button.dart';

class EventPreview extends StatefulWidget {
  final CloudEvent? event;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;
  final bool error;
  const EventPreview({
    super.key,
    required this.event,
    required this.onDeletePressed,
    required this.onEditPressed,
    this.error = false,
  });

  factory EventPreview.loading() => EventPreview(
        event: null,
        onDeletePressed: () {},
        onEditPressed: () {},
      );

  factory EventPreview.error() => EventPreview(
        event: null,
        onDeletePressed: () {},
        onEditPressed: () {},
        error: true,
      );

  @override
  State<EventPreview> createState() => _EventPreviewState();
}

class _EventPreviewState extends State<EventPreview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.error ? 'Error' : widget.event?.title ?? 'Cargando';
    String location = widget.error ? 'Error' : widget.event?.location ?? 'Cargando';
    String creatorId = widget.error ? 'Error' : widget.event?.creatorId ?? 'Cargando';
    return GlassContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(LivitContainerStyle.horizontalPadding),
            width: double.infinity,
            child: Column(
              children: [
                LivitText(
                  title,
                  textType: TextType.smallTitle,
                ),
                LivitText(location),
                LivitText(creatorId),
                LivitSpaces.small8spacer,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ShareButton(),
                    Button.blueText(
                      text: 'Editar',
                      onPressed: widget.onEditPressed,
                      isActive: widget.event != null,
                    ),
                    Button.redText(
                      text: 'Eliminar',
                      isActive: true,
                      onPressed: widget.onDeletePressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
