import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livit/models/media/livit_media_file.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/files/temp_file_manager.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';
import 'package:livit/utilities/media/video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:livit/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class EventMediaPreviewPlayer extends StatefulWidget {
  final List<LivitMediaFile> initialMedia;
  final int index;
  final bool addMedia;

  const EventMediaPreviewPlayer({
    super.key,
    required this.initialMedia,
    this.index = 0,
    this.addMedia = false,
  });

  @override
  State<EventMediaPreviewPlayer> createState() => _EventMediaPreviewPlayerState();
}

class _EventMediaPreviewPlayerState extends State<EventMediaPreviewPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late PageController _thumbnailController;
  late PageController _pageController;

  late int _currentIndex;
  int _displayedIndex = 0;
  int _displayedThumbnailIndex = 0;

  bool _isAddingMedia = false;
  bool _isReplacingMedia = false;

  bool _isShowingCover = false;

  bool _isControlsVisible = true;
  Timer? _controlsTimer;

  bool get isVideo => _isAddingMedia ? false : _allMedia.isNotEmpty && _allMedia[_currentIndex] is LivitMediaVideo;

  final ErrorReporter _errorReporter = ErrorReporter(viewName: 'EventMediaPreviewPlayer');
  final _debugger = const LivitDebugger('EventMediaPreviewPlayer', isDebugEnabled: false);

  List<LivitMediaFile> get _allMedia => widget.initialMedia;

  late List<LivitMediaFile> _savedMedia;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _setupMediaList();
    _savedMedia = List.from(widget.initialMedia);

    if (widget.addMedia) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          _currentIndex = _allMedia.length - 1;
          _addMedia();
        },
      );
    }
  }

  void _setupMediaList() {
    _currentIndex = widget.index;
    _thumbnailController = PageController(initialPage: _currentIndex, keepPage: false, viewportFraction: 0.125);
    _pageController = PageController(initialPage: _currentIndex, keepPage: false);
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    _thumbnailController.dispose();
    _pageController.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _initializeController() async {
    if (_allMedia.isNotEmpty && _allMedia[_currentIndex].filePath != null) {
      try {
        _controller = VideoPlayerController.file(File(_allMedia[_currentIndex].filePath!));

        await _controller?.setVolume(1.0);
        await _controller?.setPlaybackSpeed(1.0);
        await _controller?.setLooping(false);

        await _controller?.initialize();
        _controller?.play();
        setState(() {
          _isInitialized = true;
        });
      } catch (e) {
        if (!File(_allMedia[_currentIndex].filePath!).existsSync()) {
          _debugger.debPrint('File does not exist: ${_allMedia[_currentIndex].filePath}', DebugMessageType.error);
        } else {
          _debugger.debPrint('Error initializing controller: $e', DebugMessageType.error);
          _errorReporter.reportError(e, StackTrace.current);
        }
      }
    }
  }

  void _replaceMedia(LivitMediaFile? newMedia) async {
    final List<LivitMediaFile?> auxMedia = _allMedia;
    if (_allMedia.isNotEmpty && _allMedia[_currentIndex].filePath != null) {
      MediaFileCleanup.deleteFileByPath(_allMedia[_currentIndex].filePath);
      if (_allMedia[_currentIndex] is LivitMediaVideo && (_allMedia[_currentIndex] as LivitMediaVideo).cover.filePath != null) {
        MediaFileCleanup.deleteFileByPath((_allMedia[_currentIndex] as LivitMediaVideo).cover.filePath!);
      }
    }

    if (newMedia != null) {
      auxMedia[_currentIndex] = newMedia;
    } else {
      auxMedia.removeAt(_currentIndex);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (_allMedia.isNotEmpty && _allMedia[_currentIndex] is LivitMediaVideo) {
      _initializeController();
    }
    setState(() {
      _hasChanges = true;
    });
  }

  void _addMedia() async {
    _debugger.debPrint('Starting _addMedia() function', DebugMessageType.methodEntering);
    _debugger.debPrint('Current media count: ${_allMedia.length}', DebugMessageType.info);
    _debugger.debPrint('Current index before addition: $_currentIndex', DebugMessageType.info);

    try {
      setState(() {
        _isAddingMedia = true;
        if (_allMedia.isEmpty) {
          _currentIndex = 0;
        } else {
          _currentIndex++;
        }
      });
      _debugger.debPrint('Updated current index for new media: $_currentIndex', DebugMessageType.info);
      _debugger.debPrint('Calling _pickMedia() to select file', DebugMessageType.methodCalling);

      final result = await _pickMedia();
      _debugger.debPrint('_pickMedia() returned: ${result != null ? 'media file' : 'null'}', DebugMessageType.response);

      if (result == null) {
        _debugger.debPrint('No media selected, resetting state', DebugMessageType.warning);
        setState(() {
          _isAddingMedia = false;
          _currentIndex = max(_currentIndex - 1, 0);
        });
        _debugger.debPrint('Reset current index to: $_currentIndex', DebugMessageType.info);
        return;
      }

      _debugger.debPrint('Media selected type: ${result.runtimeType}', DebugMessageType.info);
      _debugger.debPrint('Media file path: ${result.filePath}', DebugMessageType.fileTracking);
      if (result is LivitMediaVideo) {
        _debugger.debPrint('Video cover path: ${result.cover.filePath}', DebugMessageType.fileTracking);
      }

      final List<LivitMediaFile?> auxMedia = _allMedia;
      _debugger.debPrint('Current media list before insert (count: ${auxMedia.length})', DebugMessageType.info);

      auxMedia.insert(_currentIndex, result);
      _debugger.debPrint('Media inserted at index $_currentIndex', DebugMessageType.done);
      _debugger.debPrint('New media list size: ${auxMedia.length}', DebugMessageType.info);

      setState(() {
        _isAddingMedia = false;
      });
      _debugger.debPrint('Reset _isAddingMedia flag', DebugMessageType.info);

      setState(() {
        _hasChanges = true;
      });
      _debugger.debPrint('Set _hasChanges flag to true', DebugMessageType.info);
      _debugger.debPrint('_addMedia() completed successfully', DebugMessageType.methodExiting);
    } catch (e) {
      _debugger.debPrint('Error adding media: $e', DebugMessageType.error);
      _debugger.debPrint('Error stack trace: ${StackTrace.current}', DebugMessageType.error);
      _errorReporter.reportError(e, StackTrace.current);
      setState(() {
        _isAddingMedia = false;
      });
      _debugger.debPrint('Reset _isAddingMedia flag after error', DebugMessageType.info);
      _showDialog('Error al agregar multimedia', 'Ocurrio un error al agregar el archibo. Intenta nuevamente.');
    }
  }

  void _deleteCurrentMedia() async {
    _replaceMedia(null);
    setState(() {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _currentIndex = max(_currentIndex - 1, 0);
    });
    setState(() {
      _hasChanges = true;
    });
  }

  Widget _buildVideoView(LivitMediaVideo media) {
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
                            File((media).cover.filePath!),
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
                                        onTap: () {
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
                                        onTap: () {
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
                                                _controller?.value.isPlaying == true ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
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
              width: LivitButtonStyle.bigIconSize,
              height: LivitButtonStyle.bigIconSize,
              child: CupertinoActivityIndicator(
                color: LivitColors.whiteActive,
                radius: LivitButtonStyle.bigIconSize / 2,
              ),
            ),
          );
  }

  Widget _buildImageView(LivitMediaImage media) {
    if (!File(media.filePath!).existsSync()) {
      return Container(
        height: LivitBarStyle.height,
        width: LivitBarStyle.height * 9 / 16,
        decoration: BoxDecoration(
          borderRadius: LivitContainerStyle.borderRadius / 4,
        ),
        child: Icon(
          Icons.error,
          color: LivitColors.whiteInactive,
          size: 24.sp,
        ),
      );
    }
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: LivitContainerStyle.borderRadius / 2,
      ),
      child: Image.file(File(media.filePath!), fit: BoxFit.contain),
    );
  }

  Widget _buildThumbnail(int index, bool isCurrent) {
    final LivitMediaFile media = _allMedia[index];
    final bool isVideo = media is LivitMediaVideo;
    final String? path = isVideo ? media.cover.filePath : media.filePath;
    if (path != null && !File(path).existsSync()) {
      return Container(
        height: LivitBarStyle.height,
        width: LivitBarStyle.height * 9 / 16,
        decoration: BoxDecoration(
          borderRadius: LivitContainerStyle.borderRadius / 4,
        ),
        child: Icon(
          Icons.error,
          color: LivitColors.whiteInactive,
          size: 24.sp,
        ),
      );
    }

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
          setState(() {
            _displayedThumbnailIndex = index;
            _currentIndex = index;
          });
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
                setState(() {
                  _currentIndex = index;
                });
              },
              child: _isAddingMedia && index == _allMedia.length
                  ? Center(
                      child: SizedBox(
                        width: LivitButtonStyle.iconSize,
                        height: LivitButtonStyle.iconSize,
                        child: CupertinoActivityIndicator(
                          color: LivitColors.whiteActive,
                          radius: LivitButtonStyle.iconSize / 2,
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

  Future<LivitMediaFile?> _pickMedia() async {
    _debugger.debPrint('Starting _pickMedia() function', DebugMessageType.methodEntering);
    _debugger.debPrint('Showing system picker for media selection', DebugMessageType.interaction);

    final XFile? pickedFile = await ImagePicker().pickMedia(imageQuality: 100);

    if (pickedFile == null) {
      _debugger.debPrint('No file selected from picker', DebugMessageType.warning);
      return null;
    }

    _debugger.debPrint('File selected: ${pickedFile.path}', DebugMessageType.fileTracking);
    _debugger.debPrint('File name: ${pickedFile.name}', DebugMessageType.info);

    // Check if file exists
    final fileExists = await File(pickedFile.path).exists();
    _debugger.debPrint('File exists check: $fileExists', DebugMessageType.verifying);

    if (!fileExists) {
      _debugger.debPrint('File does not exist at path!', DebugMessageType.error);
      return null;
    }

    // Get file size
    final fileSize = await File(pickedFile.path).length();
    _debugger.debPrint('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB', DebugMessageType.info);

    await TempFileManager.trackFile(pickedFile.path, false);
    _debugger.debPrint('File added to temp file tracking', DebugMessageType.fileSaving);

    final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
    _debugger.debPrint('File extension: $fileExtension', DebugMessageType.info);

    final bool isVideo = ['mp4', 'mov', 'avi'].contains(fileExtension);
    _debugger.debPrint('File type: ${isVideo ? 'Video' : 'Image'}', DebugMessageType.info);

    try {
      if (isVideo) {
        _debugger.debPrint('Processing video file', DebugMessageType.info);

        if (mounted) {
          _debugger.debPrint('Opening video editor for processing', DebugMessageType.navigation);

          final result = await Navigator.push<LivitMediaVideo>(
            context,
            MaterialPageRoute<LivitMediaVideo>(
              builder: (context) => LivitMediaEditor(videoPath: pickedFile.path, isInitialEdit: true),
            ),
          );

          if (result == null) {
            _debugger.debPrint('Video editor returned null (user cancelled)', DebugMessageType.warning);
          } else {
            _debugger.debPrint('Video processed successfully', DebugMessageType.done);
            _debugger.debPrint('Processed video path: ${result.filePath}', DebugMessageType.fileTracking);
            _debugger.debPrint('Video cover path: ${result.cover.filePath}', DebugMessageType.fileTracking);
          }

          return result;
        } else {
          _debugger.debPrint('Widget not mounted, cannot open editor', DebugMessageType.error);
          return null;
        }
      } else {
        _debugger.debPrint('Processing image file', DebugMessageType.info);
        _debugger.debPrint('Opening image cropper', DebugMessageType.navigation);

        final croppedFilePath = await LivitMediaEditor.cropImage(pickedFile.path);

        if (croppedFilePath == null) {
          _debugger.debPrint('Image cropper returned null (user cancelled)', DebugMessageType.warning);
          return null;
        }

        _debugger.debPrint('Cropped image path: $croppedFilePath', DebugMessageType.fileTracking);

        // Verify cropped file exists
        final croppedExists = await File(croppedFilePath).exists();
        _debugger.debPrint('Cropped file exists check: $croppedExists', DebugMessageType.verifying);

        if (!croppedExists) {
          _debugger.debPrint('Cropped file does not exist at path!', DebugMessageType.error);
          return null;
        }

        // Get cropped file size
        final croppedSize = await File(croppedFilePath).length();
        _debugger.debPrint('Cropped file size: ${(croppedSize / 1024 / 1024).toStringAsFixed(2)} MB', DebugMessageType.info);

        _debugger.debPrint('Image processed successfully', DebugMessageType.done);
        return LivitMediaImage(filePath: croppedFilePath, url: '');
      }
    } catch (e) {
      _debugger.debPrint('Error picking media: $e', DebugMessageType.error);
      _debugger.debPrint('Error stack trace: ${StackTrace.current}', DebugMessageType.error);
      _errorReporter.reportError(e, StackTrace.current);
      return null;
    } finally {
      // Check if original file still exists before deleting
      final originalStillExists = await File(pickedFile.path).exists();
      _debugger.debPrint('Original file still exists: $originalStillExists', DebugMessageType.verifying);

      if (originalStillExists) {
        _debugger.debPrint('Cleaning up original picked file', DebugMessageType.fileCleaning);
        await MediaFileCleanup.deleteFileByPath(pickedFile.path);

        // Verify deletion
        final deletionSuccessful = !(await File(pickedFile.path).exists());
        _debugger.debPrint('Original file deleted: $deletionSuccessful', DebugMessageType.verifying);
      }

      _debugger.debPrint('_pickMedia() function completed', DebugMessageType.methodExiting);
    }
  }

  Widget _buildTopBar() {
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.none,
      child: Padding(
        padding: LivitContainerStyle.padding(padding: [0, null, 0, 0]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Button.icon(
              deactivateSplash: true,
              isActive: !_isAddingMedia && !_isReplacingMedia,
              isIconBig: true,
              icon: CupertinoIcons.chevron_back,
              onTap: _onWillPop,
            ),
            Row(
              children: [
                Button.icon(
                  isActive: _allMedia.length < 7 && !_isAddingMedia && !_isReplacingMedia,
                  isShadowActive: true,
                  isIconBig: true,
                  icon: CupertinoIcons.add,
                  onTap: () {
                    _addMedia();
                  },
                ),
                LivitSpaces.s,
                Button.main(
                  text: 'Guardar',
                  isActive: _hasChanges,
                  onTap: () {
                    _saveChanges();
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
      noPadding: true,
      child: Padding(
        padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Button.icon(
              isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
              onTap: () async {
                if (_allMedia[_currentIndex] is LivitMediaVideo) {
                  final result = await Navigator.push<LivitMediaVideo>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LivitMediaEditor(
                        videoPath: _allMedia[_currentIndex].filePath!,
                        coverPath: (_allMedia[_currentIndex] as LivitMediaVideo).cover.filePath!,
                        isInitialEdit: false,
                      ),
                    ),
                  );
                  if (result != null) {
                    _replaceMedia(result);
                  }
                } else {
                  final croppedFilePath = await LivitMediaEditor.cropImage(_allMedia[_currentIndex].filePath!);
                  if (croppedFilePath == null) return;
                  _replaceMedia(LivitMediaImage(filePath: croppedFilePath, url: ''));
                }
              },
              icon: CupertinoIcons.slider_horizontal_3,
              isShadowActive: true,
            ),
            Button.main(
              text: _isReplacingMedia ? 'Reemplazando' : 'Reemplazar',
              isLoading: _isReplacingMedia,
              isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
              onTap: () async {
                setState(() {
                  _isReplacingMedia = true;
                });
                final LivitMediaFile? file = await _pickMedia();
                if (file != null) {
                  _replaceMedia(file);
                }
                setState(() {
                  _isReplacingMedia = false;
                });
              },
            ),
            Button.icon(
              isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
              onTap: () {
                _deleteCurrentMedia();
              },
              icon: CupertinoIcons.delete,
              isShadowActive: true,
            ),
          ],
        ),
      ),
    );
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

  Future<void> _onWillPop() async {
    if (_hasChanges) {
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
                ),
                LivitSpaces.m,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button.main(
                      text: 'Cancelar',
                      onTap: () => Navigator.of(context).pop(false),
                      isActive: true,
                    ),
                    Button.redText(
                      text: 'Descartar',
                      onTap: () => Navigator.of(context).pop(true),
                      isActive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (shouldPop == true && mounted) {
        Navigator.of(context).pop(_savedMedia);
      }
    } else {
      Navigator.of(context).pop(_savedMedia);
    }
  }

  void _saveChanges() {
    setState(() {
      _savedMedia = List.from(_allMedia);
      _hasChanges = false;
    });
  }

  void _cleanupCurrentVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  void _showDialog(String title, String message, {int autoDismissSeconds = 10}) {
    showDialog(
      barrierColor: LivitColors.mainBlackDialog,
      context: context,
      builder: (context) {
        if (autoDismissSeconds > 0) {
          Timer(Duration(seconds: autoDismissSeconds), () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: LivitContainerStyle.decoration,
            child: Padding(
              padding: LivitContainerStyle.padding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LivitText(
                    title,
                    textType: LivitTextType.smallTitle,
                  ),
                  LivitSpaces.s,
                  LivitText(
                    message,
                  ),
                  if (autoDismissSeconds > 0) ...[
                    LivitSpaces.xs,
                    LivitText(
                      'Este mensaje se cerrará automáticamente en $autoDismissSeconds segundos',
                      textType: LivitTextType.small,
                      color: LivitColors.whiteInactive,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_displayedIndex != _currentIndex || _displayedThumbnailIndex != _currentIndex) {
          _cleanupCurrentVideo();
        }
        if (isVideo && !_isInitialized) {
          _initializeController();
        }
        if (_displayedIndex != _currentIndex) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
          );
          _displayedIndex = _currentIndex;
        }
        if (_displayedThumbnailIndex != _currentIndex) {
          _thumbnailController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
          );
          _displayedThumbnailIndex = _currentIndex;
        }
      },
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: LivitDisplayArea(
          child: Center(
            child: Column(
              children: [
                _buildTopBar(),
                LivitSpaces.xs,
                Flexible(
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
                                      setState(() {
                                        _currentIndex = index;
                                        _displayedIndex = index;
                                      });
                                    },
                                    itemCount: _allMedia.length + (_isAddingMedia ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _allMedia.length && _isAddingMedia) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: LivitButtonStyle.bigIconSize,
                                                height: LivitButtonStyle.bigIconSize,
                                                child: CupertinoActivityIndicator(
                                                  color: LivitColors.whiteActive,
                                                  radius: LivitButtonStyle.bigIconSize / 2,
                                                ),
                                              ),
                                              LivitSpaces.s,
                                              const LivitText(
                                                'Estamos obteniendo el archivo...\nA veces puede tardar un poco',
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      final LivitMediaFile media = _allMedia[index];
                                      if (!File(media.filePath!).existsSync()) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          setState(() {
                                            _allMedia.removeAt(index);
                                            _currentIndex = max(_currentIndex - 1, 0);
                                            _hasChanges = true;
                                          });
                                          _saveChanges();
                                          _showDialog('El archivo no existe', 'Es posible que se haya eliminado automáticamente.');
                                        });
                                        return Container();
                                      }
                                      if (media is LivitMediaVideo) {
                                        return _buildVideoView(media);
                                      } else {
                                        return _buildImageView(media as LivitMediaImage);
                                      }
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
                LivitSpaces.xs,
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
