// import 'dart:math';
// import 'package:blobs/blobs.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:livit/constants/colors.dart';

// class MainBackground extends StatefulWidget {
//   const MainBackground({super.key});

//   @override
//   State<MainBackground> createState() => _MainBackgroundState();
// }

// const String imagePath = 'assets/images/dots.png';
// List<String> blobPaths = [
//   //'5-6-43178',
//   //Blob.fromID(id: const ['5-6-43178'], size: 200),
//   "assets/images/blobs/blob1.svg",
//   "assets/images/blobs/blob2.svg",
//   "assets/images/blobs/blob3.svg",
// ];
// List<List<List<double>>> blobPositions = [
//   [
//     [-312, -126],
//     [-507, -117],
//   ],
//   [
//     [235, 488],
//     [235, 488],
//   ],
//   [
//     [-500, 179],
//     [-517, 146],
//   ],
// ];

// class _MainBackgroundState extends State<MainBackground> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.sizeOf(context).width;
//     final double screenHeight = MediaQuery.sizeOf(context).height;
//     int animationState = 0;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white10,
//         border: Border.all(
//           width: 1,
//           color: LivitColors.mainBlueActive,
//         ),
//       ),
//       width: screenWidth,
//       height: screenHeight,
//       child: Stack(
//         children: [
//           DotsBackground(screenHeight: screenHeight, screenWidth: screenWidth),
//           Stack(
//             children: blobPaths.map(
//               (blob) {
//                 int index = blobPaths.indexOf(blob);
//                 return Positioned(
//                   left: screenWidth *
//                       blobPositions[index][animationState][0] /
//                       390,
//                   top: screenHeight *
//                       blobPositions[index][animationState][1] /
//                       844,
//                   child: SvgPicture.asset(
//                     blob,
//                     colorFilter: const ColorFilter.mode(
//                       LivitColors.mainBlueActive,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                 );
//               },
//             ).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DotsBackground extends StatelessWidget {
//   final double screenWidth;
//   final double screenHeight;
//   const DotsBackground({
//     super.key,
//     required this.screenHeight,
//     required this.screenWidth,
//   });

//   final int imageHeight = 853;
//   final int imageWidth = 480;

//   final Image dotsImage = const Image(
//     image: AssetImage(imagePath),
//   );

//   @override
//   Widget build(BuildContext context) {
//     final double screenHWratio = screenHeight / screenWidth;
//     final double imageHWratio = imageHeight / imageWidth;

//     if (screenHeight > screenWidth) {
//       return Positioned(
//         left: 0,
//         top: 0,
//         child: Container(
//           height: screenHWratio > imageHWratio ? screenHeight : null,
//           width: screenHWratio > imageHWratio ? null : screenWidth,
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: <Color>[Colors.black, Colors.blue]),
//           ),
//           child: dotsImage,
//         ),
//       );
//     } else {
//       return Positioned(
//         left: screenWidth,
//         top: 0,
//         child: Transform(
//           transform: Matrix4.rotationZ(pi / 2),
//           child: Container(
//             height: 1 / screenHWratio > 1 / imageHWratio ? null : screenWidth,
//             width: 1 / screenHWratio > 1 / imageHWratio ? screenHeight : null,
//             alignment: Alignment.center,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: <Color>[Colors.black, Colors.blue]),
//             ),
//             child: dotsImage,
//           ),
//         ),
//       );
//     }
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livit/constants/colors.dart';

class MainBackground extends StatefulWidget {
  const MainBackground({super.key});

  @override
  State<MainBackground> createState() => _MainBackgroundState();
}

