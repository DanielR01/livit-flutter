import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'dart:io';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/background/background_states.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/utilities/background/background_defaults.dart';
import 'package:livit/utilities/background/background_exception.dart';
import 'package:livit/utilities/background/blend_mask.dart';
import 'package:path_provider/path_provider.dart';

class MainBackground extends StatefulWidget {
  const MainBackground({super.key});

  @override
  State<MainBackground> createState() => _MainBackgroundState();
}

class _MainBackgroundState extends State<MainBackground> with TickerProviderStateMixin {
  Timer? _ticker;
  Duration _lastSpeedUpdate = Duration.zero;
  Duration _lastFrameTime = Duration.zero;
  static const int _targetFPS = 30;
  static const double _frameInterval = 1000.0 / _targetFPS;
  static const double _animationIncrement = 0.00125 * (60.0 / _targetFPS); // Adjusted for 30 FPS

  double _currentSpeed = 0;

  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<Color?>> _colorAnimations;

  late List<Animation<Offset>> _originalPositionAnimations;
  late List<Animation<Color?>> _originalColorAnimations;

  bool? _isLowEndDevice;
  late AnimationController _mainController;

  String? _cachedBackgroundPath;
  bool _isBackgroundCached = false;

  late List<List<List<double>>> _colorfulPositions;

  bool _isGoingToOrigin = false;
  static const double _minTransitionSpeed = 0.25;
  static const double _maxTransitionSpeed = 7;

  late final BackgroundBloc _backgroundBloc;
  AnimationSpeed _lastSpeed = AnimationSpeed.stopped;

  bool _showStaticBackground = true;

  bool _isGeneratingBackground = false;

  late ImageProvider _cachedImage;
  bool _isImagePreloaded = false;

