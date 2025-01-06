import 'dart:ui';
import 'package:livit/constants/colors.dart';

class BackgroundDefaults {
  static final List<String> defaultBlobPaths = [
    "assets/images/blobs/blob5.png",
    "assets/images/blobs/blob4.png",
    "assets/images/blobs/blob3.png",
    "assets/images/blobs/blob2.png",
    "assets/images/blobs/blob1.png",
  ];
  static final List<double> defaultBlobHeights = [
    (568 + 300) / 844,
    (542 + 300) / 844,
    (485 + 300) / 844,
    (190 + 300) / 844,
    (307.5 + 300) / 844,
  ];
  static final List<List<List<double>>> defaultBlobPositions = [
    [
      [506, -206],
      [354, 24],
      [358, -146],
      [330, 622],
      [330, 622],
    ],
    [
      [-395, 739],
      [-495, 739],
      [-182, 842],
      [-182, 842],
      [-182, 842],
    ],
    [
      [-900, 180],
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
  static final List<List<Color>> defaultBlobColorStates = [
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
}