const String imagePath = 'assets/images/dots.png';
List<String> blobPaths = [
  "assets/images/blobs/blob1.svg",
  "assets/images/blobs/blob2.svg",
  "assets/images/blobs/blob3.svg",
];
List<List<List<double>>> blobPositions = [
  [
    [-312, -126],
    [-507, -117],
    [-165, -171],
  ],
  [
    [235, 488],
    [235, 488],
    [235, 594],
  ],
  [
    [-500, 179],
    [-517, 146],
    [-297, 544],
  ],
];
List<List<Color>> blobColorStates = [
  [LivitColors.mainBlueActive, LivitColors.whiteActive, LivitColors.mainBlueActive],
  [LivitColors.mainBlack, LivitColors.mainBlueActive, LivitColors.mainBlack],
  [LivitColors.whiteActive, LivitColors.mainBlack, LivitColors.mainBlack],
];

class _MainBackgroundState extends State<MainBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<Color?>> _colorAnimations;
  int animationState = 0;

  @override
  void initState() {
    super.initState();

    _controllers = blobPaths.map((_) {
      return AnimationController(
        duration: const Duration(milliseconds: 5000),
        vsync: this,
      );
    }).toList();

    _positionAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(controller);
    }).toList();

    _colorAnimations = _controllers.map((controller) {
      return ColorTween(
        begin: Colors.transparent,
        end: Colors.transparent,
      ).animate(controller);
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      _animateBlob(i);
    }
  }

  void _animateBlob(int index) {
    final start = blobPositions[index][animationState];
    final end = blobPositions[index]
        [(animationState + 1) % blobPositions[index].length];
    final colorStart = blobColorStates[index][animationState];
    final colorEnd = blobColorStates[index]
        [(animationState + 1) % blobColorStates[index].length];

    _positionAnimations[index] = Tween<Offset>(
      begin: Offset(start[0], start[1]),
      end: Offset(end[0], end[1]),
    ).animate(CurvedAnimation(
      parent: _controllers[index],
      curve: Curves.linear,
    ));

    _colorAnimations[index] = ColorTween(
      begin: colorStart,
      end: colorEnd,
    ).animate(CurvedAnimation(
      parent: _controllers[index],
      curve: Curves.linear,
    ));

    _controllers[index].forward(from: 0).whenComplete(() {
      setState(() {
        animationState = (animationState + 1) % blobPositions[index].length;
      });
      _animateBlob(index);
    });
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
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border.all(
          width: 1,
          color: LivitColors.mainBlueActive,
        ),
      ),
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          DotsBackground(screenHeight: screenHeight, screenWidth: screenWidth),
          Stack(
            children: blobPaths.asMap().entries.map(
              (entry) {
                int index = entry.key;
                String blob = entry.value;
                return AnimatedBuilder(
                  animation: _controllers[index],
                  builder: (context, child) {
                    final position = _positionAnimations[index].value;
                    final color = _colorAnimations[index].value;
                    return Positioned(
                      left: screenWidth * position.dx / 390,
                      top: screenHeight * position.dy / 844,
                      child: SvgPicture.asset(
                        blob,
                        colorFilter: ColorFilter.mode(
                          color ?? Colors.transparent,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                );
              },
            ).toList(),
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

  final Image dotsImage = const Image(
    image: AssetImage(imagePath),
  );

  @override
  Widget build(BuildContext context) {
    final double screenHWratio = screenHeight / screenWidth;
    final double imageHWratio = imageHeight / imageWidth;

    if (screenHeight > screenWidth) {
      return Positioned(
        left: 0,
        top: 0,
        child: Container(
          height: screenHWratio > imageHWratio ? screenHeight : null,
          width: screenHWratio > imageHWratio ? null : screenWidth,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.black, Colors.blue],
            ),
          ),
          child: dotsImage,
        ),
      );
    } else {
      return Positioned(
        left: screenWidth,
        top: 0,
        child: Transform(
          transform: Matrix4.rotationZ(pi / 2),
          child: Container(
            height: 1 / screenHWratio > 1 / imageHWratio ? null : screenWidth,
            width: 1 / screenHWratio > 1 / imageHWratio ? screenHeight : null,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.black, Colors.blue],
              ),
            ),
            child: dotsImage,
          ),
        ),
      );
    }
  }
}
