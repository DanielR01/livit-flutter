import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/crud/crud_exceptions.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/action_button.dart';

class EventPreview extends StatefulWidget {
  final LivitEvent event;
  const EventPreview({
    super.key,
    required this.event,
  });

  @override
  State<EventPreview> createState() => _EventPreviewState();
}

class _EventPreviewState extends State<EventPreview> {
  late final LivitDBService _livitDBService;

  @override
  void initState() {
    _livitDBService = LivitDBService();
    super.initState();
  }

  late String _title;
  late String _location;
  late String _creatorUsername;

  Future<bool> _getEventData() async {
    final LivitEvent event = widget.event;
    try {
      final LivitUser creator =
          await _livitDBService.getUserWithId(id: event.creatorId);
      _title = event.title;
      _location = event.location;
      _creatorUsername = creator.username;

      return true;
    } on UserNotFound {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(LivitContainerStyle.horizontalPadding),
            width: double.infinity,
            child: FutureBuilder(
              future: _getEventData(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Column(
                    children: [
                      LivitText(
                        _title,
                        textType: TextType.smallTitle,
                      ),
                      LivitText(_location),
                      LivitText(_creatorUsername),
                      LivitSpaces.small8spacer,
                      SecondaryActionButton(
                        text: 'Eliminar',
                        isActive: true,
                        onPressed: () {},
                      ),
                    ],
                  );
                }
                return const Column(
                  children: [
                    LivitText(
                      "loading",
                      textType: TextType.smallTitle,
                    ),
                    LivitText("loading"),
                    LivitText("loading"),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
