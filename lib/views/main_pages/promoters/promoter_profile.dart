import 'package:flutter/material.dart';
import 'package:livit/utilities/display/livit_display_area.dart';

class PromoterProfile extends StatefulWidget {
  const PromoterProfile({super.key});

  @override
  State<PromoterProfile> createState() => _PromoterProfileState();
}

class _PromoterProfileState extends State<PromoterProfile> {
  @override
  Widget build(BuildContext context) {
    return const LivitDisplayArea(
      child: Text('Promoter Profile'),
    );
  }
}