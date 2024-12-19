import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/video_editor/video_editor.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class LocationMediaInputField extends StatefulWidget {
  final Location location;
  final Function(LivitLocationMediaFile, Location) onMainSelected;
  final Function(LivitLocationMediaFile, Location) onSecondarySelected;
  final Function(LivitLocationMediaFile, Location) onMainDeleted;
  final Function(LivitLocationMediaFile, Location) onSecondaryDeleted;
  final Function(Location) onMediaReset;

  const LocationMediaInputField({
    super.key,
    required this.location,
    required this.onMainSelected,
    required this.onSecondarySelected,
    required this.onMainDeleted,
    required this.onSecondaryDeleted,
    required this.onMediaReset,
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

  bool _isMainLoading = false;
  bool _isSecondaryLoading = false;

  int secondaryFilesLength = 0;
  int secondaryTilesLength = 0;

  final Map<String, String> _videoThumbnails = {};

  Future<File?> _cropImage(String sourcePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagen',
          toolbarColor: LivitColors.mainBlack,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Ajustar imagen',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  _calculateMediaDisplaySizes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final remainingWidth = screenWidth - LivitContainerStyle.paddingFromScreen.horizontal - LivitContainerStyle.horizontalPadding * 2;
    _mediaDisplayWidth = remainingWidth / 3;
    _mediaDisplayHeight = _mediaDisplayWidth * 16 / 9;
    final textSpan = TextSpan(
      text: 'Principal', // Using the longest text between 'Principal' and 'Adicionales'
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
    for (final path in _videoThumbnails.values) {
      try {
        File(path).deleteSync();
      } catch (e) {
        debugPrint('Error deleting thumbnail: $e');
      }
    }
    _videoThumbnails.clear();
    super.dispose();
  }

  Future<void> _pickMedia(bool isMainMedia) async {
    final pickedFile = await ImagePicker().pickMedia();
    if (pickedFile != null) {
      final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
      final bool isVideo = ['mp4', 'mov', 'avi'].contains(fileExtension);

      LivitLocationMediaFile? mediaFile;
      if (isVideo && mounted) {
        final result = await Navigator.push<LivitLocationMediaVideo>(
          context,
          MaterialPageRoute<LivitLocationMediaVideo>(
            builder: (context) => VideoEditor(file: File(pickedFile.path)),
          ),
        );
        if (result != null) {
          mediaFile = result;
        }
      } else {
        File? croppedFile;
        croppedFile = await _cropImage(pickedFile.path);
        mediaFile = LivitLocationMediaImage(url: null, file: croppedFile);
      }

      if (mediaFile != null) {
        if (isMainMedia) {
          widget.onMainSelected(mediaFile, widget.location);
        } else {
          widget.onSecondarySelected(mediaFile, widget.location);
        }
      }
    }
  }

  Widget _buildMediaPreview(File file, {bool isSmall = false}) {
    final String fileExtension = file.path.split('.').last.toLowerCase();
    final bool isVideo = ['mp4', 'mov', 'avi'].contains(fileExtension);

    if (isVideo) {
      return FutureBuilder<String?>(
        future: _getVideoThumbnail(file.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 24.sp,
                height: 24.sp,
                child: CircularProgressIndicator(
                  color: LivitColors.whiteActive,
                  strokeWidth: 2.sp,
                ),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(snapshot.data!),
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
            );
          }

          return Center(
            child: Icon(
              Icons.error_outline,
              color: LivitColors.whiteInactive,
              size: 24.sp,
            ),
          );
        },
      );
    } else {
      return Image.file(file, fit: BoxFit.cover);
    }
  }

  Future<String?> _getVideoThumbnail(String videoPath) async {
    if (_videoThumbnails.containsKey(videoPath)) {
      return _videoThumbnails[videoPath];
    }

    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      );

      if (thumbnail != null) {
        _videoThumbnails[videoPath] = thumbnail;
        return thumbnail;
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _calculateMediaDisplaySizes();
    secondaryFilesLength = widget.location.media?.secondaryFiles?.length ?? 0;
    secondaryTilesLength = min(secondaryFilesLength + (_isSecondaryLoading ? 1 : 0) + 1, 6);
    if (secondaryFilesLength > 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMediaReset(widget.location);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: LivitText('Máximo 6 imágenes secundarias')));
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
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                width: _mediaDisplayWidth,
                height: _mediaDisplayHeight,
                decoration: widget.location.media?.mainFile == null
                    ? LivitContainerStyle.decorationWithActiveShadow
                    : LivitContainerStyle.decorationWithInactiveShadow,
                child: _isMainLoading
                    ? Center(
                        child: SizedBox(
                          width: 24.sp,
                          height: 24.sp,
                          child: CircularProgressIndicator(
                            color: LivitColors.whiteActive,
                            strokeWidth: 2.sp,
                          ),
                        ),
                      )
                    : widget.location.media?.mainFile?.file == null
                        ? InkWell(
                            onTap: () async {
                              setState(() {
                                _isMainLoading = true;
                              });
                              await _pickMedia(true);
                              setState(() {
                                _isMainLoading = false;
                              });
                            },
                            child: Icon(
                              CupertinoIcons.add,
                              color: LivitColors.whiteInactive,
                              size: 24.sp,
                            ),
                          )
                        : _buildMediaPreview(widget.location.media!.mainFile!.file!),
              ),
              LivitSpaces.s,
              LivitText('Principal', fontWeight: FontWeight.bold, color: LivitColors.whiteInactive),
            ],
          ),
          LivitSpaces.s,
          Flexible(
            child: Column(
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
                          decoration: LivitContainerStyle.decorationWithInactiveShadow,
                          child: (_isSecondaryLoading && index == secondaryFilesLength)
                              ? Center(
                                  child: SizedBox(
                                    width: 24.sp,
                                    height: 24.sp,
                                    child: CircularProgressIndicator(
                                      color: LivitColors.whiteActive,
                                      strokeWidth: 2.sp,
                                    ),
                                  ),
                                )
                              : index == secondaryTilesLength - 1 && secondaryFilesLength < 6
                                  ? InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _isSecondaryLoading = true;
                                        });
                                        await _pickMedia(false);
                                        setState(() {
                                          _isSecondaryLoading = false;
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.add,
                                        color: LivitColors.whiteInactive,
                                        size: 24.sp,
                                      ),
                                    )
                                  : _buildMediaPreview(
                                      widget.location.media!.secondaryFiles![index]!.file!,
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
            ),
          )
        ],
      ),
    );
  }
}
