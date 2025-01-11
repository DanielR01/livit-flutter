import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:livit/cloud_models/location/location.dart';
import 'package:livit/cloud_models/location/location_media.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_event.dart';
import 'package:livit/services/firestore_storage/bloc/locations/location_state.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/display/livit_display_area.dart';
import 'package:livit/utilities/media/video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:livit/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationMediaPreviewPlayer extends StatefulWidget {
  final LivitLocation location;
  final int index;
  final bool addMedia;

  const LocationMediaPreviewPlayer({
    super.key,
    required this.location,
    this.index = 0,
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
  int _displayedIndex = 0;
  int _displayedThumbnailIndex = 0;

  bool _isAddingMedia = false;
  bool _isReplacingMedia = false;

  bool _isShowingCover = false;

  bool _isControlsVisible = true;
  Timer? _controlsTimer;

  bool get isVideo => _isAddingMedia ? false : _allMedia.isNotEmpty && _allMedia[_currentIndex] is LivitLocationMediaVideo;

  late final LocationBloc _locationBloc;

  late LivitLocation _location;

  List<LivitLocationMediaFile> get _allMedia => [
        if (_location.media?.mainFile != null) _location.media!.mainFile!,
        ..._location.media?.secondaryFiles?.whereType<LivitLocationMediaFile>() ?? [],
      ];

  @override
  void initState() {
    super.initState();
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _location = _locationBloc.locations.firstWhere((location) => location.id == widget.location.id);
    _setupMediaList();

    if (widget.addMedia) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          setState(() {
            _isAddingMedia = true;
            _currentIndex = _allMedia.length;
          });
          final result = await _pickMedia();
          if (result == null) {
            setState(() {
              _isAddingMedia = false;
              _currentIndex = max(_currentIndex - 1, 0);
            });
            return;
          }

          final LivitLocationMedia locationMedia = LivitLocationMedia(
            mainFile: _currentIndex == 0 ? result : _allMedia[0],
            secondaryFiles: _currentIndex == 0 ? _location.media?.secondaryFiles : [..._location.media?.secondaryFiles ?? [], result],
          );
          if (mounted) {
            BlocProvider.of<LocationBloc>(context).add(
              UpdateLocationMediaLocally(context, location: _location, media: locationMedia),
            );
          }

          setState(
            () {
              _isAddingMedia = false;
            },
          );
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
    if (_allMedia[_currentIndex].filePath != null) {
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
        debugPrint('error: $e');
      }
    }
  }

  void _replaceMedia(LivitLocationMediaFile? newMedia) {
    final List<LivitLocationMediaFile?> auxMedia = [_location.media?.mainFile, ..._location.media?.secondaryFiles ?? []];

    if (newMedia != null) {
      auxMedia[_currentIndex] = newMedia;
    } else {
      auxMedia.removeAt(_currentIndex);
    }

    final LivitLocationMedia locationMedia = LivitLocationMedia(
      mainFile: auxMedia.isNotEmpty ? auxMedia[0] : null,
      secondaryFiles: auxMedia.length > 1 ? auxMedia.sublist(1) : [],
    );

    if (mounted) {
      BlocProvider.of<LocationBloc>(context).add(
        UpdateLocationMediaLocally(context, location: _location, media: locationMedia),
      );
    }
  }

  void _addMedia() async {
    setState(() {
      _isAddingMedia = true;
      if (_location.media?.mainFile != null) {
        _currentIndex++;
      }
    });
    final result = await _pickMedia();
    if (result == null) {
      setState(() {
        _isAddingMedia = false;
        _currentIndex = max(_currentIndex - 1, 0);
      });
      return;
    }

    final List<LivitLocationMediaFile?> auxMedia = [
      if (_location.media?.mainFile != null) _location.media!.mainFile!,
      ..._location.media?.secondaryFiles ?? []
    ];

    auxMedia.insert(_currentIndex, result);

    final LivitLocationMedia locationMedia = LivitLocationMedia(
      mainFile: auxMedia[0],
      secondaryFiles: auxMedia.sublist(1),
    );

    if (mounted) {
      BlocProvider.of<LocationBloc>(context).add(
        UpdateLocationMediaLocally(context, location: _location, media: locationMedia),
      );
    }

    setState(() {
      _isAddingMedia = false;
    });
  }

  void _deleteCurrentMedia() async {
    _replaceMedia(null);
    setState(() {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _currentIndex = max(_currentIndex - 1, 0);
    });
  }

  Widget _buildMediaView(LivitLocationMediaFile media) {
    final bool isVideo = media is LivitLocationMediaVideo;
    if (isVideo) {
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

  Widget _buildVideoView(LivitLocationMediaVideo media) {
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

  Widget _buildImageView(LivitLocationMediaImage media) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: LivitContainerStyle.borderRadius / 2,
      ),
      child: Image.file(File(media.filePath!), fit: BoxFit.contain),
    );
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

  Future<LivitLocationMediaFile?> _pickMedia() async {
    final XFile? pickedFile = await ImagePicker().pickMedia(imageQuality: 100);
    if (pickedFile == null) return null;

    final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
    final bool isVideo = ['mp4', 'mov', 'avi'].contains(fileExtension);

    try {
      if (isVideo) {
        if (mounted) {
          return await Navigator.push<LivitLocationMediaVideo>(
            context,
            MaterialPageRoute<LivitLocationMediaVideo>(
              builder: (context) => LivitMediaEditor(videoPath: pickedFile.path),
            ),
          );
        } else {
          return null;
        }
      } else {
        final croppedFilePath = await LivitMediaEditor.cropImage(pickedFile.path);
        if (croppedFilePath == null) return null;
        debugPrint('🖼️ [LocationMediaPreviewPlayer] Cropped image path: $croppedFilePath');
        return LivitLocationMediaImage(filePath: croppedFilePath, url: '');
      }
    } finally {}
  }

  Widget _buildTopBar(String? errorMessage) {
    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.none,
      child: Column(
        children: [
          Padding(
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
                      if (!_locationBloc.areUnsavedChanges) {
                        if (mounted) Navigator.pop(context);
                        return;
                      }
                      final shouldPop = await _onWillPop();
                      if (!shouldPop) return;
                      if (mounted) {
                        BlocProvider.of<LocationBloc>(context).add(DiscardChangesLocally(context));
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    Button.icon(
                      isActive: _allMedia.length < 7 && !_isAddingMedia && !_isReplacingMedia,
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
                      isActive: _locationBloc.areUnsavedChanges && !_isAddingMedia && !_isReplacingMedia,
                      onPressed: () {
                        BlocProvider.of<LocationBloc>(context).add(SaveChangesLocally(context));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (errorMessage != null)
            LivitText(
              errorMessage,
              textType: LivitTextType.small,
              fontWeight: FontWeight.bold,
            ),
        ],
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
                  _replaceMedia(result);
                }
              } else {
                final croppedFilePath = await LivitMediaEditor.cropImage(_allMedia[_currentIndex].filePath!);
                if (croppedFilePath == null) return;
                _replaceMedia(LivitLocationMediaImage(filePath: croppedFilePath, url: ''));
              }
            },
            icon: CupertinoIcons.slider_horizontal_3,
            isShadowActive: true,
          ),
          Button.main(
            text: _isReplacingMedia ? 'Reemplazando' : 'Reemplazar',
            isLoading: _isReplacingMedia,
            isActive: _allMedia.isNotEmpty && !_isAddingMedia && !_isReplacingMedia,
            onPressed: () async {
              setState(() {
                _isReplacingMedia = true;
              });
              final LivitLocationMediaFile? file = await _pickMedia();
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
    if (!_locationBloc.areUnsavedChanges) return true;

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

  void _cleanupCurrentVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    // return _buildVideoView(LivitLocationMediaVideo(
    //     url: '',
    //     filePath: 'assets/test/test_video_afterlife.mp4',
    //     cover: LivitLocationMediaImage(filePath: 'assets/test/test_cover_afterlife.png', url: '')));
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

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        _location = _locationBloc.locations.firstWhere((location) => location.id == widget.location.id);
        return PopScope(
          canPop: !_locationBloc.areUnsavedChanges && !_isAddingMedia && !_isReplacingMedia,
          child: Scaffold(
            body: LivitDisplayArea(
              child: Center(
                child: Column(
                  children: [
                    _buildTopBar(state is LocationsLoaded ? state.errorMessage : null),
                    LivitSpaces.s,
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
                                          final LivitLocationMediaFile media = _allMedia[index];
                                          if (media is LivitLocationMediaVideo) {
                                            return _buildVideoView(media);
                                          } else {
                                            return _buildImageView(media as LivitLocationMediaImage);
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
                    LivitSpaces.s,
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:inview_notifier_list/inview_notifier_list.dart';
// import 'package:livit/cloud_models/location/location.dart';
// import 'package:livit/constants/colors.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';

// class VideoWidget extends StatefulWidget {
//   final String url;
//   final bool play;

//   const VideoWidget({super.key, required this.url, required this.play});

//   @override
//   _VideoWidgetState createState() => _VideoWidgetState();
// }

// class _VideoWidgetState extends State<VideoWidget> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   String? _filePath;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       _filePath = 'assets/test/test_video_afterlife.mp4';
//       _controller = VideoPlayerController.asset(_filePath!);
//       _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//         setState(() {});
//       });

//       if (widget.play) {
//         _controller.play();
//         _controller.setLooping(true);
//       }
//     });
//   }

//   @override
//   void didUpdateWidget(VideoWidget oldWidget) {
//     if (oldWidget.play != widget.play) {
//       if (widget.play) {
//         _controller.play();
//         _controller.setLooping(true);
//       } else {
//         _controller.pause();
//       }
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_filePath != null) {
//       print('filePath: $_filePath');
//       print('file exists: ${File(_filePath!).existsSync()}');
//       return FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Container(
//               decoration: BoxDecoration(color: LivitColors.mainBlack),
//               child: VideoPlayer(_controller),
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       );
//     }
//     return const SizedBox();
//   }
// }

// class LocationMediaPreviewPlayer extends StatelessWidget {
//   final LivitLocation location;
//   final int index;
//   final bool addMedia;

//   const LocationMediaPreviewPlayer({super.key, required this.location, required this.index, this.addMedia = false});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: <Widget>[
//         InViewNotifierList(
//           scrollDirection: Axis.vertical,
//           initialInViewIds: ['0'],
//           isInViewPortCondition: (double deltaTop, double deltaBottom, double viewPortDimension) {
//             return deltaTop < (0.5 * viewPortDimension) && deltaBottom > (0.5 * viewPortDimension);
//           },
//           itemCount: 30,
//           builder: (BuildContext context, int index) {
//             return Container(
//               width: double.infinity,
//               height: 300.0,
//               alignment: Alignment.center,
//               margin: EdgeInsets.symmetric(vertical: 50.0),
//               child: LayoutBuilder(
//                 builder: (BuildContext context, BoxConstraints constraints) {
//                   final InViewState? inViewState = InViewNotifierList.of(context);
//                   if (inViewState == null) return const SizedBox();

//                   inViewState.addContext(context: context, id: '$index');
//                   return AnimatedBuilder(
//                     animation: inViewState,
//                     builder: (BuildContext context, Widget? child) {
//                       return Container(
//                         clipBehavior: Clip.hardEdge,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.red),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: VideoWidget(
//                             play: inViewState.inView('$index'),
//                             url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
//                       );
//                     },
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//         Align(
//           alignment: Alignment.center,
//           child: Container(
//             height: 1.0,
//             color: Colors.redAccent,
//           ),
//         )
//       ],
//     );
//   }
// }
