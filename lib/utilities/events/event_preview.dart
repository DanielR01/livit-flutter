import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/secondary_action_button.dart';

class EventPreview extends StatefulWidget {
  final LivitEvent? event;
  final LivitUser? user;
  final VoidCallback onDeletePressed;
  final bool error;
  const EventPreview({
    super.key,
    required this.event,
    required this.user,
    required this.onDeletePressed,
    this.error = false,
  });

  factory EventPreview.loading() => EventPreview(
        event: null,
        user: null,
        onDeletePressed: () {},
      );

  factory EventPreview.error() => EventPreview(
        event: null,
        user: null,
        onDeletePressed: () {},
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
    String location =
        widget.error ? 'Error' : widget.event?.location ?? 'Cargando';
    String creatorUsername =
        widget.error ? 'Error' : widget.user?.username ?? 'Cargando';
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
                LivitText(creatorUsername),
                LivitSpaces.small8spacer,
                SecondaryActionButton(
                  text: 'Eliminar',
                  isActive: true,
                  onPressed: widget.onDeletePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
