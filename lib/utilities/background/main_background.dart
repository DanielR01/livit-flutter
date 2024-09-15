import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/utilities/background/blend_mask.dart';
import 'dart:math' show Random;

class MainBackground extends StatefulWidget {
  final bool blurred;
  final List<List<List<double>>> blobPositions;
  final List<List<Color>> blobColorStates;

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

  const MainBackground({
    super.key,
    this.blurred = false,
    required this.blobPositions,
    required this.blobColorStates,
  });

  factory MainBackground.normal() {
    return MainBackground(
      blurred: false,
      blobPositions: _defaultBlobPositions,
      blobColorStates: _defaultBlobColorStates,
    );
  }

  factory MainBackground.colorful({bool blurred = false}) {
    List<List<List<double>>> colorfulBlobPositions = [
      for (var blobSet in _defaultBlobPositions)
        [
          for (var position in blobSet)
            [
              position[0] * 0.9, // Reduce horizontal spread
              position[1] * 0.9, // Reduce vertical spread
            ]
        ]
    ];

    return MainBackground(
      blurred: blurred,
      blobPositions: colorfulBlobPositions,
      blobColorStates: _defaultBlobColorStates,
    );
  }

  factory MainBackground.colorfulTinted({
    required Color tintColor,
    required double opacity,
  }) {
    final random = Random();
    List<List<List<double>>> colorfulBlobPositions = [
      for (var blobSet in _defaultBlobPositions)
        [
          for (var position in blobSet)
            [
              position[0] * 0.95, // Reduce horizontal spread
              position[1] * 1, // Reduce vertical spread
            ]
        ]
    ];
    List<List<Color>> tintedBlobColorStates = _defaultBlobColorStates.map((blobColors) {
      return blobColors.map((color) {
        final randomOpacity = (opacity + (random.nextDouble() * 0.7 - 0.35)).clamp(0.0, 1.0);
        return Color.alphaBlend(tintColor.withOpacity(randomOpacity), color);
      }).toList();
    }).toList();

    return MainBackground(
      blurred: false,
      blobPositions: colorfulBlobPositions,
      blobColorStates: tintedBlobColorStates,
    );
  }

  factory MainBackground.normalTinted({
    required Color tintColor,
    required double opacity,
  }) {
    final random = Random();
    List<List<Color>> tintedBlobColorStates = _defaultBlobColorStates.map((blobColors) {
      return blobColors.map((color) {
        final randomOpacity = (opacity + (random.nextDouble() * 0.7 - 0.35)).clamp(0.0, 1.0);
        return Color.alphaBlend(tintColor.withOpacity(randomOpacity), color);
      }).toList();
    }).toList();

    return MainBackground(
      blurred: false,
      blobPositions: _defaultBlobPositions,
      blobColorStates: tintedBlobColorStates,
    );
  }

  factory MainBackground.plainTinted({
    required Color tintColor,
    required double opacity,
    bool blurred = false,
  }) {
    final random = Random();

    List<List<Color>> grayscaleBlobColorStates = _defaultBlobColorStates.map((blobColors) {
      return blobColors.map((color) {
        final hslColor = HSLColor.fromColor(color);
        return hslColor.withSaturation(0).toColor();
      }).toList();
    }).toList();

    List<List<Color>> tintedBlobColorStates = grayscaleBlobColorStates.map((blobColors) {
      return blobColors.map((color) {
        final randomOpacity = (opacity + (random.nextDouble() * 0.8 - 0.4)).clamp(0.0, 1.0);
        return Color.alphaBlend(tintColor.withOpacity(randomOpacity), color);
      }).toList();
    }).toList();

    return MainBackground(
      blurred: blurred,
      blobPositions: _defaultBlobPositions,
      blobColorStates: tintedBlobColorStates,
    );
  }

  @override
  State<MainBackground> createState() => _MainBackgroundState();
}

class _MainBackgroundState extends State<MainBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<Color?>> _colorAnimations;

  List<int> animationStates = [];

  @override
  void initState() {
    super.initState();

    animationStates = widget.blobPositions[0].map((_) => 0).toList();

    _controllers = MainBackground._defaultBlobPaths.map(
      (_) {
        return AnimationController(
          duration: const Duration(milliseconds: 5000),
          vsync: this,
        );
      },
    ).toList();

    _positionAnimations = _controllers.map(
      (controller) {
        return Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(controller);
      },
    ).toList();

    _colorAnimations = _controllers.map(
      (controller) {
        return ColorTween(
          begin: Colors.transparent,
          end: Colors.transparent,
        ).animate(controller);
      },
    ).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      _animateBlob(i);
    }
  }

  void _animateBlob(int blobIndex) {
    final start = widget.blobPositions[blobIndex][animationStates[blobIndex]];
    final end = widget.blobPositions[blobIndex][(animationStates[blobIndex] + 1) % widget.blobPositions[blobIndex].length];
    final colorStart = widget.blobColorStates[blobIndex][animationStates[blobIndex]];
    final colorEnd = widget.blobColorStates[blobIndex][(animationStates[blobIndex] + 1) % widget.blobColorStates[blobIndex].length];

    _positionAnimations[blobIndex] = Tween<Offset>(
      begin: Offset(start[0], start[1]),
      end: Offset(end[0], end[1]),
    ).animate(
      CurvedAnimation(
        parent: _controllers[blobIndex],
        curve: Curves.linear,
      ),
    );

    _colorAnimations[blobIndex] = ColorTween(
      begin: colorStart,
      end: colorEnd,
    ).animate(
      CurvedAnimation(
        parent: _controllers[blobIndex],
        curve: Curves.linear,
      ),
    );

    _controllers[blobIndex].forward(from: 0).whenComplete(
      () {
        setState(
          () {
            animationStates[blobIndex] = (animationStates[blobIndex] + 1) % widget.blobPositions[blobIndex].length;
          },
        );
        _animateBlob(blobIndex);
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
          Blobs(
            controllers: _controllers,
            positionAnimations: _positionAnimations,
            colorAnimations: _colorAnimations,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            svg: false,
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

class Blobs extends StatelessWidget {
  final List<AnimationController> controllers;
  final List<Animation<Offset>> positionAnimations;
  final List<Animation<Color?>> colorAnimations;
  final double screenWidth;
  final double screenHeight;
  final bool svg;

  const Blobs({
    required this.controllers,
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
            return AnimatedBuilder(
              animation: controllers[index],
              builder: (context, child) {
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
            );
          },
        ).toList(),
      ),
    );
  }
}
