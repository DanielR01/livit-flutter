import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: LivitText(title),
        content: LivitText(content),
        actions: options.keys.map(
          (optionTitle) {
            final T value = options[optionTitle];
            return MainActionButton(
              text: optionTitle,
              isActive: true,
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
            );
          },
        ).toList(),
      );
    },
  );
}
