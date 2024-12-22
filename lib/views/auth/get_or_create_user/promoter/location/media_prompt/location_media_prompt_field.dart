import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/files/file_cleanup_service.dart';
import 'package:livit/services/video/video_compression_service.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/media/media_preview_player/location_media_preview_player.dart';

class LocationMediaInputField extends StatefulWidget {
  final Location location;
  final Function(LivitLocationMediaFile, Location) onMainSelected;
  final Function(LivitLocationMediaFile, Location) onSecondarySelected;
  final Function(Location) onMediaReset;
  final Function(LivitLocationMedia, Location) onMediaChanged;

  const LocationMediaInputField({
    super.key,
    required this.location,
    required this.onMainSelected,
    required this.onSecondarySelected,
    required this.onMediaReset,
    required this.onMediaChanged,
  });

  @override
  State<LocationMediaInputField> createState() => _LocationMediaInputFieldState();
}

class _LocationMediaInputFieldState extends State<LocationMediaInputField> {
  bool isDisplayingMedia = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  late double _mediaDisplayWidth;
  late double _mediaDisplayHeight;
  late double _mediaDisplayContainerHeight;

  int secondaryFilesLength = 0;
  int secondaryTilesLength = 0;

  final Map<String, String> _videoThumbnails = {};

  _calculateMediaDisplaySizes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final remainingWidth = screenWidth - LivitContainerStyle.paddingFromScreen.horizontal - LivitContainerStyle.horizontalPadding * 2;
    _mediaDisplayWidth = remainingWidth / 3;
    _mediaDisplayHeight = _mediaDisplayWidth * 16 / 9;
    final textSpan = TextSpan(
      text: 'Adicionales\n(máximo 6)', // Using the longest text between 'Principal' and 'Adicionales'
      style: TextStyle(
        fontSize: LivitTextStyle.regularFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final textHeight = textPainter.height;

    _mediaDisplayContainerHeight = _mediaDisplayHeight + LivitSpaces.sDouble * 2 + LivitContainerStyle.padding().vertical + textHeight;
  }

  @override
  void dispose() {
    FileCleanupService().cleanupTempFiles();
    for (final path in _videoThumbnails.values) {
      try {
        File(path).deleteSync();
      } catch (e) {
        debugPrint('Error deleting thumbnail: $e');
      }
    }
    _videoThumbnails.clear();
    VideoCompressionService.cleanup();
    super.dispose();
  }

  Widget _buildMediaPreview(LivitLocationMediaFile file, {bool isSmall = false}) {
    try {
      final bool isVideo = file is LivitLocationMediaVideo;
      final String? path = isVideo ? file.cover.filePath : file.filePath;

      if (path == null) return const SizedBox.shrink();

      if (isVideo) {
        return GestureDetector(
          onTap: () {
            _showMediaPreview(file);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: isSmall ? 16.sp : 24.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return GestureDetector(
          onTap: () {
            _showMediaPreview(file);
          },
          child: Image.asset(path),
        );
      }
    } catch (_) {
      return Center(
        child: Icon(
          Icons.error_outline,
          color: LivitColors.whiteInactive,
          size: 24.sp,
        ),
      );
    }
  }

  void _showMediaPreview(LivitLocationMediaFile currentMedia) async {
    if (currentMedia.filePath == null || widget.location.media == null) return;
    final result = await Navigator.push<LivitLocationMedia?>(
      context,
      MaterialPageRoute<LivitLocationMedia?>(
        builder: (context) => LocationMediaPreviewPlayer(
          locationMedia: widget.location.media!,
          currentMedia: currentMedia,
          onSave: (locationMedia) {
            widget.onMediaChanged(locationMedia, widget.location);
          },
        ),
      ),
    );
    if (result != null) {
      widget.onMediaChanged(result, widget.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateMediaDisplaySizes();
    secondaryFilesLength = widget.location.media?.secondaryFiles?.length ?? 0;
    secondaryTilesLength = min(secondaryFilesLength  + 1, 6);
    if (secondaryFilesLength + (widget.location.media?.mainFile != null ? 1 : 0) > 7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMediaReset(widget.location);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: LivitText('Máximo 7 archivos en total')));
      });
    }

    final bool isLocationMediaEmpty = widget.location.media == null ||
        (widget.location.media?.mainFile == null && (widget.location.media?.secondaryFiles?.isEmpty ?? true));

    return LivitBar(
      noPadding: true,
      shadowType: !isLocationMediaEmpty ? ShadowType.weak : ShadowType.strong,
      child: Column(
        children: [
          LivitBar(
            shadowType: !isLocationMediaEmpty ? ShadowType.weak : ShadowType.strong,
            noPadding: true,
            child: InkWell(
              onTap: () {
                setState(() {
                  isDisplayingMedia = !isDisplayingMedia;
                });
              },
              child: Padding(
                padding: LivitContainerStyle.padding(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          children: [
                            LivitText(isDisplayingMedia ? 'Ocultar' : 'Archivos', color: LivitColors.mainBlack),
                            LivitSpaces.xs,
                            Icon(
                              !isDisplayingMedia ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_up,
                              color: LivitColors.mainBlack,
                              size: 16.sp,
                            ),
                          ],
                        ),
                        LivitSpaces.xs,
                        Flexible(child: LivitText(widget.location.name, textType: LivitTextType.smallTitle)),
                        LivitSpaces.xs,
                        Row(
                          children: [
                            LivitText(isDisplayingMedia ? 'Ocultar' : 'Archivos', color: LivitColors.whiteInactive),
                            LivitSpaces.xs,
                            Icon(
                              !isDisplayingMedia ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_up,
                              color: LivitColors.whiteInactive,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      child: Icon(
                        Icons.circle,
                        color: !isLocationMediaEmpty ? LivitColors.mainBlueActive : LivitColors.whiteInactive,
                        size: 6.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: _animationDuration,
            height: isDisplayingMedia ? _mediaDisplayContainerHeight : 0,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                duration: _animationDuration,
                opacity: isDisplayingMedia ? 1.0 : 0.0,
                child: Column(
                  children: [
                    LivitSpaces.s,
                    mediaDisplay(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mediaDisplay() {
    return Padding(
      padding: LivitContainerStyle.padding(padding: null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mainMediaDisplay(),
          if (widget.location.media?.mainFile != null) ...[
            LivitSpaces.s,
            Flexible(
              child: _secondaryMediaDisplay(),
            )
          ]
        ],
      ),
    );
  }

  Widget _secondaryMediaDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Wrap(
            spacing: LivitSpaces.xsDouble,
            runSpacing: LivitSpaces.xsDouble,
            alignment: WrapAlignment.start,
            children: List.generate(
              secondaryTilesLength,
              (index) {
                return Container(
                  clipBehavior: Clip.hardEdge,
                  width: _mediaDisplayWidth / 2 - LivitSpaces.xsDouble / 2,
                  height: _mediaDisplayHeight / 2 - LivitSpaces.xsDouble / 2,
                  decoration: BoxDecoration(
                    borderRadius: LivitContainerStyle.borderRadius / 2,
                    color: LivitColors.mainBlack,
                    boxShadow: [
                      LivitShadows.inactiveWhiteShadow,
                    ],
                  ),
                  child:  index == secondaryTilesLength - 1 && secondaryFilesLength < 6
                          ? InkWell(
                              onTap: () async {
                                final result = await Navigator.push<LivitLocationMedia?>(
                                  context,
                                  MaterialPageRoute<LivitLocationMedia?>(
                                    builder: (context) => LocationMediaPreviewPlayer(
                                      locationMedia: widget.location.media ?? LivitLocationMedia(),
                                      currentMedia: null,
                                      onSave: (locationMedia) {
                                        widget.onMediaChanged(locationMedia, widget.location);
                                      },
                                      addMedia: true,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  widget.onMediaChanged(result, widget.location);
                                }
                              },
                              child: Icon(
                                CupertinoIcons.add,
                                color: LivitColors.whiteInactive,
                                size: 24.sp,
                              ),
                            )
                          : _buildMediaPreview(
                              widget.location.media!.secondaryFiles![index]!,
                              isSmall: true,
                            ),
                );
              },
            ),
          ),
        ),
        LivitSpaces.s,
        LivitText('Adicionales\n(máximo 6)', color: LivitColors.whiteInactive, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _mainMediaDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          width: _mediaDisplayWidth,
          height: _mediaDisplayHeight,
          decoration: widget.location.media?.mainFile == null
              ? LivitContainerStyle.decorationWithActiveShadow
              : LivitContainerStyle.decorationWithInactiveShadow,
          child: widget.location.media?.mainFile?.filePath == null
                  ? InkWell(
                      onTap: () async {
                        final LivitLocationMedia? result = await Navigator.push<LivitLocationMedia?>(
                          context,
                          MaterialPageRoute<LivitLocationMedia?>(
                            builder: (context) => LocationMediaPreviewPlayer(
                              locationMedia: widget.location.media ?? LivitLocationMedia(),
                              currentMedia: null,
                              onSave: (locationMedia) {
                                widget.onMediaChanged(locationMedia, widget.location);
                              },
                              addMedia: true,
                            ),
                          ),
                        );
                        if (result != null) {
                          widget.onMediaChanged(result, widget.location);
                        }
                      },
                      child: Icon(
                        CupertinoIcons.add,
                        color: LivitColors.whiteInactive,
                        size: 24.sp,
                      ),
                    )
                  : _buildMediaPreview(widget.location.media!.mainFile!),
        ),
        LivitSpaces.s,
        LivitText('Principal', fontWeight: FontWeight.bold, color: LivitColors.whiteInactive),
      ],
    );
  }
}
