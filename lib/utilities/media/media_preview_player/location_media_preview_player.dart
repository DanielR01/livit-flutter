import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';
import 'package:livit/utilities/media/video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:livit/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationMediaPreviewPlayer extends StatefulWidget {
  final LivitLocationMedia locationMedia;
  final LivitLocationMediaFile? currentMedia;
  final Function(LivitLocationMedia) onSave;
  final bool addMedia;

  const LocationMediaPreviewPlayer({
    super.key,
    required this.locationMedia,
    required this.currentMedia,
    required this.onSave,
    this.addMedia = false,
  });

  @override
  State<LocationMediaPreviewPlayer> createState() => _LocationMediaPreviewPlayerState();
}

class _LocationMediaPreviewPlayerState extends State<LocationMediaPreviewPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late PageController _thumbnailController;
  late PageController _pageController;
  late int _currentIndex;
  bool _isAnimating = false;
  List<LivitLocationMediaFile> _allMedia = [];

  bool _isAddingMedia = false;
  bool _isReplacingMedia = false;

  bool _contentHasChanged = false;
  bool _isContentSaved = false;

  bool _isShowingCover = false;

  bool _isControlsVisible = true;
  Timer? _controlsTimer;

  bool get _isVideo => widget.currentMedia is LivitLocationMediaVideo;

  @override
  void initState() {
    super.initState();
    _setupMediaList();
    if (_isVideo) {
      _initializeController();
    }
    if (widget.addMedia) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _isAddingMedia = true;
        });
        final result = await _pickMedia();
        if (result == null) {
          setState(() {
            _isAddingMedia = false;
          });
          return;
        }

        _allMedia.add(result);

        setState(() {
          _isAddingMedia = false;
          _currentIndex = _allMedia.length - 1;
          _contentHasChanged = true;
          _isContentSaved = false;
          if (result is LivitLocationMediaVideo) {
            _initializeController();
          }
        });
      });
    }
  }

  void _setupMediaList() {
    _allMedia = [
      if (widget.locationMedia.mainFile != null) widget.locationMedia.mainFile!,
      ...widget.locationMedia.secondaryFiles?.whereType<LivitLocationMediaFile>() ?? [],
    ];
    _currentIndex = _allMedia.isEmpty || widget.currentMedia == null ? 0 : _allMedia.indexOf(widget.currentMedia!);

    _thumbnailController = PageController(initialPage: _currentIndex, keepPage: false, viewportFraction: 0.125);
    _pageController = PageController(initialPage: _currentIndex, keepPage: false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _thumbnailController.dispose();
    _pageController.dispose();
    _controlsTimer?.cancel();

    for (var media in _allMedia) {
      MediaFileCleanup.cleanupLocationMediaFile(media);
    }

    super.dispose();
  }

  void _initializeController() {
    if (_allMedia[_currentIndex].filePath != null) {
      _controller = VideoPlayerController.asset(_allMedia[_currentIndex].filePath!)
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          _controller?.play();
        });
    }
  }

  void _addMedia() async {
    setState(() {
      _isAddingMedia = true;
    });
    final index = _allMedia.length;
    _onPageChanged(index);
    await Future.wait(
      [
        _thumbnailController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
        ),
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
        ),
      ],
    );
    final result = await _pickMedia();
    if (result == null) {
      setState(() {
        _isAddingMedia = false;
      });
      return;
    }

    _allMedia.add(result);

    setState(() {
      _isAddingMedia = false;
      _currentIndex = _allMedia.length - 1;
      _contentHasChanged = true;
      _isContentSaved = false;
      if (result is LivitLocationMediaVideo) {
        _initializeController();
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _isShowingCover = false;
    });

    setState(() {
      _currentIndex = index;
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
        _isInitialized = false;
      }
      if (_allMedia.isEmpty || _allMedia.length - 1 < index) return;
      if (_allMedia[index] is LivitLocationMediaVideo) {
        _initializeController();
      }
    });
  }

  Widget _buildMediaView(LivitLocationMediaFile media) {
    final bool isVideo = media is LivitLocationMediaVideo;
    if (isVideo) {
      return _isInitialized && _controller != null
          ? Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: LivitContainerStyle.borderRadius / 2,
              ),
              child: GestureDetector(
                onLongPress: () {},
                onTap: () {
                  _handleControlsVisibility();
                },
                child: SizedBox(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _isShowingCover
                          ? Image.file(
                              File((_allMedia[_currentIndex] as LivitLocationMediaVideo).cover.filePath!),
                              fit: BoxFit.fitHeight,
                            )
                          : VideoPlayer(_controller!),
                      AnimatedOpacity(
                        opacity: _isControlsVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          color: LivitColors.mainBlack.withOpacity(0.2),
                          child: _isShowingCover
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        LivitSpaces.s,
                                        Button.main(
                                          text: 'Ver video',
                                          isActive: true,
                                          onPressed: () {
                                            setState(() {
                                              _isShowingCover = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        LivitSpaces.s,
                                        Button.main(
                                          text: 'Ver portada',
                                          isActive: true,
                                          onPressed: () {
                                            setState(() {
                                              _isShowingCover = true;
                                              _controller?.pause();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (!_isControlsVisible) return;
                                                if (_controller?.value.isPlaying == true) {
                                                  _controller?.pause();
                                                } else {
                                                  _controller?.play();
                                                }
                                                setState(() {});
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(LivitSpaces.mDouble),
                                                child: Icon(
                                                  _controller?.value.isPlaying == true
                                                      ? CupertinoIcons.pause_fill
                                                      : CupertinoIcons.play_fill,
                                                  size: LivitButtonStyle.bigIconSize,
                                                  color: LivitColors.whiteActive,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: LivitSpaces.sDouble),
                                              child: ValueListenableBuilder(
                                                valueListenable: _controller!,
                                                builder: (context, VideoPlayerValue value, child) {
                                                  return LivitText(
                                                    '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                                    textType: LivitTextType.small,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: LivitSpaces.sDouble),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  height: LivitSpaces.xsDouble,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(LivitSpaces.xsDouble / 2),
                                                  ),
                                                  child: VideoProgressIndicator(
                                                    padding: EdgeInsets.zero,
                                                    _controller!,
                                                    allowScrubbing: true,
                                                    colors: VideoProgressColors(
                                                      playedColor: LivitColors.whiteActive,
                                                      bufferedColor: LivitColors.whiteInactive.withOpacity(0.5),
                                                      backgroundColor: LivitColors.mainBlack.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        LivitSpaces.s,
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: SizedBox(
                width: 24.sp,
                height: 24.sp,
                child: CircularProgressIndicator(
                  color: LivitColors.whiteActive,
                  strokeWidth: 2.sp,
                ),
              ),
            );
    } else if (media.filePath != null) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: LivitContainerStyle.borderRadius / 2,
        ),
        child: Image.file(
          File(media.filePath!),
          fit: BoxFit.contain,
        ),
      );
    }
    return const Center(child: Icon(Icons.error));
  }

  Widget _buildThumbnail(int index, bool isCurrent) {
    final media = _allMedia[index];
    final bool isVideo = media is LivitLocationMediaVideo;
    final String? path = isVideo ? media.cover.filePath : media.filePath;

    return Container(
      height: LivitBarStyle.height,
      width: LivitBarStyle.height * 9 / 16,
      decoration: BoxDecoration(
        borderRadius: LivitContainerStyle.borderRadius / 4,
      ),
      clipBehavior: Clip.hardEdge,
      child: path != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(path),
                  fit: BoxFit.cover,
                ),
              ],
            )
          : Icon(
              Icons.error,
              color: LivitColors.whiteInactive,
              size: 24.sp,
            ),
    );
  }

  Widget _buildThumbnailView() {
    return SizedBox(
      height: LivitBarStyle.height,
      child: PageView.builder(
        clipBehavior: Clip.none,
        itemCount: _allMedia.length + (_isAddingMedia ? 1 : 0),
        controller: _thumbnailController,
        onPageChanged: (index) async {
          if (index == _currentIndex) return;
          _onPageChanged(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
          );
        },
        itemBuilder: (context, index) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            padding: EdgeInsets.symmetric(
                horizontal: _currentIndex != index ? LivitSpaces.xsDouble / 4 : LivitSpaces.sDouble / 2,
                vertical: _currentIndex == index ? 0.0 : LivitSpaces.sDouble / 2),
            child: GestureDetector(
              onTap: () async {
                _isAnimating = true;
                _onPageChanged(index);
                await Future.wait([
                  _thumbnailController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                  ),
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                  ),
                ]);
                _isAnimating = false;
              },
              child: _isAddingMedia && index == _allMedia.length
                  ? Center(
                      child: SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          color: LivitColors.whiteActive,
                          strokeWidth: 1.sp,
                        ),
                      ),
                    )
                  : _buildThumbnail(
                      index,
                      _currentIndex == index,
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<LivitLocationMediaFile?> _pickMedia() async {
    final XFile? pickedFile = await ImagePicker().pickMedia();
    if (pickedFile == null) return null;

    final File originalFile = File(pickedFile.path);
    final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
    final bool isVideo = ['mp4', 'mov', 'avi'].contains(fileExtension);

    try {
      if (isVideo) {
        return await Navigator.push<LivitLocationMediaVideo>(
          context,
          MaterialPageRoute<LivitLocationMediaVideo>(
            builder: (context) => LivitMediaEditor(videoPath: originalFile.path),
          ),
        );
      } else {
        final croppedFilePath = await LivitMediaEditor.cropImage(originalFile.path);
        if (croppedFilePath == null) return null;
        return LivitLocationMediaImage(filePath: croppedFilePath, url: '');
      }
    } finally {
      // Clean up the original file from ImagePicker
      await MediaFileCleanup.deleteFile(originalFile);
    }
  }

  Widget _buildTopBar() {
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.none,
      child: Padding(
        padding: LivitContainerStyle.padding(padding: [null, null, null, 0]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: LivitContainerStyle.padding(padding: [0, null, 0, 0]),
              child: Button.icon(
                deactivateSplash: true,
                isActive: !_isAddingMedia && !_isReplacingMedia,
                isIconBig: true,
                icon: CupertinoIcons.chevron_back,
                onPressed: () async {
                  if (!_contentHasChanged || _isContentSaved) {
                    if (mounted) Navigator.pop(context);
                    return;
                  }

                  final shouldPop = await _onWillPop();
                  if (!shouldPop) return;
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
            Row(
              children: [
                Button.icon(
                  isActive: _allMedia.length < 6 && !_isAddingMedia && !_isReplacingMedia,
                  isShadowActive: true,
                  isIconBig: true,
                  icon: CupertinoIcons.add,
                  onPressed: () {
                    _addMedia();
                  },
                ),
                LivitSpaces.s,
                Button.main(
                  text: 'Guardar',
                  isActive: _contentHasChanged && !_isContentSaved && !_isAddingMedia && !_isReplacingMedia,
                  onPressed: () {
                    setState(() {
                      _isContentSaved = true;
                    });
                    widget.onSave(
                      LivitLocationMedia(
                        mainFile: _allMedia.isNotEmpty ? _allMedia[0] : null,
                        secondaryFiles: _allMedia.isNotEmpty ? _allMedia.sublist(1) : [],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return LivitBar(
      shadowType: ShadowType.none,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Button.icon(
            isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
            onPressed: () async {
              if (_allMedia[_currentIndex] is LivitLocationMediaVideo) {
                final result = await Navigator.push<LivitLocationMediaVideo>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LivitMediaEditor(
                      videoPath: _allMedia[_currentIndex].filePath!,
                      coverPath: (_allMedia[_currentIndex] as LivitLocationMediaVideo).cover.filePath!,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _allMedia[_currentIndex] = result;
                    _initializeController();
                    _isContentSaved = false;
                    _contentHasChanged = true;
                  });
                }
              } else {
                final croppedFilePath = await LivitMediaEditor.cropImage(_allMedia[_currentIndex].filePath!);
                if (croppedFilePath == null) return;
                setState(() {
                  _allMedia[_currentIndex] = LivitLocationMediaImage(filePath: croppedFilePath, url: '');
                  _isContentSaved = false;
                  _contentHasChanged = true;
                });
              }
            },
            icon: CupertinoIcons.slider_horizontal_3,
            isShadowActive: true,
          ),
          Button.main(
            text: 'Reemplazar',
            isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
            onPressed: () async {
              setState(() {
                _isReplacingMedia = true;
              });
              final LivitLocationMediaFile? file = await _pickMedia();
              if (file != null) {
                setState(() {
                  MediaFileCleanup.cleanupLocationMediaFile(_allMedia[_currentIndex]);
                  _allMedia[_currentIndex] = file;
                  _contentHasChanged = true;
                  _isContentSaved = false;
                  if (file is LivitLocationMediaVideo) {
                    _initializeController();
                  }
                });
              }
              setState(() {
                _isReplacingMedia = false;
              });
            },
          ),
          Button.icon(
            isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
            onPressed: () {
              _deleteCurrentMedia();
            },
            icon: CupertinoIcons.delete,
            isShadowActive: true,
          ),
        ],
      ),
    );
  }

  void _deleteCurrentMedia() async {
    setState(() {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _contentHasChanged = true;
      _isContentSaved = false;
    });

    await MediaFileCleanup.cleanupLocationMediaFile(_allMedia[_currentIndex]);

    _allMedia.removeAt(_currentIndex);
    final index = max(_currentIndex - 1, 0);
    _onPageChanged(index);

    await Future.wait([
      _thumbnailController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      ),
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      ),
    ]);
  }

  void _handleControlsVisibility() {
    setState(() => _isControlsVisible = !_isControlsVisible);
    if (_isControlsVisible) {
      _controlsTimer?.cancel();
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isControlsVisible = false);
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<bool> _onWillPop() async {
    if (!_contentHasChanged) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: LivitColors.mainBlack,
        child: Padding(
          padding: EdgeInsets.all(LivitSpaces.mDouble),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LivitText(
                '¿Deseas descartar los cambios?',
                textType: LivitTextType.smallTitle,
              ),
              LivitSpaces.s,
              const LivitText(
                'Los cambios que realizaste se perderán',
                textType: LivitTextType.small,
              ),
              LivitSpaces.m,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button.main(
                    text: 'Cancelar',
                    isActive: true,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Button.redText(
                    text: 'Descartar',
                    isActive: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: (!_contentHasChanged || _isContentSaved) && !_isAddingMedia && !_isReplacingMedia,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: LivitContainerStyle.paddingFromScreen,
                  child: _buildTopBar(),
                ),
                LivitSpaces.s,
                Flexible(
                  child: Padding(
                    padding: LivitContainerStyle.paddingFromScreen,
                    child: GlassContainer(
                      opacity: 1,
                      child: Padding(
                        padding: LivitContainerStyle.padding(padding: null),
                        child: Column(
                          children: [
                            Flexible(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    constraints: BoxConstraints(maxWidth: constraints.maxHeight * 9 / 16),
                                    child: PageView.builder(
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        if (index == _currentIndex || _isAnimating) return;
                                        _onPageChanged(index);
                                        _thumbnailController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.fastOutSlowIn,
                                        );
                                      },
                                      itemCount: _allMedia.length + (_isAddingMedia ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (index == _allMedia.length && _isAddingMedia) {
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
                                        return _buildMediaView(_allMedia[index]);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            LivitSpaces.s,
                            _buildThumbnailView(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                LivitSpaces.s,
                Padding(
                  padding: LivitContainerStyle.paddingFromScreen,
                  child: _buildBottomBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
