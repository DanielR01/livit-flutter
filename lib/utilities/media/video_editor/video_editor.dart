import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livit/cloud_models/location/location_media_file.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/video/export_video_service.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/media/video_editor/crop_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/video_editor.dart';

class LivitMediaEditor extends StatefulWidget {
  final String videoPath;
  final String? coverPath;

  const LivitMediaEditor({super.key, required this.videoPath, this.coverPath});

  @override
  State<LivitMediaEditor> createState() => _LivitMediaEditorState();

  static Future<File?> cropImage(String sourcePath) async {
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
          rotateButtonsHidden: true,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}

class _LivitMediaEditorState extends State<LivitMediaEditor> with TickerProviderStateMixin {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = LivitBarStyle.height;

  String? _coverPath;

  late final VideoEditorController _controller = VideoEditorController.file(
    File(widget.videoPath),
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  late final TabController _tabController;

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
    _isExporting.dispose();
    _controller.dispose();
    _tabController.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  Future<void> _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final appDocDir = await getApplicationDocumentsDirectory();

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      outputDirectory: appDocDir.path,
    );

    final executeConfig = await config.getExecuteConfig();

    await ExportService.runFFmpegCommand(
      executeConfig,
      onProgress: (stats) {
        _exportingProgress.value = config.getFFmpegProgress(stats.getTime().toInt());
      },
      onError: (e, s) {
        _showErrorSnackBar("Error on export video :(");
      },
      onCompleted: (file) async {
        _isExporting.value = false;
        if (!mounted) return;

        // Export cover after video is done
        await _exportCover(file);
      },
    );
  }

  Future<void> _exportCover(File videoFile) async {
    if (_coverPath != null) {
      final LivitLocationMediaImage coverImage = LivitLocationMediaImage(
        file: File(_coverPath!),
        url: '',
      );
      final LivitLocationMediaVideo video = LivitLocationMediaVideo(
        file: videoFile,
        url: '',
        cover: coverImage,
      );
      Navigator.pop(context, video);
      return;
    }
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        final LivitLocationMediaImage coverImage = LivitLocationMediaImage(
          file: cover,
          url: '',
        );
        final LivitLocationMediaVideo video = LivitLocationMediaVideo(
          file: videoFile,
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
        backgroundColor: Colors.black,
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
                                builder: (_, bool export, Widget? child) => AnimatedSize(
                                  duration: kThemeAnimationDuration,
                                  child: export ? child : null,
                                ),
                                child: AlertDialog(
                                  title: ValueListenableBuilder(
                                    valueListenable: _exportingProgress,
                                    builder: (_, double value, __) => Text(
                                      "Exporting video ${(value * 100).ceil()}%",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
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
            ArrowBackButton(onPressed: () => Navigator.pop(context)),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => CropPage(controller: _controller),
                      ),
                    ),
                  ),
                  Button.whiteText(
                    isIconBig: true,
                    deactivateSplash: true,
                    text: '',
                    leftIcon: Icons.crop,
                    isActive: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => CropPage(controller: _controller),
                      ),
                    ),
                  ),
                  Button.whiteText(
                    isIconBig: true,
                    deactivateSplash: true,
                    text: '',
                    leftIcon: Icons.rotate_right,
                    isActive: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => CropPage(controller: _controller),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Button.main(
              isActive: true,
              onPressed: () async {
                await _exportVideo();
              },
              text: 'Continuar',
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
            onPressed: () {
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
                onPressed: () async {
                  final cover = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (cover == null) return;
                  final croppedFile = await LivitMediaEditor.cropImage(cover.path);
                  if (croppedFile == null) return;
                  _coverPath = croppedFile.path;
                  setState(() {});
                },
                text: 'Subir portada',
                rightIcon: CupertinoIcons.upload_circle,
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
                        Icons.check_circle,
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

