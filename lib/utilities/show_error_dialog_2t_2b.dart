import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
//import 'dart:developer' as devtools show log;

Future<void> showErrorDialog2b(
  List contextList,
  String title,
  String body,
  List button1,
  List button2,
) async {
  BuildContext? context = contextList[0]?.currentContext ?? contextList[1];
  if ((context != null) && (context.mounted)) {
    showDialog<bool>(
      context: context,
      barrierColor: const Color.fromARGB(150, 0, 0, 0),
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: LivitColors.mainBlack,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(77, 255, 255, 255),
                  blurRadius: 9,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: button1[1],
                      child: Text(
                        button1[0],
                        style: const TextStyle(
                          color: LivitColors.mainBlueActive,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: button2[1],
                      child: Text(
                        button2[0],
                        style: const TextStyle(
                          color: LivitColors.mainBlueActive,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