  final errorReporter = ErrorReporter(viewName: 'MainBackground');

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      value: 0,
    );
    _backgroundBloc = BlocProvider.of<BackgroundBloc>(context);
    _backgroundBloc.add(BackgroundOnOrigin());
    _setupAnimations();
    _checkDeviceCapabilities();
    _startTicker();
  }

  Future<void> _initCachedBackground() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cachedBackgroundPath = '${appDir.path}/cached_background.png';
  }

  Future<void> _checkDeviceCapabilities() async {
    _isLowEndDevice = await context.read<BackgroundBloc>().checkIsLowEndDevice();
    return;
  }

  void _setupAnimations() {
    _originalPositionAnimations = List.generate(
      BackgroundDefaults.defaultBlobPaths.length,
      (index) => _createPositionAnimation(index),
    );

    _originalColorAnimations = List.generate(
      BackgroundDefaults.defaultBlobPaths.length,
      (index) => _createColorAnimation(index),
    );
    _positionAnimations = _originalPositionAnimations;
    _colorAnimations = _originalColorAnimations;
  }

  Animation<Offset> _createPositionAnimation(int index) {
    _colorfulPositions = BackgroundDefaults.defaultBlobPositions
        .map((blobSet) => blobSet.map((position) => [position[0] * 0.9, position[1] * 0.9]).toList())
        .toList();
    return TweenSequence<Offset>(
      List.generate(
        _colorfulPositions[index].length,
        (stateIndex) {
          final currentPos = _colorfulPositions[index][stateIndex];
          final nextPos = _colorfulPositions[index][(stateIndex + 1) % _colorfulPositions[index].length];
          return TweenSequenceItem(
            tween: Tween<Offset>(
              begin: Offset(currentPos[0], currentPos[1]),
              end: Offset(nextPos[0], nextPos[1]),
            ),
            weight: 1,
          );
        },
      ),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.linear,
    ));
  }

  Animation<Color?> _createColorAnimation(int index) {
    return TweenSequence<Color?>(
      List.generate(
        BackgroundDefaults.defaultBlobColorStates[index].length,
        (stateIndex) => TweenSequenceItem(
          tween: ColorTween(
            begin: BackgroundDefaults.defaultBlobColorStates[index][stateIndex],
            end: BackgroundDefaults.defaultBlobColorStates[index]
                [(stateIndex + 1) % BackgroundDefaults.defaultBlobColorStates[index].length],
          ),
          weight: 1,
        ),
      ),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.linear,
    ));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(
      Duration(milliseconds: _frameInterval.toInt()),
      _onTick,
    );
  }

  void _onTick(Timer timer) {
    if (_isLowEndDevice == null) {
      _checkDeviceCapabilities();
    } else if (_isLowEndDevice!) {
      return;
    }
    if (_isGoingToOrigin) {
      _handleOriginTransition(timer);
    } else {
      _handleNormalAnimation(timer);
    }
  }

  void _handleNormalAnimation(Timer timer) {
    if ((_backgroundBloc.state.mode != BackgroundMode.dynamic) ||
        (_isGoingToOrigin && _mainController.value == 0 && _currentSpeed == 0) ||
        _backgroundBloc.state.speed == AnimationSpeed.stopped) return;

    final elapsed = Duration(milliseconds: timer.tick * _frameInterval.toInt());
    final targetSpeed = _backgroundBloc.state.speed.value;
    final interpolationSpeed = _backgroundBloc.state.interpolationSpeed;

    if (elapsed - _lastSpeedUpdate > const Duration(milliseconds: 50) &&
        (_currentSpeed < targetSpeed * 0.95 || _currentSpeed > targetSpeed * 1.05)) {
      _lastSpeedUpdate = elapsed;
      _currentSpeed = lerpDouble(_currentSpeed, targetSpeed, interpolationSpeed) ?? targetSpeed;
    }
    if (_currentSpeed == 0) return;
    if (elapsed - _lastFrameTime > Duration(milliseconds: (_frameInterval / (_currentSpeed * 1.25)).floor())) {
      _lastFrameTime = elapsed;
      if (mounted) {
        setState(() {
          _mainController.value = (_mainController.value + (_animationIncrement * _currentSpeed)) % 1;
        });
      }
    }
  }

  void _handleOriginTransition(Timer timer) {
    final avgDistance = 1 - _mainController.value;
    _currentSpeed = lerpDouble(
            _currentSpeed,
            min(_maxTransitionSpeed,
                max(_minTransitionSpeed, (_maxTransitionSpeed - _minTransitionSpeed) * avgDistance + _minTransitionSpeed)),
            _backgroundBloc.state.interpolationSpeed) ??
        min(_maxTransitionSpeed, max(_minTransitionSpeed, (_maxTransitionSpeed - _minTransitionSpeed) * avgDistance + _minTransitionSpeed));
    _currentSpeed = min(_currentSpeed, _lastSpeed.value);
    if (avgDistance < 0.005) {
      _currentSpeed = 0;
      _showStaticBackground = true;
      _mainController.value = 0;
      _backgroundBloc.add(BackgroundOnOrigin());
      _positionAnimations = _originalPositionAnimations;
      _colorAnimations = _originalColorAnimations;
      setState(() {});
      return;
    }
    final elapsed = Duration(milliseconds: timer.tick * _frameInterval.toInt());
    if (_currentSpeed == 0) return;
    if (elapsed - _lastFrameTime > Duration(milliseconds: (_frameInterval / (_currentSpeed * 1.25)).floor())) {
      _lastFrameTime = elapsed;
      if (mounted) {
        setState(() {
          _mainController.value = (_mainController.value + (_animationIncrement * _currentSpeed)) % 1;
        });
      }
    }
  }

  Future<bool> getCachedBackground() async {
    if (_isBackgroundCached) return true;
    try {
      if (_cachedBackgroundPath == null) {
        await _initCachedBackground();
        if (_cachedBackgroundPath == null) {
          throw BackgroundCouldNotInitCachedBackgroundException();
        }
      }
      if (await File(_cachedBackgroundPath!).exists()) {
        debugPrint('✅ [MainBackground] Cached background file exists');
        await _preloadImage();
        _isBackgroundCached = true;
        if (!_backgroundBloc.state.isBackgroundGenerated) {
          _backgroundBloc.add(BackgroundGeneratedBackground());
        }
        return true;
      } else {
        debugPrint('❌ [MainBackground] Cached background file does not exist');
        if (mounted) {
          await generateAndCacheBackground(context);
          if (await File(_cachedBackgroundPath!).exists()) {
            await _preloadImage();
            if (!_isImagePreloaded) {
              throw BackgroundPreloadException(details: 'Could not preload cached background');
            }
            _isBackgroundCached = true;
            return true;
          }
          throw BackgroundGenerateException(details: 'Cached background file does not exist');
        }
      }
    } catch (e) {
      errorReporter.reportError(e, StackTrace.current);
      debugPrint('🚨 [MainBackground] Error checking cached background: $e');
      return false;
    }
    errorReporter.reportError(Exception('Unknown error getting cached background'), StackTrace.current);
    return false;
  }

  Future<void> generateAndCacheBackground(BuildContext context) async {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final devicePixelRatio = View.of(context).devicePixelRatio;
    final overlay = Overlay.of(context);
    if (_isGeneratingBackground) return;
    _isGeneratingBackground = true;
    debugPrint('🔄 [MainBackground] Generating and caching background');

    if (_isLowEndDevice == null) {
      await _checkDeviceCapabilities();
    }

    final directory = await getApplicationDocumentsDirectory();
    _cachedBackgroundPath = '${directory.path}/cached_background.png';

    try {
      final boundaryKey = GlobalKey();
      final overlayEntry = OverlayEntry(
        builder: (context) => RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: screenWidth,
            height: screenHeight,
            color: LivitColors.mainBlack,
            child: Stack(
              children: [
                ...BackgroundDefaults.defaultBlobPaths.asMap().entries.map(
                  (entry) {
                    int index = entry.key;
                    String blob = entry.value;
                    final initialPosition = _colorfulPositions[index][0];
                    final initialColor = BackgroundDefaults.defaultBlobColorStates[index][0];

                    return Positioned(
                      left: screenWidth * initialPosition[0] / 390 - 150,
                      top: screenHeight * initialPosition[1] / 844 - 150,
                      child: Image.asset(
                        blob,
                        height: BackgroundDefaults.defaultBlobHeights[index] * screenHeight,
                        color: initialColor,
                        cacheHeight: (BackgroundDefaults.defaultBlobHeights[index] * screenHeight).toInt(),
                        filterQuality: FilterQuality.high,
                      ),
                    );
                  },
                ),
                BlendMask(
                  opacity: 1,
                  blendMode: BlendMode.multiply,
                  child: DotsBackground(
                    blurred: false,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (mounted) {
        overlay.insert(overlayEntry);
        debugPrint('✅ [MainBackground] Overlay inserted');
      }
      final maxAttempts = 100;
      final minAttempts = _isLowEndDevice ?? false ? 10 : 3;
      int attempts = 0;
      while (attempts < maxAttempts) {
        debugPrint('🔄 [MainBackground] Attempt ${attempts + 1} of $maxAttempts');
        await Future.delayed(const Duration(milliseconds: 100));

        final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          // Check if the boundary is laid out and ready
          if (boundary.hasSize && boundary.size.width > 0 && boundary.size.height > 0 && !boundary.debugNeedsPaint) {
            debugPrint('✅ [MainBackground] Boundary is ready for capture');
            if (attempts >= minAttempts) {
              break;
            }
          }
        }
        attempts++;
      }

      // After loop, verify boundary is really ready
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.hasSize) {
        throw Exception('🚨 [MainBackground] Failed to get a valid boundary after $maxAttempts attempts');
      }

      final image = await boundary.toImage(pixelRatio: devicePixelRatio);
      debugPrint('✅ [MainBackground] Image captured');
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      debugPrint('✅ [MainBackground] Byte data captured');
      final buffer = byteData!.buffer.asUint8List();
      debugPrint('✅ [MainBackground] Buffer captured');

      await File(_cachedBackgroundPath!).writeAsBytes(buffer);
      debugPrint('✅ [MainBackground] File written');

      overlayEntry.remove();
      debugPrint('✅ [MainBackground] Overlay removed');
      _isGeneratingBackground = false;
      if (mounted) setState(() {});
      debugPrint('✅ [MainBackground] Background cached');
    } catch (e) {
      errorReporter.reportError(BackgroundGenerateException(details: e.toString()), StackTrace.current);
      debugPrint('🚨 [MainBackground] Error generating cached background: $e');
    }
  }

  Future<void> _preloadImage() async {
    try {
      if (_cachedBackgroundPath == null) {
        throw Exception('🚨 [MainBackground] Cached background path is null');
      }
      if (!await File(_cachedBackgroundPath!).exists()) {
        throw Exception('🚨 [MainBackground] Cached background file does not exist');
      }
      _cachedImage = FileImage(File(_cachedBackgroundPath!));
      if (mounted) {
        await precacheImage(_cachedImage, context);
        debugPrint('✅ [MainBackground] Image preloaded');
        setState(() {
          _isImagePreloaded = true;
        });
      }
    } catch (e) {
      errorReporter.reportError(BackgroundPreloadException(details: e.toString()), StackTrace.current);
      debugPrint('🚨 [MainBackground] Error preloading cached background: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    return FutureBuilder<bool>(
      future: getCachedBackground(),
      builder: (context, snapshot) {
        return BlocBuilder<BackgroundBloc, BackgroundState>(
          buildWhen: (previous, current) => previous.speed != current.speed || previous.isGoingToOrigin != current.isGoingToOrigin,
          builder: (context, state) {
            if (state.speed != AnimationSpeed.stopped) {
              _lastSpeed = state.speed;
            }
            _isGoingToOrigin = state.isGoingToOrigin;
            if (state.isGoingToOrigin && !_isGoingToOrigin) {
              final nextPositions = _positionAnimations.map((anim) => anim.value).toList();
              final nextColors = _colorAnimations.map((anim) => anim.value).toList();
              _positionAnimations = List.generate(
                BackgroundDefaults.defaultBlobPaths.length,
                (index) => TweenSequence<Offset>([
                  TweenSequenceItem(
                    tween: Tween<Offset>(
                      begin: nextPositions[index],
                      end: Offset(
                        _colorfulPositions[index][0][0],
                        _colorfulPositions[index][0][1],
                      ),
                    ),
                    weight: 1,
                  ),
                ]).animate(CurvedAnimation(
                  parent: _mainController,
                  curve: Curves.linear,
                )),
              );

              // Reset color animations to original first state
              _colorAnimations = List.generate(
                BackgroundDefaults.defaultBlobPaths.length,
                (index) => ColorTween(
                  begin: nextColors[index],
                  end: BackgroundDefaults.defaultBlobColorStates[index][0],
                ).animate(CurvedAnimation(
                  parent: _mainController,
                  curve: Curves.linear,
                )),
              );

              // Reset controller to start new animation
              _mainController.value = 0;
            }
            if (state.speed != AnimationSpeed.stopped) {
              _showStaticBackground = false;
            }

            if (!snapshot.hasData) {
              return Container(color: LivitColors.mainBlack);
            }
            // if (!_isImagePreloaded) {
            //   return Container(color: LivitColors.mainBlack);
            // }
            if (snapshot.data!) {
              if (_showStaticBackground || (_isLowEndDevice ?? false)) {
                return Image(
                  image: _cachedImage,
                  width: screenWidth,
                  height: screenHeight,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                );
              } else {
                return _buildDynamicBackground(screenWidth, screenHeight);
              }
            }
            return Container(color: LivitColors.mainBlack);
          },
        );
      },
    );
  }

  Widget _buildDynamicBackground(double screenWidth, double screenHeight) {
    return Container(
      color: LivitColors.mainBlack,
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          RepaintBoundary(
            child: Blobs(
              positionAnimations: _positionAnimations,
              colorAnimations: _colorAnimations,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              svg: false,
            ),
          ),
          BlendMask(
            opacity: 1,
            blendMode: BlendMode.multiply,
            child: DotsBackground(
              blurred: false,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _ticker?.cancel();
    super.dispose();
  }
}

// Update Blobs widget to match new animation system
class Blobs extends StatelessWidget {
  final List<Animation<Offset>> positionAnimations;
  final List<Animation<Color?>> colorAnimations;
  final double screenWidth;
  final double screenHeight;
  final bool svg;

  const Blobs({
    required this.positionAnimations,
    required this.colorAnimations,
    required this.screenHeight,
    required this.screenWidth,
    required this.svg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: BackgroundDefaults.defaultBlobPaths.asMap().entries.map(
        (entry) {
          int index = entry.key;
          String blob = entry.value;
          final position = positionAnimations[index].value;
          final color = colorAnimations[index].value;

          return Positioned(
            left: screenWidth * position.dx / 390 - 150,
            top: screenHeight * position.dy / 844 - 150,
            child: Image.asset(
              blob,
              height: BackgroundDefaults.defaultBlobHeights[index] * screenHeight,
              color: color,
              cacheHeight: (BackgroundDefaults.defaultBlobHeights[index] * screenHeight).toInt(),
              filterQuality: FilterQuality.high,
            ),
          );
        },
      ).toList(),
    );
  }
}

class DotsBackground extends StatelessWidget {
  final bool blurred;
  final double screenWidth;
  final double screenHeight;
  const DotsBackground({
    super.key,
    required this.blurred,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = blurred ? 'assets/images/dots-blurred.png' : 'assets/images/dots.png';
    return Container(
      width: screenWidth,
      height: screenHeight,
      color: LivitColors.mainBlack,
      child: Image(
        image: AssetImage(imagePath),
        width: screenWidth,
        height: screenHeight,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }
}
