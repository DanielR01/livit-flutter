import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
//import 'dart:developer' as devtools show log;

void showErrorDialog(GlobalKey contextKey, String title, String body) {
  BuildContext? context = contextKey.currentContext;
  if ((context != null) && (context.mounted)) {
    //devtools.log('Mounting dialog');
    showDialog(
      context: context,
      barrierColor: const Color.fromARGB(150, 0, 0, 0),
      builder: (contextOfBuilder) {
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
                TextButton(
                  onPressed: () {
                    Navigator.of(contextOfBuilder).pop();
                  },
                  child: const Text(
                    'Go back',
                    style: TextStyle(
                      color: LivitColors.mainBlueActive,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        // return AlertDialog(
        //   title: Text(title),
        //   content: Text(body),
        //   shadowColor: Colors.white,
        //   elevation: 0,
        //   backgroundColor: LivitColors.mainBlack,
        //   surfaceTintColor: LivitColors.mainBlack,
        //   actions: [
        //     TextButton(
        //       onPressed: () {
        //         Navigator.of(contextOfBuilder).pop();
        //       },
        //       child: const Text(
        //         'Go back',
        //         style: TextStyle(
        //           color: LivitColors.mainBlueActive,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ],
        //   titleTextStyle: const TextStyle(
        //     color: LivitColors.whiteActive,
        //     fontSize: 22,
        //     fontWeight: FontWeight.bold,
        //   ),
        //   contentTextStyle: const TextStyle(
        //     color: LivitColors.whiteActive,
        //     fontSize: 14,
        //     fontWeight: FontWeight.normal,
        //   ),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //     side: const BorderSide(
        //       color: LivitColors.borderGray,
        //       width: 1,
        //     ),
        //   ),
        // );
      },
    );
  } else {
    //devtools.log('Not mounted parent');
  }
}
