import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Center(
          child: CircularProgressIndicator(
            color: LivitColors.whiteActive,
          ),
        ),
      ],
    );
  }
}

class LoadingScreenWithBackground extends StatefulWidget {
  const LoadingScreenWithBackground({super.key});

  @override
  State<LoadingScreenWithBackground> createState() => _LoadingScreenWithBackgroundState();
}

class _LoadingScreenWithBackgroundState extends State<LoadingScreenWithBackground> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Center(
          child: CircularProgressIndicator(
            color: LivitColors.whiteInactive,
          ),
        ),
      ],
    );
  }
}
