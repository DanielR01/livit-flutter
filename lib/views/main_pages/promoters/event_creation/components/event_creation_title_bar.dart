import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';

class EventCreationTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onEditTitle;

  const EventCreationTitleBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onEditTitle,
  });

  @override
  Widget build(BuildContext context) {
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.weak,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Button.icon(
            deactivateSplash: true,
            isActive: true,
            icon: CupertinoIcons.chevron_back,
            onTap: onBack,
          ),
          Flexible(
            child: Padding(
              padding: LivitContainerStyle.padding(),
              child: LivitText(
                title.isEmpty ? 'Titulo del nuevo evento' : title,
                textType: LivitTextType.smallTitle,
              ),
            ),
          ),
          Button.icon(
            boxShadow: [],
            isActive: true,
            icon: CupertinoIcons.pencil_circle,
            onTap: onEditTitle,
          ),
        ],
      ),
    );
  }
}

class EditTitleDialog extends StatefulWidget {
  final String initialTitle;
  final ValueChanged<String> onSave;

  const EditTitleDialog({
    super.key,
    required this.initialTitle,
    required this.onSave,
  });

  @override
  State<EditTitleDialog> createState() => _EditTitleDialogState();
}

class _EditTitleDialogState extends State<EditTitleDialog> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LivitBar(
            shadowType: ShadowType.normal,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LivitText('Editar título', textType: LivitTextType.smallTitle),
                  LivitSpaces.xs,
                  Icon(CupertinoIcons.pencil, size: LivitButtonStyle.bigIconSize, color: LivitColors.whiteActive),
                ],
              ),
            ),
          ),
          LivitSpaces.m,
          GlassContainer(
            hasPadding: false,
            child: Padding(
              padding: LivitContainerStyle.padding(),
              child: Column(
                children: [
                  LivitTextField(
                    controller: _titleController,
                    hint: 'Título del evento',
                  ),
                  LivitSpaces.m,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button.secondary(
                        text: 'Cancelar',
                        isActive: true,
                        onTap: () => Navigator.of(context).pop(),
                        rightIcon: CupertinoIcons.xmark_circle,
                      ),
                      Button.main(
                        text: 'Guardar',
                        isActive: _titleController.text.isNotEmpty,
                        onTap: () {
                          widget.onSave(_titleController.text);
                          Navigator.of(context).pop();
                        },
                        rightIcon: CupertinoIcons.checkmark_alt_circle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
