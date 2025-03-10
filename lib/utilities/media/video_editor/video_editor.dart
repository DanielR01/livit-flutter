import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livit/models/media/location_media_file.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/files/temp_file_manager.dart';
import 'package:livit/services/firebase_storage/firebase_storage_constants.dart';
import 'package:livit/services/video/export_video_service.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/media/media_file_cleanup.dart';
import 'package:livit/utilities/media/video_editor/crop_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/video_editor.dart';
import 'package:livit/services/video/video_compression_service.dart';

enum LivitMediaEditorProcess {
  idle,
  exporting,
  exportingCover,
  compressing,
  finished,
  error,
}

class LivitMediaEditor extends StatefulWidget {
  final String videoPath;
  final String? coverPath;

  const LivitMediaEditor({super.key, required this.videoPath, this.coverPath});

  @override
  State<LivitMediaEditor> createState() => _LivitMediaEditorState();

  static Future<String?> cropImage(String sourcePath) async {
    try {
      debugPrint('🔥 [LivitMediaEditor] Copying image to temp directory');
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFilePath = '${directory.path}/temp_$timestamp.${sourcePath.split('.').last}';
      await File(sourcePath).copy(tempFilePath);
      debugPrint('📝 [LivitMediaEditor] Cropping image');
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFilePath,
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
            rotateButtonsHidden: true,
          ),
        ],
      );
      return croppedFile?.path;
    } catch (e) {
      debugPrint('🔥 [LivitMediaEditor] Error on cropImage: $e');
      return null;
    }
  }
}

class _LivitMediaEditorState extends State<LivitMediaEditor> with TickerProviderStateMixin {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _exportingProcess = ValueNotifier<LivitMediaEditorProcess>(LivitMediaEditorProcess.idle);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = LivitBarStyle.height;

  String? _coverPath;

