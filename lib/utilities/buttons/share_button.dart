import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/services/firestore_storage/livit_event.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ShareEventButton extends StatelessWidget {
  final LivitEvent event;
  final bool isEnabled;

  const ShareEventButton({
    super.key,
    required this.event,
    this.isEnabled = true,
  });

  Future<void> _shareEventInfo() async {
    if (isEnabled) {
      final image = await _createImage();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/event_share.png').create();
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: 'Check out this event!');
    }
  }

  Future<Uint8List> _createImage() async {
    //TODO: Add event image, title, location, and information.

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(300, 200);
    final paint = Paint()..color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      children: [
        TextSpan(
          text: 'Event: ${event.name}\n',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        TextSpan(
          text: 'Location: ${event.locations.first.name}\n',
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ],
    );
    textPainter.layout(maxWidth: size.width - 20);
    textPainter.paint(canvas, const Offset(10, 10));

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? () => _shareEventInfo() : null,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            right: LivitContainerStyle.horizontalPadding,
            bottom: 10.sp,
            top: 10.sp,
          ),
          child: SizedBox(
            child: Icon(
              CupertinoIcons.share,
              color: isEnabled ? LivitColors.whiteActive : LivitColors.whiteInactive,
              size: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}
