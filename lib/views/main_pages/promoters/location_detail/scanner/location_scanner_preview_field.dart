import 'package:flutter/cupertino.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';

class LocationScannerPreviewField extends StatelessWidget {
  final CloudScanner scanner;
  const LocationScannerPreviewField({super.key, required this.scanner});

  @override
  Widget build(BuildContext context) {
    return LivitBar.touchable(
      shadowType: ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LivitText(scanner.name, textType: LivitTextType.smallTitle),
            LivitSpaces.xs,
            LivitText(scanner.email),
          ],
        ),
      ),
      onTap: () {},
    );
  }
}
