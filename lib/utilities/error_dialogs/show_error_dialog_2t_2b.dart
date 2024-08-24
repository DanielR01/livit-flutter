import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/action_button.dart';
//import 'dart:developer' as devtools show log;

Future<void> showErrorDialog2b(
  List contextList,
  String title,
  String? body,
  List button1,
  List button2,
) async {
  BuildContext? context = contextList[0]?.currentContext ?? contextList[1];
  if ((context != null) && (context.mounted)) {
    showDialog<bool>(
      context: context,
      barrierColor: const Color.fromARGB(0, 0, 0, 0),
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
                    textType: TextType.smallTitle,
                  ),
                  body == null
                      ? LivitSpaces.small8spacer
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LivitSpaces.small8spacer,
                            LivitText(body),
                            LivitSpaces.medium16spacer,
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SecondaryActionButton(
                        bold: true,
                        blueStyle: false,
                        isShadowActive: true,
                        transparent: false,
                        text: button1[0],
                        isActive: true,
                        onPressed: button1[1],
                      ),
                      SecondaryActionButton(
                        bold: true,
                        blueStyle: false,
                        isShadowActive: true,
                        transparent: false,
                        text: button2[0],
                        isActive: true,
                        onPressed: button2[1],
                      ),
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
