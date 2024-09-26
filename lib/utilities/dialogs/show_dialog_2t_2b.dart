import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';

Future<void> showDialog2b({
  required List contextList,
  required String title,
  String? body,
  required Widget button1,
  required Widget button2,
  int opacity = 0,
}) async {
  BuildContext? context = contextList[0]?.currentContext ?? contextList[1];
  if ((context != null) && (context.mounted)) {
    showDialog<bool>(
      context: context,
      barrierColor: Color.fromARGB(opacity, 0, 0, 0),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: GlassContainer(
            opacity: 1,
            child: Padding(
              padding: LivitContainerStyle.padding(null),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LivitText(
                    title,
                    textStyle: TextType.smallTitle,
                  ),
                  body == null
                      ? LivitSpaces.s
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LivitSpaces.s,
                            LivitText(body),
                            LivitSpaces.m,
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      button1,
                      button2,
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