  late final VideoEditorController _controller = VideoEditorController.file(
    File(widget.videoPath),
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: FirebaseStorageConstants.maxVideoDurationInSeconds),
  );

  late final TabController _tabController;

  final ErrorReporter _errorReporter = ErrorReporter();

  @override
  void initState() {
    super.initState();
    _coverPath = widget.coverPath;
    _tabController = TabController(length: 2, vsync: this);
    _controller.initialize(aspectRatio: 9 / 16).then((_) => setState(() {})).catchError((error) {
      if (mounted) {
        Navigator.pop(context);
      }
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _exportingProcess.dispose();
    _isExporting.dispose();
    _controller.dispose();
    _tabController.dispose();
    ExportService.dispose();
    MediaFileCleanup.deleteFileByPath(widget.videoPath);
    if (_coverPath != null) {
      MediaFileCleanup.deleteFileByPath(_coverPath!);
    }
    super.dispose();
  }

  void _showErrorSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  Future<void> _exportVideo() async {
    _isExporting.value = true;
    File? trimmedFile;
    String? compressedFilePath;

    try {
      final tempDir = await getTemporaryDirectory();
      await tempDir.create(recursive: true);

      final config = VideoFFmpegVideoEditorConfig(
        _controller,
        outputDirectory: tempDir.path,
      );

      final executeConfig = await config.getExecuteConfig();

      await ExportService.runFFmpegCommand(
        executeConfig,
        onProgress: (stats) {
          _exportingProgress.value = config.getFFmpegProgress(stats.getTime().toInt());
          _exportingProcess.value = LivitMediaEditorProcess.exporting;
        },
        onError: (e, s) {
          debugPrint('❌ [LivitMediaEditor] Error on export video: $e');
          if (e is Exception) {
            debugPrint('❌ [LivitMediaEditor] Exception: ${e.toString()}');
          }
          _errorReporter.reportError(e, s);
          _exportingProcess.value = LivitMediaEditorProcess.error;
        },
        onCompleted: (file) async {
          await TempFileManager.trackFile(file.path);

          compressedFilePath = await VideoCompressionService.compressVideo(
            inputFilePath: file.path,
            onProgress: (stats) {
              _exportingProgress.value = config.getFFmpegProgress(stats.getTime().toInt());
              _exportingProcess.value = LivitMediaEditorProcess.compressing;
            },
            onError: (e, s) {
              debugPrint('❌ [LivitMediaEditor] Error on export video: $e');
              _exportingProcess.value = LivitMediaEditorProcess.error;
              _errorReporter.reportError(e, s);
            },
            onCompleted: (compressedFile) async {
              await TempFileManager.trackFile(compressedFile.path);
              debugPrint('📑 [LivitMediaEditor] compressedFilePath: ${compressedFile.path}');
              debugPrint('📑 [LivitMediaEditor] compressedFilePath size: ${compressedFile.lengthSync() / 1024 / 1024} MB');
              await MediaFileCleanup.deleteFileByPath(file.path);
              _exportingProcess.value = LivitMediaEditorProcess.exportingCover;
              await _exportCover(compressedFile.path);
              if (_exportingProcess.value == LivitMediaEditorProcess.error) return;
              _exportingProcess.value = LivitMediaEditorProcess.finished;
            },
          );
        },
      );
    } catch (e) {
      await MediaFileCleanup.deleteFile(trimmedFile);
      await MediaFileCleanup.deleteFileByPath(compressedFilePath);
      _exportingProcess.value = LivitMediaEditorProcess.error;
      _errorReporter.reportError(e, StackTrace.current);
    }
  }

  Future<void> _exportCover(String videoFilePath) async {
    final tempDir = await getTemporaryDirectory();
    await tempDir.create(recursive: true);

    if (_coverPath != null) {
      final LivitMediaImage coverImage = LivitMediaImage(
        filePath: _coverPath!,
        url: '',
      );
      final LivitMediaVideo video = LivitMediaVideo(
        filePath: videoFilePath,
        url: '',
        cover: coverImage,
      );
      Navigator.pop(context, video);
      return;
    }
    final config = CoverFFmpegVideoEditorConfig(
      _controller,
      outputDirectory: tempDir.path,
    );
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      debugPrint('❌ [LivitMediaEditor] Error on cover exportation initialization.');
      _exportingProcess.value = LivitMediaEditorProcess.error;
      _errorReporter.reportError(Exception('Error on cover exportation initialization.'), StackTrace.current);
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) {
        debugPrint('❌ [LivitMediaEditor] Error on cover exportation: $e');
        _exportingProcess.value = LivitMediaEditorProcess.error;
        _errorReporter.reportError(e, s);
      },
      onCompleted: (cover) {
        if (!mounted) return;

        final LivitMediaImage coverImage = LivitMediaImage(
          filePath: cover.path,
          url: '',
        );
        final LivitMediaVideo video = LivitMediaVideo(
          filePath: videoFilePath,
          url: '',
          cover: coverImage,
        );
        Navigator.pop(context, video);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {},
      child: Scaffold(
        backgroundColor: LivitColors.mainBlack,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topNavBar(),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CropGridViewer.preview(controller: _controller),
                                        AnimatedBuilder(
                                          animation: _controller.video,
                                          builder: (_, __) => AnimatedOpacity(
                                            opacity: _controller.isPlaying ? 0 : 1,
                                            duration: kThemeAnimationDuration,
                                            child: GestureDetector(
                                              onTap: _controller.video.play,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    _coverPath == null ? CoverViewer(controller: _controller) : Image.asset(_coverPath!)
                                  ],
                                ),
                              ),
                              Container(
                                height: 200,
                                margin: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    TabBar(
                                      onTap: (index) {
                                        setState(() {
                                          _tabController.index = index;
                                        });
                                      },
                                      controller: _tabController,
                                      labelColor: LivitColors.whiteActive,
                                      unselectedLabelColor: LivitColors.whiteInactive,
                                      indicatorColor: LivitColors.whiteActive,
                                      tabs: [
                                        Button.whiteText(
                                          deactivateSplash: true,
                                          text: 'Duración',
                                          isActive: true,
                                          onPressed: () {
                                            setState(() {
                                              _tabController.index = 0;
                                            });
                                          },
                                          isIconBig: true,
                                        ),
                                        Button.whiteText(
                                          deactivateSplash: true,
                                          text: 'Portada',
                                          isActive: true,
                                          onPressed: () {
                                            setState(() {
                                              _tabController.index = 1;
                                            });
                                          },
                                          isIconBig: true,
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        controller: _tabController,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: _trimSlider(),
                                          ),
                                          _coverSelection(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _isExporting,
                                builder: (_, bool export, Widget? child) {
                                  if (!export) return const SizedBox.shrink();
                                  return ValueListenableBuilder(
                                    valueListenable: _exportingProgress,
                                    builder: (_, double value, __) {
                                      return ValueListenableBuilder(
                                        valueListenable: _exportingProcess,
                                        builder: (_, LivitMediaEditorProcess process, __) {
                                          late final String text;
                                          if (process == LivitMediaEditorProcess.error) {
                                            text = "Error al exportar video";
                                          } else if (_exportingProcess.value == LivitMediaEditorProcess.exporting) {
                                            text = "Exportando video ${(value * 100).ceil()}%";
                                          } else if (_exportingProcess.value == LivitMediaEditorProcess.compressing) {
                                            text = "Comprimiendo video ${(value * 100).ceil()}%";
                                          } else if (_exportingProcess.value == LivitMediaEditorProcess.exportingCover) {
                                            text = "Exportando portada";
                                          } else if (_exportingProcess.value == LivitMediaEditorProcess.finished) {
                                            text = "Video exportado";
                                          } else {
                                            text = "Esperando";
                                          }
                                          return Padding(
                                            padding: LivitContainerStyle.paddingFromScreen,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: AnimatedSize(
                                                    duration: kThemeAnimationDuration,
                                                    curve: Curves.easeInOut,
                                                    child: Button.main(
                                                      text: text,
                                                      isActive: true,
                                                      deactivateSplash: true,
                                                      onTap: () {},
                                                      rightIcon: process == LivitMediaEditorProcess.error
                                                          ? CupertinoIcons.exclamationmark_circle
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Center(
                child: CupertinoActivityIndicator(
                  radius: LivitButtonStyle.iconSize / 2,
                  color: LivitColors.whiteActive,
                ),
              ),
      ),
    );
  }

  Widget _topNavBar() {
    return SizedBox(
      height: height,
      child: Padding(
        padding: LivitContainerStyle.paddingFromScreen,
        child: Row(
          children: [
            ArrowBackButton(onPressed: () {
              Navigator.pop(context);
            }),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button.whiteText(
                    isIconBig: true,
                    deactivateSplash: true,
                    text: '',
                    leftIcon: Icons.rotate_left,
                    isActive: true,
                    onPressed: () {
                      if (_isExporting.value == true) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => CropPage(controller: _controller),
                        ),
                      );
                    },
                  ),
                  Button.whiteText(
                    isIconBig: true,
                    deactivateSplash: true,
                    text: '',
                    leftIcon: Icons.crop,
                    isActive: true,
                    onPressed: () {
                      if (_isExporting.value == true) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => CropPage(controller: _controller),
                        ),
                      );
                    },
                  ),
                  Button.whiteText(
                    isIconBig: true,
                    deactivateSplash: true,
                    text: '',
                    leftIcon: Icons.rotate_right,
                    isActive: true,
                    onPressed: () {
                      if (_isExporting.value == true) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => CropPage(controller: _controller),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: kThemeAnimationDuration,
              curve: Curves.easeInOut,
              child: ValueListenableBuilder(
                valueListenable: _exportingProcess,
                builder: (_, LivitMediaEditorProcess process, __) {
                  if (process == LivitMediaEditorProcess.idle) {
                    return Button.main(
                      isActive: true,
                      isLoading: process != LivitMediaEditorProcess.idle && process != LivitMediaEditorProcess.error,
                      onTap: () async {
                        await _exportVideo();
                      },
                      text: 'Continuar',
                    );
                  } else if (process == LivitMediaEditorProcess.error) {
                    return Button.main(
                      isActive: true,
                      onTap: () async {
                        _exportingProcess.value = LivitMediaEditorProcess.exporting;
                        await Future.delayed(kThemeAnimationDuration);
                        await _exportVideo();
                      },
                      text: 'Intentar de nuevo',
                    );
                  } else {
                    return Button.icon(
                      isLoading: true,
                      isIconBig: false,
                      isActive: true,
                      onTap: () async {
                        _exportingProcess.value = LivitMediaEditorProcess.exporting;
                        await Future.delayed(kThemeAnimationDuration);
                        await _exportVideo();
                      },
                      activeBackgroundColor: LivitColors.whiteActive,
                      activeColor: LivitColors.mainBlack,
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) =>
      [duration.inMinutes.remainder(60).toString().padLeft(2, '0'), duration.inSeconds.remainder(60).toString().padLeft(2, '0')].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              LivitText(
                formatter(
                  Duration(
                    seconds: pos.toInt(),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  LivitText(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  LivitText(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            quantity: 10,
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    if (_coverPath != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Button.secondary(
            isActive: true,
            onTap: () {
              MediaFileCleanup.deleteFile(File(_coverPath!));
              _coverPath = null;
              setState(() {});
            },
            text: 'Eliminar portada',
          ),
        ],
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Button.secondary(
                isActive: true,
                onTap: () async {
                  if (_isExporting.value == true) return;
                  final XFile? cover = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (cover == null) return;
                  await TempFileManager.trackFile(cover.path);
                  final String? croppedFilePath = await LivitMediaEditor.cropImage(cover.path);
                  if (croppedFilePath == null) return;
                  await TempFileManager.trackFile(croppedFilePath);
                  _coverPath = croppedFilePath;
                  await MediaFileCleanup.deleteFileByPath(cover.path);
                  setState(() {});
                },
                text: 'Subir portada',
                rightIcon: CupertinoIcons.arrow_up_circle,
              ),
            ),
            LivitSpaces.s,
            Center(
              child: CoverSelection(
                controller: _controller,
                size: height,
                quantity: 20,
                wrap: Wrap(
                  spacing: LivitSpaces.xsDouble,
                  runSpacing: LivitSpaces.xsDouble,
                ),
                selectedCoverBuilder: (cover, size) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      cover,
                      Icon(
                        CupertinoIcons.checkmark_alt_circle,
                        color: const CoverSelectionStyle().selectedBorderColor,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
