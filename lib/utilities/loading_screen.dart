import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/utilities/background/main_background.dart';

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
        MainBackground(),
        Center(
          child: CircularProgressIndicator(
            color: LivitColors.whiteInactive,
          ),
        ),
      ],
    );
  }
}
