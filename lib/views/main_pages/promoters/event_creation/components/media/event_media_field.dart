import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/media/event_media_preview_player.dart';

class EventMediaField extends StatefulWidget {
  final List<LivitMediaFile> initialMedia;
  final Function(List<LivitMediaFile>)? onMediaChanged;

  const EventMediaField({
    super.key,
    required this.initialMedia,
    this.onMediaChanged,
  });

  @override
  State<EventMediaField> createState() => _EventMediaFieldState();
}

class _EventMediaFieldState extends State<EventMediaField> {
  final List<LivitMediaFile> _media = [];

  @override
  void initState() {
    super.initState();

    _media.addAll(widget.initialMedia);
  }

  @override
  void dispose() {
    super.dispose();
    for (var file in _media) {
      MediaFileCleanup.deleteFileByPath(file.filePath);
      if (file is LivitMediaVideo) {
        MediaFileCleanup.deleteFileByPath(file.cover.filePath);
      }
    }
  }

  void _notifyMediaChanged() {
    if (widget.onMediaChanged != null) {
      widget.onMediaChanged!(_media);
    }
  }

  void _showMediaPreviewDialog(int index, bool isAdding) async {
    final updatedMedia = await Navigator.push<List<LivitMediaFile>>(
      context,
      MaterialPageRoute<List<LivitMediaFile>>(
        builder: (context) => EventMediaPreviewPlayer(
          initialMedia: List.from(_media),
          index: index,
          addMedia: isAdding,
        ),
      ),
    );

    if (updatedMedia != null) {
      setState(() {
        _media.clear();
        _media.addAll(updatedMedia);
      });
      _notifyMediaChanged();
    }
  }

  Widget _buildMediaPreview(LivitMediaFile file) {
    if (file is LivitMediaImage) {
      if (file.filePath != null && file.filePath!.isNotEmpty) {
        return Image.file(
          File(file.filePath!),
          fit: BoxFit.cover,
        );
      } else if (file.url != null && file.url!.isNotEmpty) {
        return Image.network(
          file.url!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CupertinoActivityIndicator(
                radius: LivitButtonStyle.iconSize / 2,
                color: LivitColors.whiteActive,
              ),
            );
          },
        );
      }
    } else if (file is LivitMediaVideo) {
      if (file.cover.filePath != null && file.cover.filePath!.isNotEmpty) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(file.cover.filePath!),
              fit: BoxFit.cover,
            ),
            Icon(
              CupertinoIcons.play_circle_fill,
              color: LivitColors.whiteActive,
              size: LivitButtonStyle.bigIconSize,
            ),
          ],
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = _media.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final mediaDisplayWidth = (screenWidth - LivitContainerStyle.horizontalPadding * 4 - LivitSpaces.sDouble * 3) / 4;
    final mediaDisplayHeight = mediaDisplayWidth * 16 / 9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitText(
          'Agrega fotos o videos para que tus clientes puedan verlos y conocer tu evento.',
          color: LivitColors.whiteInactive,
        ),
        LivitSpaces.s,
        if (!hasMedia)
          _buildEmptyState(mediaDisplayHeight)
        else
          Wrap(
            runSpacing: LivitSpaces.sDouble,
            children: [
              ..._media.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(right: entry.key < _media.length - 1 ? LivitSpaces.sDouble : 0),
                      child: GestureDetector(
                        onTap: () => _showMediaPreviewDialog(entry.key, false),
                        child: Container(
                          width: mediaDisplayWidth,
                          height: mediaDisplayHeight,
                          decoration: LivitContainerStyle.decorationWithInactiveShadow,
                          clipBehavior: Clip.hardEdge,
                          child: _buildMediaPreview(entry.value),
                        ),
                      ),
                    ),
                  ),
              if (_media.length < 4)
                Padding(
                  padding: EdgeInsets.only(left: _media.isNotEmpty ? LivitSpaces.sDouble : 0),
                  child: _buildAddMediaButton(mediaDisplayWidth, mediaDisplayHeight),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState(double height) {
    return Column(
      children: [
        LivitBar(
          shadowType: ShadowType.weak,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: LivitColors.whiteActive,
                size: LivitButtonStyle.iconSize,
              ),
              LivitSpaces.xs,
              Flexible(
                child: LivitText(
                  'No has agregado ninguna imagen o video',
                  textType: LivitTextType.small,
                ),
              ),
            ],
          ),
        ),
        LivitSpaces.s,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Button.main(
                  isActive: true,
                  text: 'Añadir imagen o video',
                  onTap: () => _showMediaPreviewDialog(widget.initialMedia.length, true),
                  rightIcon: CupertinoIcons.photo_on_rectangle),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddMediaButton(double width, double height) {
    return GestureDetector(
      onTap: () => _showMediaPreviewDialog(widget.initialMedia.length, true),
      child: Container(
        width: width,
        height: height,
        decoration: LivitContainerStyle.decorationWithInactiveShadow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.plus_circle,
              color: LivitColors.whiteActive,
              size: LivitButtonStyle.bigIconSize,
            ),
          ],
        ),
      ),
    );
  }
}
