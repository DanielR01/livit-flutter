import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/utilities/background/blend_mask.dart';
import 'dart:math' show Random;
import 'package:flutter/scheduler.dart';

class MainBackgroundController {
  static final MainBackgroundController _instance = MainBackgroundController._internal();
  factory MainBackgroundController() => _instance;

  MainBackgroundController._internal();

  bool _blurred = false;
  List<List<List<double>>> _blobPositions = MainBackground._defaultBlobPositions;
  List<List<Color>> _blobColorStates = MainBackground._defaultBlobColorStates;

  // Getters and setters
  bool get blurred => _blurred;
  List<List<List<double>>> get blobPositions => _blobPositions;
  List<List<Color>> get blobColorStates => _blobColorStates;

  set blurred(bool value) => _blurred = value;
  set blobPositions(List<List<List<double>>> value) => _blobPositions = value;
  set blobColorStates(List<List<Color>> value) => _blobColorStates = value;
}

class MainBackground extends StatefulWidget {
  static final MainBackground _colorful = MainBackground._internal(
    blurred: false,
    blobPositions:
        _defaultBlobPositions.map((blobSet) => blobSet.map((position) => [position[0] * 0.9, position[1] * 0.9]).toList()).toList(),
    blobColorStates: _defaultBlobColorStates,
  );

  static final MainBackground _normal = MainBackground._internal(
    blurred: false,
    blobPositions: _defaultBlobPositions,
    blobColorStates: _defaultBlobColorStates,
  );

  final bool blurred;
  final List<List<List<double>>> blobPositions;
  final List<List<Color>> blobColorStates;

  const MainBackground._internal({
    required this.blurred,
    required this.blobPositions,
    required this.blobColorStates,
  });

  static MainBackground colorful({bool blurred = false}) {
    _colorful.blurred = blurred;
    return _colorful;
  }

  static MainBackground normal() {
    return _normal;
  }

  static MainBackground colorfulTinted({
    required Color tintColor,
    required double opacity,
  }) {
    final random = Random();
    final tintedBlobColorStates = _defaultBlobColorStates.map((blobColors) {
      return blobColors.map((color) {
        final randomOpacity = (opacity + (random.nextDouble() * 0.7 - 0.35)).clamp(0.0, 1.0);
        return Color.alphaBlend(tintColor.withOpacity(randomOpacity), color);
      }).toList();
    }).toList();

    return MainBackground._internal(
      blurred: false,
      blobPositions: _colorful.blobPositions,
      blobColorStates: tintedBlobColorStates,
    );
  }

  // Add setter for blurred property
  set blurred(bool value) {
    if (_colorful.blurred != value) {
      _colorful.blurred = value;
    }
  }

  // Rest of the existing static properties...
  static final List<String> _defaultBlobPaths = [
    "assets/images/blobs/blob5.png",
    "assets/images/blobs/blob4.png",
    "assets/images/blobs/blob3.png",
    "assets/images/blobs/blob2.png",
    "assets/images/blobs/blob1.png",
  ];
  static final List<double> _defaultBlobHeights = [
    (568 + 300) / 844,
    (542 + 300) / 844,
    (485 + 300) / 844,
    (190 + 300) / 844,
    (307.5 + 300) / 844,
  ];
  static final List<List<List<double>>> _defaultBlobPositions = [
    [
      [306, -206],
      [354, 24],
      [358, -146],
      [330, 622],
      [330, 622],
    ],
    [
      [-495, 739],
      [-495, 739],
      [-182, 842],
      [-182, 842],
      [-182, 842],
    ],
    [
      [-500, 179],
      [-500, 422],
      [-469, -63],
      [-469, 388],
      [-469, 388],
    ],
    [
      [235, 488],
      [296, 726],
      [340, 347],
      [284, 36],
      [310, 190],
    ],
    [
      [-312, -126],
      [-162, -261],
      [0, -265],
      [-17, -191],
      [-486, -36],
    ],
  ];
  static final List<List<Color>> _defaultBlobColorStates = [
    [
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
    ],
    [
      LivitColors.greenActive,
      LivitColors.greenActive,
      LivitColors.greenActive,
      LivitColors.whiteActive,
      LivitColors.whiteActive,
    ],
    [
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
    ],
    const [
      Color.fromARGB(255, 30, 104, 249),
      Color.fromARGB(255, 30, 104, 249),
      Color.fromARGB(255, 30, 104, 249),
      Color.fromARGB(255, 30, 104, 249),
      Color.fromARGB(255, 30, 104, 249),
    ],
    [
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.mainBlueActive,
      LivitColors.whiteActive,
      LivitColors.whiteActive,
    ],
  ];

