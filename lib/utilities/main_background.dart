import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';

class MainBackground extends StatefulWidget {
  const MainBackground({super.key});

  @override
  State<MainBackground> createState() => _MainBackgroundState();
}

class _MainBackgroundState extends State<MainBackground> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: LivitColors.borderGray,
    );
  }
}