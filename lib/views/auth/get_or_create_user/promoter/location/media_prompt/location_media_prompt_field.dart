import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/location/location.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';

class LocationMediaInputField extends StatefulWidget {
  final LivitLocation location;
  final Map<String, LivitException>? errors;

  const LocationMediaInputField({
    super.key,
    required this.location,
    required this.errors,
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
  bool isUploading = false;
  bool isUploadingAnimationVisible = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  _calculateMediaDisplaySizes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final remainingWidth = screenWidth - LivitContainerStyle.paddingFromScreen.horizontal - LivitContainerStyle.horizontalPadding * 2;
    _mediaDisplayWidth = remainingWidth / 3;
    _mediaDisplayHeight = _mediaDisplayWidth * 16 / 9;
    final textSpan = TextSpan(
      text:
          'Adicionales\n(máximo ${FirebaseStorageConstants.maxFiles - 1})', // Using the longest text between 'Principal' and 'Adicionales'
      style: TextStyle(
        fontSize: LivitTextStyle.regularFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    TextPainter? errorTextPainter;
    if (widget.errors != null) {
      errorTextPainter = TextPainter(
        text: TextSpan(
          text: _errorMessage,
          style: TextStyle(
            fontSize: LivitTextStyle.regularFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    final textHeight = textPainter.height;
    final errorTextHeight = errorTextPainter?.height ?? 0;
    _mediaDisplayContainerHeight = _mediaDisplayHeight +
        LivitSpaces.sDouble * 2 +
        LivitContainerStyle.padding().vertical +
        textHeight +
        errorTextHeight +
        (errorTextHeight > 0 ? LivitSpaces.sDouble + LivitSpaces.xsDouble + LivitButtonStyle.iconSize : 0);
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

  Widget _buildMediaPreview(LivitMediaFile file, int index, {bool isSmall = false}) {
    try {
      final bool isVideo = file is LivitMediaVideo;
      final String? path = isVideo ? file.cover.filePath : file.filePath;

      if (path == null) return const SizedBox.shrink();

      if (isVideo) {
        return GestureDetector(
          onTap: () {
            _showMediaPreview(file, index);
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
        debugPrint('🖼️ [LocationMediaPromptField] Image path: $path');
        return GestureDetector(
          onTap: () {
            _showMediaPreview(file, index);
          },
          child: Image.file(File(path)),
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

  void _showMediaPreview(LivitMediaFile currentMedia, int index) async {
    if (currentMedia.filePath == null || widget.location.media == null) return;
    if (isUploading) return;

    Navigator.pushNamed(
      context,
      Routes.locationMediaPreviewPlayerRoute,
      arguments: {
        'location': widget.location,
        'index': index,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errors != null) {
      if (widget.errors!['error'] != null) {
        _errorMessage = widget.errors!['error']?.message;
      } else {
        if (widget.errors!.length > 1) {
          _errorMessage = 'Multiples errores: ';
        } else {
          _errorMessage = '';
        }
        final List<String> errorMessages = [];
        widget.errors!.forEach((key, value) {
          errorMessages.add(value.message);
        });
        _errorMessage = '${_errorMessage!}${errorMessages.join(', ')}.';
      }
    }
    _calculateMediaDisplaySizes();
    secondaryFilesLength = (widget.location.media?.files?.length ?? 0) - 1;
    secondaryTilesLength = min(secondaryFilesLength + 1, FirebaseStorageConstants.maxFiles - 1);

    final bool isLocationMediaEmpty = widget.location.media == null || (widget.location.media?.files?.isEmpty ?? true);

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        if (state is LocationsLoaded) {
          isUploading = state.loadingStates['cloud'] == LoadingState.loading;
          isUploadingAnimationVisible = ((state.loadingStates[widget.location.id] != LoadingState.uploaded &&
                      state.loadingStates[widget.location.id] != LoadingState.loaded) &&
                  state.loadingStates[widget.location.id] != LoadingState.error) &&
              state.loadingStates['cloud'] == LoadingState.loading;
        } else {
          isUploading = false;
          isUploadingAnimationVisible = false;
        }
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
                          child: isUploadingAnimationVisible
                              ? SizedBox(
                                  width: LivitButtonStyle.iconSize,
                                  height: LivitButtonStyle.iconSize,
                                  child: CupertinoActivityIndicator(
                                    radius: LivitButtonStyle.iconSize / 2,
                                    color: LivitColors.whiteInactive,
                                  ),
                                )
                              : Icon(
                                  Icons.circle,
                                  color: state is LocationsLoaded && state.loadingStates[widget.location.id] == LoadingState.error
                                      ? LivitColors.yellowError
                                      : !isLocationMediaEmpty
                                          ? LivitColors.mainBlueActive
                                          : LivitColors.whiteInactive,
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
                        if (_errorMessage != null) ...[
                          LivitSpaces.s,
                          Padding(
                            padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: LivitText(_errorMessage ?? '',
                                      color: LivitColors.whiteActive, fontWeight: FontWeight.bold, textType: LivitTextType.small),
                                ),
                                LivitSpaces.xs,
                                Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  color: LivitColors.yellowError,
                                  size: LivitButtonStyle.iconSize,
                                ),
                              ],
                            ),
                          ),
                          LivitSpaces.s,
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          if (widget.location.media?.files?.isNotEmpty ?? false) ...[
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
                  child: index == secondaryTilesLength - 1 && secondaryFilesLength < FirebaseStorageConstants.maxFiles - 1
                      ? InkWell(
                          onTap: () {
                            if (isUploading) return;
                            Navigator.pushNamed(
                              context,
                              Routes.locationMediaPreviewPlayerRoute,
                              arguments: {
                                'location': widget.location,
                                'index': index,
                                'addMedia': true,
                              },
                            );
                          },
                          child: Icon(
                            CupertinoIcons.add,
                            color: LivitColors.whiteInactive,
                            size: 24.sp,
                          ),
                        )
                      : _buildMediaPreview(
                          widget.location.media!.files![index + 1]!,
                          index + 1,
                          isSmall: true,
                        ),
                );
              },
            ),
          ),
        ),
        LivitSpaces.s,
        LivitText('Adicionales\n(máximo ${FirebaseStorageConstants.maxFiles - 1})',
            color: LivitColors.whiteInactive, fontWeight: FontWeight.bold),
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
          decoration: widget.location.media?.files?.isEmpty ?? true
              ? LivitContainerStyle.decorationWithActiveShadow
              : LivitContainerStyle.decorationWithInactiveShadow,
          child: widget.location.media?.files?.isEmpty ?? true
              ? InkWell(
                  onTap: () {
                    if (isUploading) return;
                    Navigator.pushNamed(
                      context,
                      Routes.locationMediaPreviewPlayerRoute,
                      arguments: {
                        'location': widget.location,
                        'index': 0,
                        'addMedia': true,
                      },
                    );
                  },
                  child: Icon(
                    CupertinoIcons.add,
                    color: LivitColors.whiteInactive,
                    size: 24.sp,
                  ),
                )
              : _buildMediaPreview(widget.location.media!.files![0]!, 0),
        ),
        LivitSpaces.s,
        LivitText('Principal', fontWeight: FontWeight.bold, color: LivitColors.whiteInactive),
      ],
    );
  }
}
