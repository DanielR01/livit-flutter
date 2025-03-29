import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';
import 'package:video_editor/video_editor.dart';

class CropPage extends StatelessWidget {
  const CropPage({super.key, required this.controller});

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    const debugger = LivitDebugger('CropPage');
    debugger.debPrint('build', DebugMessageType.building);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: IconButton(
                  onPressed: () => controller.rotate90Degrees(RotateDirection.left),
                  icon: const Icon(
                    Icons.rotate_left,
                    color: LivitColors.whiteActive,
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () => controller.rotate90Degrees(RotateDirection.right),
                  icon: const Icon(
                    Icons.rotate_right,
                    color: LivitColors.whiteActive,
                  ),
                ),
              )
            ]),
            const SizedBox(height: 15),
            Expanded(
              child: CropGridViewer.edit(
                controller: controller,
                rotateCropArea: false,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                flex: 2,
                child: Button.whiteText(
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                  text: "Cancelar",
                ),
              ),
              Expanded(
                flex: 4,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildCropButton(context, Fraction.fromString("9/16")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Button.main(
                  isActive: true,
                  onTap: () {
                    controller.applyCacheCrop();
                    Navigator.pop(context);
                  },
                  text: "Continuar",
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildCropButton(BuildContext context, Fraction? f) {
    if (controller.preferredCropAspectRatio != null && controller.preferredCropAspectRatio! > 1) f = f?.inverse();

    return Flexible(
      child: TextButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: controller.preferredCropAspectRatio == f?.toDouble() ? Colors.grey.shade800 : null,
          foregroundColor: controller.preferredCropAspectRatio == f?.toDouble() ? Colors.white : null,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
        onPressed: () => controller.preferredCropAspectRatio = f?.toDouble(),
        child: LivitText(f == null ? 'free' : '${f.numerator}:${f.denominator}'),
      ),
    );
  }
}