  @override
  State<MainBackground> createState() => _MainBackgroundState();
}

class _MainBackgroundState extends State<MainBackground> with TickerProviderStateMixin {
  late Ticker _ticker;
  late AnimationController _mainController;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<Color?>> _colorAnimations;

  List<int> animationStates = [];

  // Lower frame rate but maintain speed
  static const int _targetFrameRate = 15;
  static const double _frameInterval = 1000.0 / _targetFrameRate;
  static const double _animationIncrement = 0.001 * (60.0 / _targetFrameRate); // Adjust increment for lower FPS
  Duration _lastFrameTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    animationStates = widget.blobPositions[0].map((_) => 0).toList();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 25000),
      vsync: this,
    );

    _setupSimultaneousAnimations();
    
    _ticker = createTicker((elapsed) {
      if (elapsed - _lastFrameTime > Duration(milliseconds: _frameInterval.floor())) {
        _lastFrameTime = elapsed;
        if (mounted) {
          setState(() {
            // Update animation with adjusted increment
            _mainController.value = (_mainController.value + _animationIncrement) % 1;
          });
        }
      }
    });

    _ticker.start();
  }

  void _setupSimultaneousAnimations() {
    _positionAnimations = List.generate(
      MainBackground._defaultBlobPaths.length,
      (index) {
        return TweenSequence<Offset>(
          List.generate(
            widget.blobPositions[index].length,
            (stateIndex) {
              final currentPos = widget.blobPositions[index][stateIndex];
              final nextPos = widget.blobPositions[index][(stateIndex + 1) % widget.blobPositions[index].length];

              return TweenSequenceItem(
                tween: Tween<Offset>(
                  begin: Offset(currentPos[0], currentPos[1]),
                  end: Offset(nextPos[0], nextPos[1]),
                ),
                weight: 1,
              );
            },
          ),
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Curves.linear,
          ),
        );
      },
    );

    _colorAnimations = List.generate(
      MainBackground._defaultBlobPaths.length,
      (index) {
        return TweenSequence<Color?>(
          List.generate(
            widget.blobColorStates[index].length,
            (stateIndex) {
              return TweenSequenceItem(
                tween: ColorTween(
                  begin: widget.blobColorStates[index][stateIndex],
                  end: widget.blobColorStates[index][(stateIndex + 1) % widget.blobColorStates[index].length],
                ),
                weight: 1,
              );
            },
          ),
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Curves.linear,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _mainController.dispose();
    super.dispose();
  }

  // Update Blobs widget to use the new animation system
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      color: LivitColors.mainBlack,
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Blobs(
                controller: _mainController,
                positionAnimations: _positionAnimations,
                colorAnimations: _colorAnimations,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                svg: false,
              );
            },
          ),
          BlendMask(
            opacity: 1,
            blendMode: BlendMode.multiply,
            child: DotsBackground(
              blurred: widget.blurred,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
          ),
        ],
      ),
    );
  }
}

// Update Blobs widget to match new animation system
class Blobs extends StatelessWidget {
  final AnimationController controller;
  final List<Animation<Offset>> positionAnimations;
  final List<Animation<Color?>> colorAnimations;
  final double screenWidth;
  final double screenHeight;
  final bool svg;

  const Blobs({
    required this.controller,
    required this.positionAnimations,
    required this.colorAnimations,
    required this.screenHeight,
    required this.screenWidth,
    required this.svg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LivitColors.mainBlack,
      child: Stack(
        children: MainBackground._defaultBlobPaths.asMap().entries.map(
          (entry) {
            int index = entry.key;
            String blob = entry.value;
            final position = positionAnimations[index].value;
            final color = colorAnimations[index].value;

            return Positioned(
              left: screenWidth * position.dx / 390 - 150,
              top: screenHeight * position.dy / 844 - 150,
              child: svg
                  ? SvgPicture.asset(
                      blob,
                      colorFilter: ColorFilter.mode(
                        color ?? Colors.transparent,
                        BlendMode.srcIn,
                      ),
                    )
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        color ?? Colors.transparent,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        blob,
                        height: MainBackground._defaultBlobHeights[index] * screenHeight,
                      ),
                    ),
            );
          },
        ).toList(),
      ),
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

  final int imageHeight = 853;
  final int imageWidth = 480;

  @override
  Widget build(BuildContext context) {
    String imagePath = blurred ? 'assets/images/dots-blurred.png' : 'assets/images/dots.png';
    return SizedBox(
      child: Image(
        image: AssetImage(imagePath),
        width: screenWidth,
        height: screenHeight,
        fit: BoxFit.fill,
      ),
    );
  }
}
