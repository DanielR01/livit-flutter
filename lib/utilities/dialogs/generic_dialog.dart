import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';

typedef DialogOptionBuilder<T> = Map<String, Map<String, T?>> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  String? content,
  TextAlign? contentAlign,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T>(
    barrierColor: Colors.transparent,
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: GlassContainer(
            opacity: 1,
            child: Padding(
              padding: LivitContainerStyle.padding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LivitText(
                    title,
                    textType: LivitTextType.smallTitle,
                  ),
                  content == null
                      ? LivitSpaces.s
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LivitSpaces.m,
                            LivitText(content, textAlign: contentAlign ?? TextAlign.center),
                            LivitSpaces.l,
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: options.keys.map(
                      (optionTitle) {
                        final T value = options[optionTitle]!['return'];
                        final ButtonType buttonType = options[optionTitle]!['buttonType'];
                        return Button.fromType(
                          type: buttonType,
                          text: optionTitle,
                          isActive: true,
                          onTap: () {
                            if (value != null) {
                              Navigator.of(context).pop(value);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    ).toList(),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
