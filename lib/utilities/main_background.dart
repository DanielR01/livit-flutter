import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/utilities/blend_mask.dart';

class MainBackground extends StatefulWidget {
  const MainBackground({super.key});

  @override
  State<MainBackground> createState() => _MainBackgroundState();
}

const String imagePath = 'assets/images/dots.png';
List<String> blobPaths = [
  "assets/images/blobs/blob5.png",
  "assets/images/blobs/blob4.png",
  "assets/images/blobs/blob3.png",
  "assets/images/blobs/blob2.png",
  "assets/images/blobs/blob1.png",
];
List<double> blobHeights = [
  (568 + 300) / 844,
  (542 + 300) / 844,
  (485 + 300) / 844,
  (190 + 300) / 844,
  (307.5 + 300) / 844,
];
List<List<List<double>>> blobPositions = [
  [
    [256, -206],
    [270, -186],
    [206, -206],
    [205, -137],
    [23, -392],
  ],
  [
    [-495, 732],
    [-641, 753],
    [-495, 739],
    [-454, 685],
    [-442, 693],
  ],
  [
    [-500, 179],
    [-517, 146],
    [-297, 544],
    [-448, 64],
    [-428, 350],
  ],
  [
    [235, 488],
    [235, 488],
    [235, 594],
    [154, 482],
    [157, 604],
  ],
  [
    [-312, -126],
    [-507, -117],
    [-165, -171],
    [163, -168],
    [-408, 339],
  ],
];
List<List<Color>> blobColorStates = [
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
    LivitColors.whiteActive,
    const Color.fromARGB(255, 182, 182, 182),

    LivitColors.whiteActive,
    //LivitColors.greenActive,
    const Color.fromARGB(255, 136, 136, 136),
  ],
];

class _MainBackgroundState extends State<MainBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<Color?>> _colorAnimations;

  List<int> animationStates = [];

  @override
  void initState() {
    super.initState();

    animationStates = blobPositions[0].map((_) => 0).toList();

    _controllers = blobPaths.map(
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
    final start = blobPositions[blobIndex][animationStates[blobIndex]];
    final end = blobPositions[blobIndex]
        [(animationStates[blobIndex] + 1) % blobPositions[blobIndex].length];
    final colorStart = blobColorStates[blobIndex][animationStates[blobIndex]];
    final colorEnd = blobColorStates[blobIndex]
        [(animationStates[blobIndex] + 1) % blobColorStates[blobIndex].length];

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
            animationStates[blobIndex] = (animationStates[blobIndex] + 1) %
                blobPositions[blobIndex].length;
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
                screenHeight: screenHeight, screenWidth: screenWidth),
          ),
        ],
      ),
    );
  }
}

class DotsBackground extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const DotsBackground({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  final int imageHeight = 853;
  final int imageWidth = 480;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Image(
        image: const AssetImage(imagePath),
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
        children: blobPaths.asMap().entries.map(
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
                            height: blobHeights[index] * screenHeight,
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
